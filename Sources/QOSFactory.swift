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
//  QOSFactory.swift
//  RMBT
//
//  Created by Benjamin Pucher on 11.02.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import Foundation

///
class QOSFactory {
    
    ///
    private init() {
    
    }
    
    ///
    class func createQOSTest(typeString: String, params: QOSTestParameters) -> QOSTest? {
        if let type = getTypeIfEnabled(QOSTestType(rawValue: typeString)) {
        
            switch (type) {
                case .TCP:
                    return QOSTCPTest(testParameters: params)
                    
                case .NON_TRANSPARENT_PROXY:
                    return QOSNonTransparentProxyTest(testParameters: params)
                
                case .HTTP_PROXY:
                    return QOSHTTPProxyTest(testParameters: params)
                
                case .WEBSITE:
                    return QOSWebsiteTest(testParameters: params)
                
                case .DNS:
                    return QOSDNSTest(testParameters: params)
                
                case .UDP:
                    return QOSUDPTest(testParameters: params)
                
                case .VOIP:
                    return QOSVOIPTest(testParameters: params)
                
                case .TRACEROUTE:
                    return QOSTracerouteTest(testParameters: params)
                
                default:
                    return nil
            }
        }
        
        return nil
    }
    
    ///
    class func createTestExecutor(testObject: QOSTest, controlConnection: QOSControlConnection, delegateQueue: dispatch_queue_t, speedtestStartTime: UInt64) -> QOSTestExecutorProtocol? {
        if let type = getTypeIfEnabled(testObject.getType()) {
        
            switch (type) {
                case .TCP:
                    return TCPTestExecutor(
                        controlConnection: controlConnection,
                        delegateQueue: delegateQueue,
                        testObject: testObject as! QOSTCPTest,
                        speedtestStartTime: speedtestStartTime
                    )
                    
                case .NON_TRANSPARENT_PROXY:
                    return NonTransparentProxyTestExecutor(
                        controlConnection: controlConnection,
                        delegateQueue: delegateQueue,
                        testObject: testObject as! QOSNonTransparentProxyTest,
                        speedtestStartTime: speedtestStartTime
                    )
                    
                case .HTTP_PROXY:
                    return HTTPProxyTestExecutor(
                        controlConnection: controlConnection,
                        delegateQueue: delegateQueue,
                        testObject: testObject as! QOSHTTPProxyTest,
                        speedtestStartTime: speedtestStartTime
                    )
                    
                case .WEBSITE:
                    return WebsiteTestExecutor(
                        controlConnection: controlConnection,
                        delegateQueue: delegateQueue,
                        testObject: testObject as! QOSWebsiteTest,
                        speedtestStartTime: speedtestStartTime
                    )
                
                case .DNS:
                    return DNSTestExecutor(
                        controlConnection: controlConnection,
                        delegateQueue: delegateQueue,
                        testObject: testObject as! QOSDNSTest,
                        speedtestStartTime: speedtestStartTime
                    )
                    
                case .UDP:
                    return UDPTestExecutor(
                        controlConnection: controlConnection,
                        delegateQueue: delegateQueue,
                        testObject: testObject as! QOSUDPTest,
                        speedtestStartTime: speedtestStartTime
                    )
                    
                case .VOIP:
                    return VOIPTestExecutor(
                        controlConnection: controlConnection,
                        delegateQueue: delegateQueue,
                        testObject: testObject as! QOSVOIPTest,
                        speedtestStartTime: speedtestStartTime
                    )
                    
                case .TRACEROUTE:
                    return TracerouteTestExecutor(
                        controlConnection: controlConnection,
                        delegateQueue: delegateQueue,
                        testObject: testObject as! QOSTracerouteTest,
                        speedtestStartTime: speedtestStartTime
                    )
                    
                default:
                    return nil
            }
        }
        
        return nil
    }
    
    ///
    private class func getTypeIfEnabled(type: QOSTestType?) -> QOSTestType? {
        if (type != nil && !isEnabled(type!)) {
            return nil
        }
        
        return type
    }
    
    ///
    private class func isEnabled(type: QOSTestType) -> Bool {
        return contains(QOS_ENABLED_TESTS, type)
    }
}
