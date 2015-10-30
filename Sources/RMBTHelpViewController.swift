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
//  RMBTHelpViewController.swift
//  RMBT
//
//  Created by Tomáš Baculák on 19/01/15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import UIKit

///
class RMBTHelpViewController: UIViewController, SWRevealViewControllerDelegate {

    ///
    @IBOutlet var helpView: UIWebView!
    
    ///
    @IBOutlet var sideBarButton: UIBarButtonItem!
    
    //
    
    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        // Assign action for the side button
        sideBarButton.target = revealViewController()
        sideBarButton.action = "revealToggle:"
        
        view.addGestureRecognizer(revealViewController().edgeGestureRecognizer())
        view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
        
        revealViewController().delegate = self
    
        let url = NSURL(string: RMBTLocalizeURLString(RMBT_HELP_URL))
        let urlRequest = NSURLRequest(URL: url!)
        
        helpView.loadRequest(urlRequest)
    }
    
    ///
    func revealController(revealController: SWRevealViewController!, didMoveToPosition position: FrontViewPosition) {
        if position == FrontViewPosition.Left {
            view.removeGestureRecognizer(revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(revealViewController().edgeGestureRecognizer())
            
            helpView.scrollView.scrollEnabled = true
        }
        
        if position == FrontViewPosition.Right {
            view.removeGestureRecognizer(revealViewController().edgeGestureRecognizer())
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            
            helpView.scrollView.scrollEnabled = false
        }
    }
}
