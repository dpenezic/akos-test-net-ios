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
//  QOSHTTPProxyTestExecutor.swift
//  RMBT
//
//  Created by Benjamin Pucher on 19.01.15.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
typealias HTTPProxyTestExecutor = QOSHTTPProxyTestExecutor<QOSHTTPProxyTest>

///
class QOSHTTPProxyTestExecutor<T : QOSHTTPProxyTest> : QOSTestExecutorClass<T> {

    let RESULT_HTTP_PROXY_STATUS    = "http_result_status"
    let RESULT_HTTP_PROXY_DURATION  = "http_result_duration"
    let RESULT_HTTP_PROXY_LENGTH    = "http_result_length"
    let RESULT_HTTP_PROXY_HEADER    = "http_result_header"
    let RESULT_HTTP_PROXY_RANGE     = "http_objective_range"
    let RESULT_HTTP_PROXY_URL       = "http_objective_url"
    let RESULT_HTTP_PROXY_HASH      = "http_result_hash"
    
    //
    
    ///
    private var requestStartTimeTicks: UInt64 = 0
    
    //
    
    ///
    override init(controlConnection: QOSControlConnection, delegateQueue: dispatch_queue_t, testObject: T, speedtestStartTime: UInt64) {
        super.init(controlConnection: controlConnection, delegateQueue: delegateQueue, testObject: testObject, speedtestStartTime: speedtestStartTime)
    }
    
    ///
    override func startTest() {
        super.startTest()
        
        testResult.set(RESULT_HTTP_PROXY_RANGE, value: testObject.range)
        testResult.set(RESULT_HTTP_PROXY_URL, value: testObject.url)
        testResult.set(RESULT_HTTP_PROXY_DURATION, value: -1)
    }
    
    ///
    override func executeTest() {
        
        // TODO: check testObject.url
        if let url = testObject.url {
        
            qosLog.debug("EXECUTING HTTP PROXY TEST")
            
            let manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
            
            // add range header if it exists
            if let range = testObject.range {
                manager.requestSerializer.setValue(range, forHTTPHeaderField: "Range")
            }
            
            // set timeout (timeoutInterval is in seconds)
            manager.requestSerializer.timeoutInterval = nsToSec(testObject.downloadTimeout) // TODO: is this the correct timeout?
            
            // add text/html to the accepted content types
            //manager.responseSerializer.acceptableContentTypes = manager.responseSerializer.acceptableContentTypes.setByAddingObject("text/html")
            manager.responseSerializer = AFHTTPResponseSerializer()
            
            // generate url request
            var error: NSError?
            let request: NSMutableURLRequest = manager.requestSerializer.requestWithMethod("GET", URLString: url, parameters: [:], error: &error)

            // check error (TODO: check more...)
            if let err = error {
                return testDidFail()
            }
            
            // set request timeout
            request.timeoutInterval = nsToSec(testObject.connectionTimeout) // TODO: is this the correct timeout?
            
            // create request operation
            let requestOperation = manager.HTTPRequestOperationWithRequest(request, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                
                self.qosLog.debug("GET SUCCESS")
                
                // compute duration
                let durationInNanoseconds = getTimeDifferenceInNanoSeconds(self.requestStartTimeTicks)
                self.testResult.set(self.RESULT_HTTP_PROXY_DURATION, number: durationInNanoseconds)
                
                // set other result values
                self.testResult.set(self.RESULT_HTTP_PROXY_STATUS, value: operation.response.statusCode)
                self.testResult.set(self.RESULT_HTTP_PROXY_LENGTH, number: operation.response.expectedContentLength)
                
                // compute md5
                if let r = responseObject as? NSData {
                    self.qosLog.debug("ITS NSDATA!")
                    
                    self.testResult.set(self.RESULT_HTTP_PROXY_HASH, value: r.MD5().hexString()) // TODO: improve
                }
                
                // loop through headers
                var headerString: String = ""
                for (headerName, headerValue) in operation.response.allHeaderFields {
                    headerString += "\(headerName): \(headerValue)\n"
                }
                
                self.testResult.set(self.RESULT_HTTP_PROXY_HEADER, value: headerString)
                
                ///
                self.testDidSucceed()
                ///
                
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                    
                self.qosLog.debug("GET FAILURE")
                self.qosLog.debug("\(error.description)")
                
                if (error != nil && error.code == NSURLErrorTimedOut) {
                    // timeout
                    self.testDidTimeout()
                } else {
                    self.testDidFail()
                }
            })
            
            // prevent redirect
            requestOperation.setRedirectResponseBlock { (connection: NSURLConnection!, request: NSURLRequest!, redirectResponse: NSURLResponse!) -> NSURLRequest! in
                if (redirectResponse == nil) {
                    return request
                } else {
                    requestOperation.cancel()
                    self.qosLog.debug("prevented redirect from \(request.URL!.absoluteString) to \(redirectResponse.URL!.absoluteString)")
                    return nil
                }
            }
            
            // set start time
            requestStartTimeTicks = getCurrentTimeTicks()
            
            // execute get
            manager.operationQueue.addOperation(requestOperation)
        }
    }
    
    ///
    override func testDidTimeout() {
        testResult.set(RESULT_HTTP_PROXY_HASH, value: "TIMEOUT")
        
        testResult.set(RESULT_HTTP_PROXY_STATUS, value: "")
        testResult.set(RESULT_HTTP_PROXY_LENGTH, value: 0)
        testResult.set(RESULT_HTTP_PROXY_HEADER, value: "")
        
        super.testDidTimeout()
    }
    
    ///
    override func testDidFail() {
        testResult.set(RESULT_HTTP_PROXY_HASH, value: "ERROR")
        
        testResult.set(RESULT_HTTP_PROXY_STATUS, value: "")
        testResult.set(RESULT_HTTP_PROXY_LENGTH, value: 0)
        testResult.set(RESULT_HTTP_PROXY_HEADER, value: "")
        
        super.testDidFail()
    }
    
    ///
    override func needsControlConnection() -> Bool {
        return false
    }
}
