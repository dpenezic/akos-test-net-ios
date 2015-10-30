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
//  QOSNonTransparentProxyTestExecutor.swift
//  RMBT
//
//  Created by Benjamin Pucher on 09.12.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
typealias NonTransparentProxyTestExecutor = QOSNonTransparentProxyTestExecutor<QOSNonTransparentProxyTest>

///
class QOSNonTransparentProxyTestExecutor<T : QOSNonTransparentProxyTest> : QOSTestExecutorClass<T>, NonOptionalGCDAsyncSocketDelegate {

    let RESULT_NONTRANSPARENT_PROXY_RESPONSE    = "nontransproxy_result_response"
    let RESULT_NONTRANSPARENT_PROXY_REQUEST     = "nontransproxy_objective_request"
    let RESULT_NONTRANSPARENT_PROXY_PORT        = "nontransproxy_objective_port"
    let RESULT_NONTRANSPARENT_PROXY_TIMEOUT     = "nontransproxy_objective_timeout"
    let RESULT_NONTRANSPARENT_PROXY_STATUS      = "nontransproxy_result"
    
    //
    
    let TAG_TASK_NTPTEST = 2001
    
    //
    
    let TAG_NTPTEST_REQUEST = -1
    
    ///
    private let socketQueue: dispatch_queue_t = dispatch_queue_create("com.specure.rmbt.qos.ntp.socketQueue", DISPATCH_QUEUE_CONCURRENT)
    
    ///
    private var socketDelegate: NonOptionalGCDAsyncSocketDelegateImpl!
    
    ///
    private var ntpTestSocket: GCDAsyncSocket!
    
    ///
    private var gotReply: Bool = false
    
    //
    
    ///
    override init(controlConnection: QOSControlConnection, delegateQueue: dispatch_queue_t, testObject: T, speedtestStartTime: UInt64) {
        super.init(controlConnection: controlConnection, delegateQueue: delegateQueue, testObject: testObject, speedtestStartTime: speedtestStartTime)
        
        self.socketDelegate = NonOptionalGCDAsyncSocketDelegateImpl(delegate: self)
    }
    
    ///
    override func startTest() {
        super.startTest()
        
        testResult.set(RESULT_NONTRANSPARENT_PROXY_TIMEOUT, number: testObject.timeout)
        testResult.set(RESULT_NONTRANSPARENT_PROXY_REQUEST, value: testObject.request?.stringByRemovingLastNewline())
    }
    
    ///
    override func endTest() {
        super.endTest()
        
//        if (ntpTestSocket != nil && ntpTestSocket.isConnected) {
//            // close socket
//            //ntpTestSocket.disconnectAfterReadingAndWriting()
//            ntpTestSocket.disconnect()
//        }
    }
    
    ///
    override func executeTest() {
        if let port = testObject.port {
            testResult.set(RESULT_NONTRANSPARENT_PROXY_PORT, number: port)
        
            qosLog.debug("EXECUTING NON TRANSPARENT PROXY TEST")
            qosLog.debug("will send \(testObject.request) to the server")
            
            // request NTPTEST
            controlConnection.sendTaskCommand("NTPTEST \(port)", withTimeout: timeoutInSec, forTaskId: testObject.qosTestId, tag: TAG_TASK_NTPTEST)
        }
    }
    
    ///
    override func testDidSucceed() {
        testResult.set(RESULT_NONTRANSPARENT_PROXY_STATUS, value: "OK")
        
        super.testDidSucceed()
    }
    
    ///
    override func testDidTimeout() {
        testResult.set(RESULT_NONTRANSPARENT_PROXY_STATUS, value: "TIMEOUT")
        
        super.testDidTimeout()
    }
    
    ///
    override func testDidFail() {
        qosLog.debug("NTP: TEST DID FAIL")
        
        testResult.set(RESULT_NONTRANSPARENT_PROXY_RESPONSE, value: "")
        testResult.set(RESULT_NONTRANSPARENT_PROXY_STATUS, value: "ERROR")
        
        super.testDidFail()
    }
    
// MARK: QOSControlConnectionDelegate methods
    
    override func controlConnection(connection: QOSControlConnection, didReceiveTaskResponse response: String, withTaskId taskId: UInt, tag: Int) {
        qosLog.debug("CONTROL CONNECTION DELEGATE FOR TASK ID \(taskId), WITH TAG \(tag), WITH STRING \(response)")
        
        switch tag {
        case TAG_TASK_NTPTEST:
            qosLog.debug("NTPTEST response: \(response)")
            
            if (response.hasPrefix("OK")) {
                
                // create client socket
                ntpTestSocket = GCDAsyncSocket(delegate: socketDelegate, delegateQueue: delegateQueue, socketQueue: socketQueue)
            
                // connect client socket
                var error: NSError?
                if (!ntpTestSocket.connectToHost(testObject.serverAddress, onPort: testObject.port!, withTimeout: timeoutInSec, error: &error)) {
                    // there was an error
                    qosLog.debug("connection error \(error!)")
                    
                    return testDidFail()
                }
            }
            
        default:
            // do nothing
            qosLog.debug("default case: do nothing")
        }
    }
    
    ///
    /*override func controlConnection(connection: QOSControlConnection, didReceiveTimeout elapsed: NSTimeInterval, withTaskId taskId: UInt, tag: Int) {
        // let test fail/timeout
    }*/
    
// MARK: GCDAsyncSocketDelegate methods
    
    ///
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        if (sock == ntpTestSocket) {
            // write request message and read response
            SocketUtils.writeLine(ntpTestSocket, line: testObject.request!, withTimeout: timeoutInSec, tag: TAG_NTPTEST_REQUEST) // TODO: what if request is nil?
            SocketUtils.readLine(ntpTestSocket, tag: TAG_NTPTEST_REQUEST, withTimeout: timeoutInSec)
        }
    }
    
    ///
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        if (sock == ntpTestSocket) {
            switch tag {
            case TAG_NTPTEST_REQUEST:
                
                gotReply = true

                if let response = SocketUtils.parseResponseToString(data) {
                    qosLog.debug("response: \(response)")
                    
                    testResult.set(RESULT_NONTRANSPARENT_PROXY_RESPONSE, value: response.stringByRemovingLastNewline())
                    
                    testDidSucceed()
                } else {
                    logger.debug("NO RESP")
                    testDidFail()
                }
                
            default:
                // do nothing
                qosLog.debug("do nothing")
            }
        }
    }
    
    ///
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        //if (err != nil && err.code == GCDAsyncSocketConnectTimeoutError) { //check for timeout
        //    return testDidTimeout()
        //}
        qosLog.debug("DID DISC gotreply (before?): \(gotReply), error: \(err)")
        if (!gotReply) {
            testDidFail()
        }
    }
    
    ///
    func socket(sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        // unused
    }
}
