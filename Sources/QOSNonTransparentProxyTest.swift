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
//  QOSNonTransparentProxyTest.swift
//  RMBT
//
//  Created by Benjamin Pucher on 05.12.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
class QOSNonTransparentProxyTest : QOSTest {
    
    let PARAM_REQUEST = "request"
    let PARAM_PORT = "port"
    
    //
    
    /// The request string to use by the non-transparent proxy test (provided by control server)
    var request: String?
    
    /// The port to test by the non-transparent proxy test (provided by control server)
    var port: UInt16?
    
    //
    
    ///
    override var description: String {
        return super.description + ", [request: \(request), port: \(port)]"
    }
    
    //
    
    ///
    override init(testParameters: QOSTestParameters) {
        // request
        if let request = testParameters[PARAM_REQUEST] as? String {
            // TODO: length check on request?
            self.request = request
            
            // append newline character if not already added
            if (!self.request!.hasSuffix("\n")) {
                self.request! += "\n"
            }
        }
        
        // port
        if let portString = testParameters[PARAM_PORT] as? String {
            if let port = portString.toInt() {
                self.port = UInt16(port)
            }
        }
        
        super.init(testParameters: testParameters)
    }
    
    ///
    override func getType() -> QOSTestType! {
        return .NON_TRANSPARENT_PROXY
    }
}