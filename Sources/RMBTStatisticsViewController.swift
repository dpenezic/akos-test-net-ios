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
//  RMBTStatisticsViewController.swift
//  RMBT
//
//  Created by Tomáš Baculák on 06/02/15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import UIKit

///
class RMBTStatisticsViewController : UIViewController/*, KINWebBrowserDelegate*/, SWRevealViewControllerDelegate {
    
    ///
    @IBOutlet var sideBarButton: UIBarButtonItem!
    
    ///
    private let webBrowser = KINWebBrowserViewController()
    
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let revealController = revealViewController()
        
        // Assign action for the side button
        sideBarButton.target = revealController
        sideBarButton.action = "revealToggle:"
        
        view.addGestureRecognizer(revealController.edgeGestureRecognizer())
        //view.addGestureRecognizer(revealController.panGestureRecognizer())
        view.addGestureRecognizer(revealController.tapGestureRecognizer())
        
        revealController.delegate = self
        
        view.opaque = false
        view.backgroundColor = UIColor.whiteColor()
        
        //webBrowser.delegate = self
        
        webBrowser.showsPageTitleInNavigationBar = false
        webBrowser.showsURLInNavigationBar = false
        webBrowser.actionButtonHidden = false
        
        webBrowser.loadURLString(RMBTLocalizeURLString(RMBT_STATS_URL))

        addChildViewController(webBrowser)
        
        view.addSubview(webBrowser.view)
        setToolbarItems(webBrowser.toolbarItems!, animated: false)
    }
    
    ///
    func revealControllerPanGestureBegan(revealController: SWRevealViewController!) {
        webBrowser.uiWebView?.scrollView.scrollEnabled = false
        webBrowser.wkWebView?.scrollView.scrollEnabled = false

        webBrowser.view.userInteractionEnabled = false
    }
    
    ///
    func revealControllerPanGestureEnded(revealController: SWRevealViewController!) {
        webBrowser.uiWebView?.scrollView.scrollEnabled = true
        webBrowser.wkWebView?.scrollView.scrollEnabled = true
        
        webBrowser.view.userInteractionEnabled = true
    }
    
    ///
    func revealController(revealController: SWRevealViewController!, didMoveToPosition position: FrontViewPosition) {
        let isPosLeft = (position == .Left)
        
        webBrowser.view.userInteractionEnabled = isPosLeft
        
        webBrowser.uiWebView?.scrollView.scrollEnabled = isPosLeft
        webBrowser.wkWebView?.scrollView.scrollEnabled = isPosLeft
        
        if (isPosLeft) {
            view.removeGestureRecognizer(revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(revealViewController().edgeGestureRecognizer())
        } else {
            view.removeGestureRecognizer(revealViewController().edgeGestureRecognizer())
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
    }
}
