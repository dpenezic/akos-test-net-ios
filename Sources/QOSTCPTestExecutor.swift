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
//  QOSTCPTestExecutor.swift
//  RMBT
//
//  Created by Benjamin Pucher on 09.12.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
typealias TCPTestExecutor = QOSTCPTestExecutor<QOSTCPTest>

///
class QOSTCPTestExecutor<T : QOSTCPTest> : QOSTestExecutorClass<T>, NonOptionalGCDAsyncSocketDelegate /*swift compiler segfault if moved to extension*/ {

    let RESULT_TCP_PORT_OUT     = "tcp_objective_out_port" // class let... class variables not yet supported
    let RESULT_TCP_PORT_IN      = "tcp_objective_in_port"
    let RESULT_TCP_TIMEOUT      = "tcp_objective_timeout"
    let RESULT_TCP_OUT          = "tcp_result_out"
    let RESULT_TCP_IN           = "tcp_result_in"
    let RESULT_TCP_RESPONSE_OUT = "tcp_result_out_response"
    let RESULT_TCP_RESPONSE_IN  = "tcp_result_in_response"
    
    //
    
    let TAG_TASK_TCPTEST_OUT = 1001
    let TAG_TASK_TCPTEST_IN = 1002
    
    //
    
    let TAG_TCPTEST_OUT_PING = -1
    let TAG_TCPTEST_IN_PING = -2
    
    //
    
    ///
    private let socketQueue: dispatch_queue_t = dispatch_queue_create("com.specure.rmbt.tcp.socketQueue", DISPATCH_QUEUE_CONCURRENT)
    
    ///
    private var socketDelegate: NonOptionalGCDAsyncSocketDelegateImpl!
    
    ///
    private var tcpTestOutSocket: GCDAsyncSocket!
    
    ///
    private var tcpTestInSocket: GCDAsyncSocket!
    
    ///
    private var portOutFinished: Bool = false
    
    ///
    private var portInFinished: Bool = false
    
    //
    
    ///
    override init(controlConnection: QOSControlConnection, delegateQueue: dispatch_queue_t, testObject: T, speedtestStartTime: UInt64) {
        super.init(controlConnection: controlConnection, delegateQueue: delegateQueue, testObject: testObject, speedtestStartTime: speedtestStartTime)
        
        self.socketDelegate = NonOptionalGCDAsyncSocketDelegateImpl(delegate: self)
    }
    
    ///
    override func startTest() {
        super.startTest()
        
        testResult.set(RESULT_TCP_TIMEOUT, number: testObject.timeout)
    }
    
    ///
    override func endTest() {
        super.endTest()
        
//        if (tcpTestOutSocket != nil && tcpTestOutSocket.isConnected) {
//            tcpTestOutSocket.disconnect()
//        }
//        
//        if (tcpTestInSocket != nil && tcpTestInSocket.isConnected) {
//            tcpTestInSocket.disconnect()
//        }
    }
    
    ///
    override func executeTest() {
        qosLog.debug("EXECUTING TCP TEST")
        
        // port out test
        if let portOut = testObject.portOut {
            qosLog.debug("TCP TEST PORT OUT")
            
            testResult.set(RESULT_TCP_PORT_OUT, number: portOut) // put portOut in test result
            testResult.set(RESULT_TCP_OUT, value: "FAILED") // assume test failed if port was provided (don't have to set failed later, only have to success)
            
            // request tcp out test
            sendTaskCommand("TCPTEST OUT \(portOut)", withTimeout: timeoutInSec, tag: TAG_TASK_TCPTEST_OUT)
        }
    
        // port in test
        if let portIn = testObject.portIn {
            qosLog.debug("TCP TEST PORT IN")
            
            testResult.set(RESULT_TCP_PORT_IN, number: portIn) // put portIn in test result
            testResult.set(RESULT_TCP_IN, value: "FAILED") // assume test failed if port was provided (don't have to set failed later, only have to success)
        
            // request tcp in test
            sendTaskCommand("TCPTEST IN \(portIn)", withTimeout: timeoutInSec, tag: TAG_TASK_TCPTEST_IN)
        }
        
        // check if both params aren't set
        if (testObject.portOut == nil && testObject.portIn == nil) {
            testResult.set(RESULT_TCP_OUT, value: "NOT_SET")
            testResult.set(RESULT_TCP_IN, value: "NOT_SET")
            
            callFinishCallback()
        }
    }
    
