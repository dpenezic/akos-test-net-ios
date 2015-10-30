/*********************************************************************************
* Copyright 2013 appscape gmbh
* Copyright 2014-2015 SPECURE GmbH
* 
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
* 
*   http://www.apache.org/licenses/LICENSE-2.0
* 
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*********************************************************************************/

#import "RMBTSettingsViewController.h"
#import "RMBTSettings.h"

#import "RMBT-Swift.h"

@implementation RMBTSettingsViewController

// TODO: dismiss number input fields!

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sideBarButton.target = self.revealViewController;
    _sideBarButton.action = @selector(revealToggle:);
    // Set the gesture
    
    [self.view addGestureRecognizer: self.revealViewController.edgeGestureRecognizer];
    [self.view addGestureRecognizer: self.revealViewController.tapGestureRecognizer];
    
    self.revealViewController.delegate = self;
    
    RMBTSettings *settings = [RMBTSettings sharedSettings];

    // general
    
    [self bindSwitch:self.forceIPv4Switch
          toSettingsKeyPath:@keypath(settings, forceIPv4)
          onToggle:^(BOOL value) {
              if (value /*&& settings.debugUnlocked*/ && self.debugForceIPv6Switch.on) {
                  settings.debugForceIPv6 = NO;
                  [self.debugForceIPv6Switch setOn:NO animated:YES];
              }
          }];

    [self bindSwitch:self.debugForceIPv6Switch
          toSettingsKeyPath:@keypath(settings, debugForceIPv6)
          onToggle:^(BOOL value) {
              if (value && self.forceIPv4Switch.on) {
                  settings.forceIPv4 = NO;
                  [self.forceIPv4Switch setOn:NO animated:YES];
              }
          }];
    
    [self bindSwitch:self.publishPublicDataSwitch
          toSettingsKeyPath:@keypath(settings, publishPublicData)
          onToggle:^(BOOL value) {
              if (value) {
                  // TODO: is set to on -> show terms and conditions again
                  [self performSegueWithIdentifier:@"show_tos_from_settings" sender:self];
              }
          }];
    
    // loop mode
    
    [self bindSwitch:self.debugLoopModeSwitch
          toSettingsKeyPath:@keypath(settings, debugLoopMode)
          onToggle:^(BOOL value) {
              [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
              [self.tableView reloadData];
          }];
    
    [self bindTextField:self.debugLoopModeMaxTestsTextField
      toSettingsKeyPath:@keypath(settings, debugLoopModeMaxTests)
                numeric:YES];
    
    [self bindTextField:self.debugLoopModeMinDelayTextField
      toSettingsKeyPath:@keypath(settings, debugLoopModeMinDelay)
                numeric:YES];

    [self bindSwitch:self.debugLoopModeSkipQOSSwitch
        toSettingsKeyPath:@keypath(settings, debugLoopModeSkipQOS)
            onToggle:nil];
    
    // custom control server
    
    [self bindSwitch:self.debugControlServerCustomizationEnabledSwitch
          toSettingsKeyPath:@keypath(settings, debugControlServerCustomizationEnabled)
          onToggle:^(BOOL value) {
              [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
              [self.tableView reloadData];
          }];

    [self bindTextField:self.debugControlServerHostnameTextField
          toSettingsKeyPath:@keypath(settings, debugControlServerHostname)
          numeric:NO];

    [self bindTextField:self.debugControlServerPortTextField
          toSettingsKeyPath:@keypath(settings, debugControlServerPort)
          numeric:YES];

    [self bindSwitch:self.debugControlServerUseSSLSwitch
          toSettingsKeyPath:@keypath(settings, debugControlServerUseSSL)
          onToggle:nil];

    // custom map server
    
    [self bindSwitch:self.debugMapServerCustomizationEnabledSwitch
          toSettingsKeyPath:@keypath(settings, debugMapServerCustomizationEnabled)
          onToggle:^(BOOL value) {
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView reloadData];
            }];
    
    [self bindTextField:self.debugMapServerHostnameTextField
      toSettingsKeyPath:@keypath(settings, debugMapServerHostname)
                numeric:NO];
    
    [self bindTextField:self.debugMapServerPortTextField
      toSettingsKeyPath:@keypath(settings, debugMapServerPort)
                numeric:YES];
    
    [self bindSwitch:self.debugMapServerUseSSLSwitch
   toSettingsKeyPath:@keypath(settings, debugMapServerUseSSL)
            onToggle:nil];
    
    // logging
    
    [self bindSwitch:self.debugLoggingEnabledSwitch
   toSettingsKeyPath:@keypath(settings, debugLoggingEnabled)
            onToggle:^(BOOL value) {
        //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationAutomatic];
        //[self.tableView reloadData];
    }];

    //[self bindTextField:self.debugLoggingHostnameTextField
    //  toSettingsKeyPath:@keypath(settings, debugLoggingHostname)
    //            numeric:NO];

    //[self bindTextField:self.debugLoggingPortTextField
    //  toSettingsKeyPath:@keypath(settings, debugLoggingPort)
    //            numeric:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    self.publishPublicDataSwitch.on = [RMBTSettings sharedSettings].publishPublicData;
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[ControlServer sharedControlServer] updateWithCurrentSettings];
}

