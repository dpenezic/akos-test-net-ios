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
//  UIViewController+ModalBrowser.swift
//  RMBT
//
//  Created by Benjamin Pucher on 19.09.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
protocol ModalBrowser {

    ///
    func presentModalBrowserWithURLString(url: String)
}

///
extension UIViewController : ModalBrowser {
   
    ///
    func presentModalBrowserWithURLString(url: String) {
        let webViewController = KINWebBrowserViewController.navigationControllerWithWebBrowser()
        
        presentViewController(webViewController, animated: true, completion: nil)
        
        let webBrowser = webViewController.rootWebBrowser()
        
        //webBrowser.tintColor = RMBT_DARK_COLOR //RMBT_TINT_COLOR
        //webBrowser.barTintColor = RMBT_DARK_COLOR //RMBT_TINT_COLOR
        
        webBrowser.loadURLString(RMBTLocalizeURLString(url))
    }
}
