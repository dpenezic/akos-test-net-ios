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
//  RMBTTOSViewController.swift
//  RMBT
//
//  Created by Benjamin Pucher on 22.09.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
class RMBTTOSViewController : UIViewController, UIWebViewDelegate {
    
    ///
    @IBOutlet private var webView: UIWebView!
    
    ///
    @IBOutlet private var acceptIntroLabel: UILabel!
    
    //
    
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        acceptIntroLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let titleLabel = UILabel(frame: CGRectMake(0, 0, 300, 44))
        
        titleLabel.textAlignment = .Center
        titleLabel.text = navigationItem.title
        titleLabel.font = UIFont.boldSystemFontOfSize(16.0)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.adjustsFontSizeToFitWidth = true
        
        navigationItem.titleView = titleLabel
        
        var i: UIEdgeInsets = webView.scrollView.scrollIndicatorInsets
        i.bottom = 88 // 2x44px for toolbars
        webView.scrollView.scrollIndicatorInsets = i
        
        i = self.webView.scrollView.contentInset
        i.bottom = 88
        webView.scrollView.contentInset = i
        
        let url: NSURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("terms_conditions_long", ofType: "html")!)! // !
        webView.loadRequest(NSURLRequest(URL: url))
    }
    
    /// Handle external links in a modal browser window
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let scheme: String = request.URL!.scheme! // !
        if (scheme == "file") {
            return true
        } else if (scheme == "mailto") {
            // TODO: Open compose dialog
            return false
        } else {
            presentModalBrowserWithURLString(request.URL!.absoluteString!) // !
            return false
        }
    }
    
    ///
    @IBAction func agree(sender: AnyObject) {
        RMBTTOS.sharedTOS.acceptCurrentVersion()
        //self.dismissViewControllerAnimated(true, completion: nil)
        performSegueWithIdentifier("show_publish_personal_data", sender: self)
    }
    
    ///
    @IBAction func decline(sender: AnyObject) {
        RMBTTOS.sharedTOS.declineCurrentVersion()
        
        // quit app
        exit(EXIT_SUCCESS)
    }
}