#pragma mark - Two-way binding helpers

- (void)bindSwitch:(UISwitch*)aSwitch toSettingsKeyPath:(NSString*)keyPath onToggle:(void(^)(BOOL value))onToggle {
    aSwitch.on = [[[RMBTSettings sharedSettings] valueForKey:keyPath] boolValue];
    [aSwitch bk_addEventHandler:^(UISwitch *sender) {
        [[RMBTSettings sharedSettings] setValue:[NSNumber numberWithBool:sender.on] forKey:keyPath];
        if (onToggle) onToggle(sender.on);
    } forControlEvents:UIControlEventValueChanged];
}

- (void)bindTextField:(UITextField*)aTextField toSettingsKeyPath:(NSString*)keyPath numeric:(BOOL)numeric {
    id value = [[RMBTSettings sharedSettings] valueForKey:keyPath];
    NSString *stringValue = numeric ? [value stringValue] : value;
    if (numeric && [stringValue isEqualToString:@"0"]) stringValue = nil;
    aTextField.text = stringValue;

    [aTextField bk_addEventHandler:^(UITextField *sender) {
        id newValue = numeric ? [NSNumber numberWithInteger:[sender.text integerValue]] : sender.text;
        [[RMBTSettings sharedSettings] setValue:newValue forKey:keyPath];
    } forControlEvents:UIControlEventEditingDidEnd];
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [RMBTSettings sharedSettings].debugUnlocked ? /*6*/5 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && ![RMBTSettings sharedSettings].debugUnlocked) {
        return 2; // hide force ipv6
    } else if (section == 1 && ![RMBTSettings sharedSettings].debugLoopMode) {
        return 1;
    } else if (section == 2 && ![RMBTSettings sharedSettings].debugControlServerCustomizationEnabled) {
        // If control server customization is disabled, hide hostname/port/ssl cells
        return 1;
    } else if (section == 3 && ![RMBTSettings sharedSettings].debugMapServerCustomizationEnabled) {
        return 1;
    //} else if (section == 3 && ![RMBTSettings sharedSettings].debugLoggingEnabled) {
    //    return 1;
    } else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

#pragma mark - Textfield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark SWRevealViewControllerDelegate

- (void)revealControllerPanGestureBegan:(SWRevealViewController *)revealController {
    
    self.tableView.scrollEnabled = NO;
}

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
{
    self.tableView.scrollEnabled = NO;
    //[self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    //[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position {
    
    if (position == FrontViewPositionLeft) {
        
        self.tableView.scrollEnabled = YES;
        self.tableView.allowsSelection = YES;
        [self.view removeGestureRecognizer:self.revealViewController.panGestureRecognizer];
        [self.view addGestureRecognizer:self.revealViewController.edgeGestureRecognizer];
    }
    
    if (position == FrontViewPositionRight) {
        
        self.tableView.scrollEnabled = NO;
        self.tableView.allowsSelection = NO;
        [self.view removeGestureRecognizer:self.revealViewController.edgeGestureRecognizer];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

@end
