/*********************************************************************************
* Copyright 2014-2015 SPECURE GmbH
* 
* Redistribution and use of the RMBT code or any derivative works are 
* permitted provided that the following conditions are met:
* 
*   - Redistributions may not be sold, nor may they be used in a commercial 
*     product or activity.
*   - Redistributions that are modified from the original source must include 
*     the complete source code, including the source code for all components
*     used by a binary built from the modified sources. However, as a special 
*     exception, the source code distributed need not include anything that is 
*     normally distributed (in either source or binary form) with the major 
*     components (compiler, kernel, and so on) of the operating system on which 
*     the executable runs, unless that component itself accompanies the executable.
*   - Redistributions must reproduce the above copyright notice, this list of 
*     conditions and the following disclaimer in the documentation and/or
*     other materials provided with the distribution.
* 
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
* BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
* DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
* OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
* OF THE POSSIBILITY OF SUCH DAMAGE.
*********************************************************************************/

//
//  RMBTInitialViewController.swift
//  RMBT
//
//  Created by Tomáš Baculák on 14/01/15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import UIKit

///
class RMBTInitialViewController: UIViewController, SWRevealViewControllerDelegate, RMBTConnectivityTrackerDelegate, UIViewControllerTransitioningDelegate, RMBTTesterViewControllerProtocol {
    
    ///
    @IBOutlet private var sideBarButton: UIBarButtonItem!
    
    ///
    @IBOutlet private var networkTypeLabel: UILabel!
    
    ///
    @IBOutlet private var networkNameLabel: UILabel!
    
    ///
    @IBOutlet private var networkTypeImageView: UIImageView!
    
    ///
    @IBOutlet private var walledGardenImageView: UIImageView!
    
    ///
    @IBOutlet private var startTestButton: UIButton!
    
    //
    
    ///
    @IBOutlet private var hardwareView: RMBTPUHardwareView!
    
    ///
    @IBOutlet private var protocolView: RMBTPUProtocolView!

    ///
    @IBOutlet private var locationView: RMBTPULocationView!
    
    ///
    @IBOutlet private var trafficView: RMBTPUTrafficView!
    
    //
    
    ///
    @IBOutlet private var bottomView: UIView!
    
    ///
    private var _connectivityTracker: RMBTConnectivityTracker!
    
    ///
    private var _result: RMBTHistoryResult?

    ///
    private var timer: NSTimer?
    
    ///
    private var ipAddressUpdateCount = 0
    
    ///
    private var ipAddressLastUpdated: UInt64 = 0
    
    ///
    private var currentConnectivityNetworkType: RMBTNetworkType = .None
    
    //
    
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        protocolView.setColorForStatusView(PROGRESS_INDICATOR_FILL_COLOR)
        
        view.backgroundColor = INITIAL_VIEW_BACKGROUND_COLOR
        bottomView.backgroundColor = INITIAL_BOTTOM_VIEW_BACKGROUND_COLOR

        if (INITIAL_VIEW_USE_GRADIENT) {
            let gradiantLayer = CAGradientLayer()

            gradiantLayer.frame = view.bounds
            gradiantLayer.frame.height - (UIScreen.mainScreen().bounds.size.height - startTestButton.frameY) // let gradiant stop above test start button
            
            gradiantLayer.colors = [
                INITIAL_VIEW_GRADIENT_TOP_COLOR.CGColor,
                INITIAL_VIEW_GRADIENT_BOTTOM_COLOR.CGColor
            ]
            
            view.layer.insertSublayer(gradiantLayer, atIndex: 0)
        }
        
        networkTypeLabel.textColor = INITIAL_SCREEN_TEXT_COLOR
        networkNameLabel.textColor = INITIAL_SCREEN_TEXT_COLOR
        
        // Assign action for the side button
        sideBarButton.target = revealViewController()
        sideBarButton.action = "revealToggle:"
        
        view.addGestureRecognizer(revealViewController().edgeGestureRecognizer())
        view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
        
        revealViewController().delegate = self
        
        networkNameLabel.text = ""
        networkTypeLabel.text = ""
        networkTypeImageView.image = nil // Clear placeholder image
        
        let tos = RMBTTOS.sharedTOS
        
