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

//
//  RMBTInfoViewController.swift
//  RMBT
//
//  Created by Benjamin Pucher on 23.09.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
class RMBTInfoViewController : UITableViewController, MFMailComposeViewControllerDelegate, UITabBarControllerDelegate, SWRevealViewControllerDelegate {

    ///
    private enum RMBTInfoViewControllerSection : Int {
        case Links = 0
        case ClientInfo = 1
        case DevInfo = 2
    }
    
    //
    
    ///
    @IBOutlet var headerTitleLabel: UILabel!
    
    ///
    @IBOutlet var testCounterLabel: UILabel!
    
    ///
    @IBOutlet var uuidCell: UITableViewCell!
    
    ///
    @IBOutlet var privacyCell: UITableViewCell!
    
    ///
    @IBOutlet var uuidLabel: UILabel!
    
    ///
    @IBOutlet var buildDetailsLabel: UILabel!
    
    ///
    @IBOutlet var sideBarButton: UIBarButtonItem!
    
    ///
    private var _uuid: String?
    
    //
    
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign action for the side button
        sideBarButton.target = revealViewController()
        sideBarButton.action = "revealToggle:"

        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
//        view.addGestureRecognizer(revealViewController().edgeGestureRecognizer())
        view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
        
        revealViewController().delegate = self
     
        buildDetailsLabel.lineBreakMode = .ByCharWrapping

        // TODO:
        //let bundleShortVersionString: String = (NSBundle.mainBundle().infoDictionary["CFBundleShortVersionString"]) as AnyObject! as String! // wtf cast?
        let bundleShortVersionString: String = "dev"
        buildDetailsLabel.text = "\(bundleShortVersionString) \(RMBTBuildInfoString()) (\(RMBTBuildDateString()))" // TODO: RMBTBuildDateString is not shown
        
        uuidLabel.lineBreakMode = .ByCharWrapping
        uuidLabel.numberOfLines = 0
        
        headerTitleLabel.text = RMBTAppTitle()
    }
    
    ///
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        testCounterLabel.text = String(format: "%lu", RMBTSettings.sharedSettings().testCounter)
    
        _uuid = ControlServer.sharedControlServer.uuid
        if let uuid = _uuid {
            uuidLabel.text = "U\(uuid)"
        }
    }
    
    ///
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //tabBarController?.delegate = self
    }
    
    ///
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //tabBarController?.delegate = nil
    }
    
// MARK: tableView
    
    ///
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == RMBTInfoViewControllerSection.ClientInfo.rawValue && indexPath.row == 0) {
            // UUID
            return self.uuidCell.rmbtApproximateOptimalHeight()
        } else if (indexPath.section == RMBTInfoViewControllerSection.Links.rawValue && indexPath.row == 2) {
            // Privacy
            return self.privacyCell.rmbtApproximateOptimalHeight()
        } else if (indexPath.section == RMBTInfoViewControllerSection.ClientInfo.rawValue && indexPath.row == 2) {
            // Version
            return 62
        } else {
            return 44
        }
    }
    
    ///
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == RMBTInfoViewControllerSection.Links.rawValue) {
            switch (indexPath.row) {
                case 0: self.presentModalBrowserWithURLString(RMBT_PROJECT_URL)
                case 1:
                    if (MFMailComposeViewController.canSendMail()) {
                        let mailVC: MFMailComposeViewController = MFMailComposeViewController()
                        mailVC.setToRecipients([RMBT_PROJECT_EMAIL])
                        mailVC.mailComposeDelegate = self
                        
                        self.presentViewController(mailVC, animated: true, completion: nil)
                    }
                case 2: self.presentModalBrowserWithURLString(RMBT_PRIVACY_TOS_URL)
                default: assert(false, "Invalid row")
            }
        } else if (indexPath.section == RMBTInfoViewControllerSection.DevInfo.rawValue) {
            switch (indexPath.row) {
                case 0: self.presentModalBrowserWithURLString(RMBT_DEVELOPER_URL)
                //case 1: self.presentModalBrowserWithURLString(RMBT_REPO_URL)
                case 1: break // Do nothing
                default: assert(false, "Invalid row")
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    ///
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    ///
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "show_google_maps_notice") { // strange bug sometimes: http://stackoverflow.com/questions/25681427/xcode6-beta7-prepareforsegue-throws-exc-bad-access
            let textVC: RMBTInfoTextViewController = segue.destinationViewController as! RMBTInfoTextViewController
            
            textVC.text = GMSServices.openSourceLicenseInfo()
            textVC.title = NSLocalizedString("info.google-maps.legal-notice", value: "Legal Notice", comment: "Google Maps Legal Notice navigation title")
        }
    }
    
// MARK: Tableview actions (copying UUID)
    
    /// Show "Copy" action for cell showing client UUID
    override func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return (indexPath.section == RMBTInfoViewControllerSection.ClientInfo.rawValue && indexPath.row == 0 && self._uuid != nil)
    }
    
    /// As client UUID is the only cell we can perform action for, we allow "copy" here
    override func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject) -> Bool {
        return action == "copy"
    }
    
    ///
    override func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject!) {
        if (action == "copy") {
            // Copy UUID to pasteboard
            UIPasteboard.generalPasteboard().string = _uuid
        }
    }
    
// MARK: Tab bar reloading
    
    ///
//    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
//        if (viewController == self.navigationController) {
//            self.tableView.setContentOffset(CGPointMake(0, -64), animated: true)
//        }
//    }
    
// MARK: - SWRevealViewControllerDelegate
    
    ///
    func revealController(revealController: SWRevealViewController!, didMoveToPosition position: FrontViewPosition) {
        let isPosLeft = position == .Left
        
        tableView?.scrollEnabled = isPosLeft
        tableView?.allowsSelection = isPosLeft
        
        if (isPosLeft) {
            view.removeGestureRecognizer(revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(revealViewController().edgeGestureRecognizer())
        } else {
            view.removeGestureRecognizer(revealViewController().edgeGestureRecognizer())
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
    }
}