    ///
    private func checkFinish() { // TODO: improve with something like CountDownLatch
        dispatch_async(delegateQueue) { // TODO: run in delegate queue!
            self.qosLog.debug("check finish")
            if (self.testObject.portOut != nil && !self.portOutFinished) {
                return
            }

            if (self.testObject.portIn != nil && !self.portInFinished) {
                return
            }
            
            //if (portOutFinished && portInFinished) { // TODO: use something like CountDownLatch...
                self.callFinishCallback()
            //}
        }
    }
    
// MARK: QOSControlConnectionDelegate methods
    
    ///
    override func controlConnection(connection: QOSControlConnection, didReceiveTaskResponse response: String, withTaskId taskId: UInt, tag: Int) {
        qosLog.debug("CONTROL CONNECTION DELEGATE FOR TASK ID \(taskId), WITH TAG \(tag), WITH STRING \(response)")
        
        switch tag {
            case TAG_TASK_TCPTEST_OUT:
                qosLog.debug("TCPTEST OUT response: \(response)")
                
                if (response.hasPrefix("OK")) {
                    
                    // create client socket
                    tcpTestOutSocket = GCDAsyncSocket(delegate: socketDelegate, delegateQueue: delegateQueue, socketQueue: socketQueue)
                    
                    // connect client socket
                    var error: NSError?
                    if (!tcpTestOutSocket.connectToHost(testObject.serverAddress, onPort: testObject.portOut!, withTimeout: timeoutInSec, error: &error)) {
                        // there was an error
                        qosLog.debug("connection error \(error!)")
                    }
                    
                    qosLog.debug("created tcpTestOutSocket")
                }
                
            case TAG_TASK_TCPTEST_IN:
                
                // create server socket
                tcpTestInSocket = GCDAsyncSocket(delegate: socketDelegate, delegateQueue: delegateQueue, socketQueue: socketQueue)
                
                var error: NSError?
                tcpTestInSocket.acceptOnPort(testObject.portIn!, error: &error) // TODO: check error (i.e. fail test if error)
                
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
    func socket(sock: GCDAsyncSocket!, didAcceptNewSocket newSocket: GCDAsyncSocket!) {
        if (sock == tcpTestInSocket) {
            // read line
            SocketUtils.readLine(newSocket, tag: TAG_TCPTEST_IN_PING, withTimeout: timeoutInSec)
        }
    }
    
    ///
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        qosLog.debug("DID CONNECT TO HOST \(host) on port \(port)")
        if (sock == tcpTestOutSocket) {
            // write "PING" and read response
            SocketUtils.writeLine(tcpTestOutSocket, line: "PING", withTimeout: timeoutInSec, tag: TAG_TCPTEST_OUT_PING)
            SocketUtils.readLine(tcpTestOutSocket, tag: TAG_TCPTEST_OUT_PING, withTimeout: timeoutInSec)
        }
    }
    
    ///
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        
        let response: String = SocketUtils.parseResponseToString(data)! // !?
        let responseWithoutLastNewline = response.stringByRemovingLastNewline()
        
        if (sock == tcpTestOutSocket) {
            switch tag {
            case TAG_TCPTEST_OUT_PING:
                qosLog.debug("ping reponse: \(response)")
         
                testResult.set(RESULT_TCP_RESPONSE_OUT, value: responseWithoutLastNewline)
                testResult.set(RESULT_TCP_OUT, value: "OK")
                
                // close socket
                //tcpTestOutSocket.disconnectAfterReadingAndWriting()
         
                qosLog.debug("TEST RESULT: \(testResult)")

                portOutFinished = true
                checkFinish()
                
            default:
                // do nothing
                qosLog.debug("do nothing")
            }
        } else {
            // should be newSocket // TODO: check!
            
            testResult.set(RESULT_TCP_RESPONSE_IN, value: responseWithoutLastNewline)
            testResult.set(RESULT_TCP_IN, value: "OK")
            
            // close socket
            //sock.disconnectAfterReadingAndWriting()
            
            portInFinished = true
            checkFinish()
        }
    }
    
    ///
    func socket(sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        // do nothing
    }
    
    ///
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        // do nothing
    }
}