        // If user hasn't agreed to new TOS version, show TOS modally
        if (!tos.isCurrentVersionAccepted()) {
            //RMBTLog("Current TOS version %d > last accepted version %d, showing dialog", tos.currentVersion, tos.lastAcceptedVersion)
            self.performSegueWithIdentifier("show_tos", sender: self)
        }
        
        // startTestButton normal state
        startTestButton.setTitleColor(TEST_START_BUTTON_TEXT_COLOR, forState: .Normal)
        startTestButton.setBackgroundImage(imageWithColor(TEST_START_BUTTON_BACKGROUND_COLOR), forState: .Normal)
        
        // startTestButton disabled state
        startTestButton.setTitleColor(TEST_START_BUTTON_TEXT_COLOR, forState: .Disabled)
        startTestButton.setBackgroundImage(imageWithColor(TEST_START_BUTTON_DISABLED_BACKGROUND_COLOR), forState: .Disabled)
        
        startTestButton.layer.masksToBounds = true
        startTestButton.layer.cornerRadius = 5.0
        
        if (!RMBTIsRunningOnWideScreen()) {
            startTestButton.frameY -= 4.0
        }
    }
    
    ///
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (_connectivityTracker == nil) {
            _connectivityTracker = RMBTConnectivityTracker(delegate: self, stopOnMixed: false)
            _connectivityTracker.start()
        }
        
        // init timer
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTimerFired", userInfo: nil, repeats: true)
    }
    
    ///
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
        timer = nil
    }
    
    ///
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "pushTestResultsView") {
            let trController = segue.destinationViewController as! RMBTHistoryResultViewController
            trController.historyResult = sender as? RMBTHistoryResult
        }
    }
    
    ///
    func updateTimerFired() {
        //logger.debug("updateTimerFired")
        
        // update hardware, traffic and location view every second
        hardwareView.updateView()
        trafficView.updateView()
        locationView.updateView()
        
        // update ip addresses and walled garden every now, 2x every 5 sec, then every time after 30
        let curTimeMS = currentTimeMillis()
        
        if (
            ipAddressUpdateCount == 0 || // now
            (ipAddressUpdateCount > 0 && ipAddressUpdateCount < 3) && (Int64(curTimeMS) - Int64(ipAddressLastUpdated)) >= 5_000 || // every 5 sec
            ipAddressUpdateCount >= 3 && (Int64(curTimeMS) - Int64(ipAddressLastUpdated)) >= 30_000 // every 30 sec
        ) {
                
            logger.debug("updating ip address after \(curTimeMS - ipAddressLastUpdated) ms")
            
            protocolView.updateView()
            checkWalledGarden()
            
            ipAddressUpdateCount++
            ipAddressLastUpdated = curTimeMS
        }
    }
    
    ///
    func imageWithColor(color: UIColor) -> UIImage {
        let rect: CGRect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContextRef = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
// MARK: - SWRevealViewController Delegate

    ///
    func revealController(revealController: SWRevealViewController!, didMoveToPosition position: FrontViewPosition) {
        if (position == FrontViewPosition.Right) {
            
            view.removeGestureRecognizer(revealViewController().edgeGestureRecognizer())
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            
            hardwareView.userInteractionEnabled = false
            protocolView.userInteractionEnabled = false
            locationView.userInteractionEnabled = false
            trafficView.userInteractionEnabled = false
            
            startTestButton.userInteractionEnabled = false
            
        } else if (position == FrontViewPosition.Left) {

            view.removeGestureRecognizer(revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(revealViewController().edgeGestureRecognizer())
            
            hardwareView.userInteractionEnabled = true
            protocolView.userInteractionEnabled = true
            locationView.userInteractionEnabled = true
            trafficView.userInteractionEnabled = true
            
            startTestButton.userInteractionEnabled = true
        }
    }
    
    ///
    @IBAction func startTest(sender: AnyObject) {
        if (currentConnectivityNetworkType == .Cellular) {
            // show alert message
        
            let message = NSLocalizedString("test.intro-message", value: "Using AKOS Test Net on mobile devices may cause consumption of large data amount. By using it on 3G technology the usual data amount would be between 5 and 10 MB. On 4G data amount may exceed 100 MB", comment: "Alert view test intro message")
            
            let alertView = UIAlertView.bk_alertViewWithTitle(RMBTAppTitle(), message: message) as! UIAlertView
            alertView.bk_addButtonWithTitle(NSLocalizedString("test.ok-button", value: "OK", comment: "Alert view button"), handler: {
                self.startTestNow()
            })
            alertView.bk_setCancelButtonWithTitle(NSLocalizedString("test.abort-test-button", value: "Abort Test", comment: "Abort test alert button"), handler: {
                // do nothing
            })

            alertView.show()
        } else {
            startTestNow()
        }
    }
    
    private func startTestNow() {
        UIApplication.sharedApplication().idleTimerDisabled = true // Disallow turning off the screen
        
        RMBTLocationTracker.sharedTracker.startAfterDeterminingAuthorizationStatus {
            let testVC = self.storyboard?.instantiateViewControllerWithIdentifier("test_vc_new") as! RMBTTesterViewController
            testVC.transitioningDelegate = self
            testVC.delegate = self
            
            self.presentViewController(testVC, animated: true, completion: nil)
        }
    }
    
// MARK: Segues and actions

    ///
    @IBAction func showHelp(sender: AnyObject) {
        presentModalBrowserWithURLString(RMBT_HELP_URL)
    }
    
    ///
    func testViewController(controller: RMBTTesterViewController, didFinishWithResult: RMBTHistoryResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        performSegueWithIdentifier("pushTestResultsView", sender: didFinishWithResult)
    }
    
// MARK: RMBTConnectivityTrackerDelegate

    ///
    func connectivityTrackerDidDetectNoConnectivity(tracker: RMBTConnectivityTracker!) {
        dispatch_async(dispatch_get_main_queue()) {
            self.currentConnectivityNetworkType = .None
            
            self.networkNameLabel.text = ""
            self.networkTypeLabel.text = NSLocalizedString("intro.network.connection.unavailable", value: "No network connection available", comment: "Test intro screen title when there's no connectivity")
            
            self.networkTypeImageView.image = UIImage(named: "intro_none")

            self.startTestButton.enabled = false
            
            // reset timer values
            self.ipAddressUpdateCount = 0
            self.ipAddressLastUpdated = 0
            
            self.protocolView.connectivityDidChange()
        }
    }
    
    ///
    func connectivityTracker(tracker: RMBTConnectivityTracker!, didDetectConnectivity connectivity: RMBTConnectivity!) {
        dispatch_async(dispatch_get_main_queue()) {
            self.currentConnectivityNetworkType = connectivity.networkType
            
            //
            
            self.startTestButton.enabled = true
            
            //
            
            self.networkNameLabel.text = connectivity.networkName ?? NSLocalizedString("intro.network.connection.name-unknown", value: "Unknown", comment: "unknown wifi or operator name")
            
            //
            
            if let cd = connectivity.testResultDictionary()["telephony_network_sim_operator"] as? String {
                self.networkTypeLabel.text = "\(connectivity.networkTypeDescription), \(cd)"
            } else {
                self.networkTypeLabel.text = connectivity.networkTypeDescription
            }
            
            //
            
            if (connectivity.networkType == .WiFi) {
                self.networkTypeImageView.image = UIImage(named: "intro_wifi_new")
            } else if (connectivity.networkType == .Cellular) {
                self.networkTypeImageView.image = UIImage(named: "intro_cellular_new")
            }
            
            // reset timer values
            self.ipAddressUpdateCount = 0
            self.ipAddressLastUpdated = 0
            
            self.protocolView.connectivityDidChange()
        }
        
        // check walled garden
        checkWalledGarden()
    }
    
    ///
    private func checkWalledGarden() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            WalledGardenTest.isWalledGardenConnection { isWalledGarden in
                //logger.debug("!?!?!?! is walled garden: \(isWalledGarden)")
                
                if (isWalledGarden) {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.walledGardenImageView.hidden = false
                        self.startTestButton.enabled = false
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.walledGardenImageView.hidden = true
                        self.startTestButton.enabled = true
                    }
                }
            }
        }
    }
    
// MARK: Animation delegate
    
    ///
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return RMBTVerticalTransitionController()
    }

    ///
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let v = RMBTVerticalTransitionController()
        v.reverse = true
        
        return v
    }
}
