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
//  QOSHTTPProxyTest.swift
//  RMBT
//
//  Created by Benjamin Pucher on 05.12.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
class QOSHTTPProxyTest : QOSTest {
    
    let PARAM_URL = "url"
    let PARAM_RANGE = "range"
    
    let PARAM_DOWNLOAD_TIMEOUT = "download_timeout"
    let PARAM_CONNECTION_TIMEOUT = "conn_timeout"
    
    //
    
    /// The download timeout in nano seconds of the http proxy test (optional) (provided by control server)
    var downloadTimeout: UInt64 = 10_000_000_000 // default download timeout value
    
    /// The connection timeout in nano seconds of the http proxy test (optional) (provided by control server)
    var connectionTimeout: UInt64 = 5_000_000_000 // default connection timeout value
    
    /// The url of the http proxy test (provided by control server)
    var url: String?
    
    /// The range of the http proxy test (optional) (provided by control server)
    var range: String?
    
    //
    
    ///
    override var description: String {
        return super.description + ", [downloadTimeout: \(downloadTimeout), connectionTimeout: \(connectionTimeout), url: \(url), range: \(range)]"
    }
    
    //
    
    ///
    override init(var testParameters: QOSTestParameters) {
        // url
        if let url = testParameters[PARAM_URL] as? String {
            // TODO: length check on url?
            self.url = url
        }
        
        // range
        if let range = testParameters[PARAM_RANGE] as? String {
            self.range = range
        }
        
        // downloadTimeout
        if let downloadTimeoutString = testParameters[PARAM_DOWNLOAD_TIMEOUT] as? NSString {
            let downloadTimeout = downloadTimeoutString.longLongValue
            if (downloadTimeout > 0) {
                self.downloadTimeout = UInt64(downloadTimeout)
            }
        }
        
        // connectionTimeout
        if let connectionTimeoutString = testParameters[PARAM_CONNECTION_TIMEOUT] as? NSString {
            let connectionTimeout = connectionTimeoutString.longLongValue
            if (connectionTimeout > 0) {
                self.connectionTimeout = UInt64(connectionTimeout)
            }
        }
        
        super.init(testParameters: testParameters)
        
        // set timeout
        self.timeout = max(downloadTimeout, connectionTimeout)
    }
    
    ///
    override func getType() -> QOSTestType! {
        return .HTTP_PROXY
    }
}
