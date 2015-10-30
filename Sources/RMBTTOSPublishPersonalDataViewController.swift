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
//  RMBTTOSPublishPersonalDataViewController
//  RMBT
//
//  Created by Benjamin Pucher on 18.08.15.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
class RMBTTOSPublishPersonalDataViewController : UIViewController, UIWebViewDelegate {
    
    ///
    @IBOutlet private var webView: UIWebView!
    
    ///
    @IBOutlet private var publishPublicDataSwitch: UISwitch!
    
    //
    
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        publishPublicDataSwitch.on = RMBTSettings.sharedSettings().publishPublicData
        
        let url: NSURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("publish_personal_data_text", ofType: "html")!)! // !
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
    @IBAction func doContinue(sender: AnyObject) {
        RMBTSettings.sharedSettings().publishPublicData = publishPublicDataSwitch.on
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
