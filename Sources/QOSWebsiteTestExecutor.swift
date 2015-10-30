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
//  QOSWebsiteTestExecutor.swift
//  RMBT
//
//  Created by Benjamin Pucher on 20.01.15.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
typealias WebsiteTestExecutor = QOSWebsiteTestExecutor<QOSWebsiteTest>

///
class QOSWebsiteTestExecutor<T : QOSWebsiteTest> : QOSTestExecutorClass<T> {

    let RESULT_WEBSITE_URL      = "website_objective_url"
    let RESULT_WEBSITE_TIMEOUT  = "website_objective_timeout"
    let RESULT_WEBSITE_DURATION = "website_result_duration"
    let RESULT_WEBSITE_STATUS   = "website_result_status"
    let RESULT_WEBSITE_INFO     = "website_result_info"
    let RESULT_WEBSITE_RX_BYTES = "website_result_rx_bytes"
    let RESULT_WEBSITE_TX_BYTES = "website_result_tx_bytes"
    
    //
    
    ///
    //private var webView: UIWebView?
    
    private let webViewDelegate = WebViewDelegate()
    
    private var requestStartTimeTicks: UInt64 = 0
    
    //
    
    ///
    override init(controlConnection: QOSControlConnection, delegateQueue: dispatch_queue_t, testObject: T, speedtestStartTime: UInt64) {
        super.init(controlConnection: controlConnection, delegateQueue: delegateQueue, testObject: testObject, speedtestStartTime: speedtestStartTime)
    }
    
    ///
    override func startTest() {
        super.startTest()
        
        testResult.set(RESULT_WEBSITE_URL, value: testObject.url)
        testResult.set(RESULT_WEBSITE_TIMEOUT, number: testObject.timeout)
    }
    
    ///
    override func executeTest() {
        
        if let url = testObject.url {
        
            qosLog.debug("EXECUTING WEBSITE TEST")
            
            /*dispatch_async(dispatch_get_main_queue()) {
                let webView = UIWebView()
                webView.delegate = self.webViewDelegate
                
                let request: NSURLRequest = NSURLRequest(URL: NSURL(string: "https://www.alladin.at")!)
                
                webView.loadRequest(request)
                
                logger.debug("AFTER LOAD REQUEST")
            }*/
        }
    }
    
    ///
    override func needsControlConnection() -> Bool {
        return false
    }
    
// MARK: UIWebViewDelegate methods

    /*func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        logger.debug("WEB VIEW DID START LOAD")
        
        requestStartTimeTicks = getCurrentTimeTicks()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        logger.debug("WEB VIEW DID FINISH LOAD")
        
        let durationInNanoseconds = getTimeDifferenceInNanoSeconds(self.requestStartTimeTicks)
        self.testResult.resultDictionary[self.RESULT_WEBSITE_DURATION] = NSNumber(unsignedLongLong: durationInNanoseconds)
        
        self.callFinishCallback()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        logger.debug("WEB VIEW DID FAIL LOAD, \(error)")
    }*/
    
// MARK: other methods
    
}
