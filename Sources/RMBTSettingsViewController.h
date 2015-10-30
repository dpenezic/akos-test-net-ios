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

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"

@interface RMBTSettingsViewController : UITableViewController <SWRevealViewControllerDelegate>

// general

@property (weak, nonatomic) IBOutlet UISwitch *forceIPv4Switch;
@property (weak, nonatomic) IBOutlet UISwitch *debugForceIPv6Switch;

@property (weak, nonatomic) IBOutlet UISwitch *publishPublicDataSwitch;

// loop mode

@property (weak, nonatomic) IBOutlet UISwitch *debugLoopModeSwitch;
@property (weak, nonatomic) IBOutlet UITextField *debugLoopModeMaxTestsTextField;
@property (weak, nonatomic) IBOutlet UITextField *debugLoopModeMinDelayTextField;
@property (weak, nonatomic) IBOutlet UISwitch *debugLoopModeSkipQOSSwitch;

// custom control server

@property (weak, nonatomic) IBOutlet UISwitch *debugControlServerCustomizationEnabledSwitch;
@property (weak, nonatomic) IBOutlet UITextField *debugControlServerHostnameTextField;
@property (weak, nonatomic) IBOutlet UITextField *debugControlServerPortTextField;
@property (weak, nonatomic) IBOutlet UISwitch *debugControlServerUseSSLSwitch;

// custom map server

@property (weak, nonatomic) IBOutlet UISwitch *debugMapServerCustomizationEnabledSwitch;
@property (weak, nonatomic) IBOutlet UITextField *debugMapServerHostnameTextField;
@property (weak, nonatomic) IBOutlet UITextField *debugMapServerPortTextField;
@property (weak, nonatomic) IBOutlet UISwitch *debugMapServerUseSSLSwitch;

// logging

@property (weak, nonatomic) IBOutlet UISwitch *debugLoggingEnabledSwitch;
//@property (weak, nonatomic) IBOutlet UITextField *debugLoggingHostnameTextField;
//@property (weak, nonatomic) IBOutlet UITextField *debugLoggingPortTextField;

// other

@property (nonatomic) IBOutlet UIBarButtonItem  *sideBarButton;

@end
