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
//  QOSControlConnection.swift
//  RMBT
//
//  Created by Benjamin Pucher on 09.12.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

@objc class QOSControlConnection : NSObject { // extends NSObject because otherwise delegate for GCDAsyncSocket would not work
    
    let TAG_GREETING = -1
    let TAG_FIRST_ACCEPT = -2
    let TAG_TOKEN = -3
    //let TAG_OK = -4
    let TAG_SECOND_ACCEPT = -4
    
    let TAG_SET_TIMEOUT = -10
    
    let TAG_TASK_COMMAND = -100
    
    //
    
    ///
    var delegate: QOSControlConnectionDelegate?
    
    ///
    var connected: Bool = false
    
    ///
    private let testToken: String
    
    ///
    private let connectCountDownLatch = CountDownLatch()
    
    ///
    private var socketDelegate: GCDAsyncSocketDelegate! // workaround for swift-delegate-arc problem, see http://stackoverflow.com/questions/24824753/delegate-not-getting-set
    
    ///
    private let socketQueue = dispatch_queue_create("com.specure.rmbt.controlConnectionSocketQueue", DISPATCH_QUEUE_CONCURRENT)
    
    ///
    private var qosControlConnectionSocket: GCDAsyncSocket!
    
    ///
    private var taskDelegateDictionary = [UInt:QOSControlConnectionTaskDelegate]()
    
    ///
    private var pendingTimeout: Double = 0
    private var currentTimeout: Double = 0
    
    //
    
    ///
    init(testToken: String) {
        self.testToken = testToken
        
        super.init()
        socketDelegate = self // assigns self to socketDelegate for swift-delegate-arc workaround
        
        // create socket
        qosControlConnectionSocket = GCDAsyncSocket(delegate: socketDelegate, delegateQueue: socketQueue) // TODO: specify other dispath queue
        
        logger.verbose("control connection created")
    }

// MARK: connection handling
    
    ///
    func connect(host: String, onPort port: UInt16) -> Bool {
        return connect(host, onPort: port, withTimeout: QOS_CONTROL_CONNECTION_TIMEOUT_NS)
    }
    
    ///
    func connect(host: String, onPort port: UInt16, withTimeout timeout: UInt64) -> Bool {
        let connectTimeout = nsToSec(timeout)
    
        var error: NSError?
    
        if (!self.qosControlConnectionSocket.connectToHost(host, onPort: port, withTimeout: connectTimeout, error: &error)) {
            // there was an error
            logger./*debug*/verbose("connection error \(error!)")
        }
        
        connectCountDownLatch.await(timeout)
        
        return connected
    }
    
    ///
    func disconnect() {
        // send quit
        logger.debug("QUIT QUIT QUIT QUIT QUIT")
        
        writeLine("QUIT", withTimeout: QOS_CONTROL_CONNECTION_TIMEOUT_SEC, tag: -1) // don't bother with the tag, don't need read after this operation
        qosControlConnectionSocket.disconnectAfterWriting()
        //qosControlConnectionSocket.disconnectAfterReadingAndWriting()
    }
    
// MARK: commands
    
    ///
    func setTimeout(timeout: UInt64) {
        //logger.debug("SET TIMEOUT: \(timeout)")
        
        // timeout is in nanoseconds -> convert to ms
        var msTimeout = nsToMs(timeout)
        
        // if msTimeout is lower than 15 seconds, increase it
        if (msTimeout < 15_000) {
            msTimeout = 15_000
        }
        
        if (currentTimeout == msTimeout) {
            logger.debug("skipping change of control connection timeout because old value = new value")
            return // skip if old == new timeout
        }
        
        pendingTimeout = msTimeout
        
        //logger.debug("REQUEST CONN TIMEOUT \(msTimeout)")
        writeLine("REQUEST CONN TIMEOUT \(msTimeout)", withTimeout: QOS_CONTROL_CONNECTION_TIMEOUT_SEC, tag: TAG_SET_TIMEOUT)
        readLine(TAG_SET_TIMEOUT, withTimeout: QOS_CONTROL_CONNECTION_TIMEOUT_SEC)
    }
    
// MARK: control connection delegate methods
    
    ///
    func registerTaskDelegate(delegate: QOSControlConnectionTaskDelegate, forTaskId taskId: UInt) {
        taskDelegateDictionary[taskId] = delegate
        logger.debug("registerTaskDelegate: \(taskId), delegate: \(delegate)")
    }
    
    ///
    func unregisterTaskDelegate(forTaskId taskId: UInt) {
        taskDelegateDictionary.removeValueForKey(taskId)
        //taskDelegateDictionary[taskId] = nil
    }
    
// MARK: task command methods
    
    // TODO: use closure instead of delegate methods
    /// command should not contain \n, will be added inside this method
    func sendTaskCommand(command: String, withTimeout timeout: NSTimeInterval, forTaskId taskId: UInt, tag: Int) {
        /*if (!qosControlConnectionSocket.isConnected) {
            logger.error("control connection is closed, sendTaskCommand won't work!")
        }*/
    
        let _command = command + " +ID\(taskId)"
        
        var t = createTaskCommandTag(forTaskId: taskId, tag: tag)
        
        // write command
        writeLine(_command, withTimeout: timeout, tag: t)
        
        // and then read? // TODO: or use thread with looped readLine?
        readLine(t, withTimeout: timeout)
    }
    
    /// command should not contain \n, will be added inside this method
    func sendTaskCommand(command: String, withTimeout timeout: NSTimeInterval, forTaskId taskId: UInt) {
        sendTaskCommand(command, withTimeout: timeout, forTaskId: taskId, tag: TAG_TASK_COMMAND)
    }
    
// MARK: convenience methods
    
    ///
    private func writeLine(line: String, withTimeout timeout: NSTimeInterval, tag: Int) {
        SocketUtils.writeLine(qosControlConnectionSocket, line: line, withTimeout: timeout, tag: tag)
    }
    
    ///
    private func readLine(tag: Int, withTimeout timeout: NSTimeInterval) {
        SocketUtils.readLine(qosControlConnectionSocket, tag: tag, withTimeout: timeout)
    }
    
// MARK: other methods
    
    ///
    private func createTaskCommandTag(forTaskId taskId: UInt, tag: Int) -> /*UInt32*/Int {
        // bitfield: 0111|aaaa_aaaa_aaaa|bbbb_bbbb_bbbb_bbbb
        
        var bitfield: UInt32 = 0x7
        
        bitfield = bitfield << 12
        
        bitfield = bitfield + (UInt32(abs(tag)) & 0x0000_0FFF)
        
        bitfield = bitfield << 16
        
        bitfield = bitfield + (UInt32(taskId) & 0x0000_FFFF)
        
        return Int(bitfield)
    }
    
    ///
    private func parseTaskCommandTag(taskCommandTag commandTag: Int) -> (taskId: UInt, tag: Int)? {
        let _commandTag = UInt(commandTag)
        
        if (!isTaskCommandTag(taskCommandTag: commandTag)) {
            return nil // not a valid task command tag
        }
        
        let taskId: UInt = (_commandTag & 0x0000_FFFF)
        let tag = Int((_commandTag & 0x0FFF_0000) >> 16)
        
        return (taskId, tag)
    }
    
    ///
    private func isTaskCommandTag(taskCommandTag commandTag: Int) -> Bool {
        return UInt(commandTag) & 0x7000_0000 == 0x7000_0000
    }
    
    ///
    private func matchAndGetTestIdFromResponse(response: String) -> UInt? {
        var error: NSError? // TODO: check
        
        var regularExpression: NSRegularExpression? = NSRegularExpression(pattern: "\\+ID(\\d*)", options: nil, error: &error)
        
        if let regex = regularExpression {
            
            if let match = regex.firstMatchInString(response, options: nil, range: NSMakeRange(0, count(response))) {
                //println(match)
                
                if (match.numberOfRanges > 0) {
                    let idStr = (response as NSString).substringWithRange(match.rangeAtIndex(1))

                    //return UInt(idStr.toInt()) // does not work because of Int?
                    if let u = idStr.toInt() {
                        return UInt(u)
                    }
                }
            }
        }
        
        return nil
    }
}

// MARK: GCDAsyncSocketDelegate methods

///
extension QOSControlConnection : GCDAsyncSocketDelegate {
    
    ///
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        logger.verbose("connected to host \(host) on port \(port)")
        
        // control connection to qos server uses tls
        sock.startTLS(QOS_TLS_SETTINGS as [NSObject : AnyObject])
    }
    
    func socket(sock: GCDAsyncSocket!, didReceiveTrust trust: SecTrustRef, completionHandler: Bool -> ()) {
        logger.verbose("DID RECEIVE TRUST")
        completionHandler(true)
    }
    
    ///
    func socketDidSecure(sock: GCDAsyncSocket!) {
        logger.verbose("socketDidSecure")
        
        // tls connection has been established, start with QTP handshake
        readLine(TAG_GREETING, withTimeout: QOS_CONTROL_CONNECTION_TIMEOUT_SEC)
    }
    
    ///
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        logger.verbose("didReadData \(data) with tag \(tag)")
        
        let str: String = SocketUtils.parseResponseToString(data)!
        
        logger.verbose("didReadData \(str)")
        
        switch tag {
        case TAG_GREETING:
            // got greeting
            logger.verbose("got greeting")
            
            // read accept
            readLine(TAG_FIRST_ACCEPT, withTimeout: QOS_CONTROL_CONNECTION_TIMEOUT_SEC)
            
        case TAG_FIRST_ACCEPT:
            // got accept
            logger.verbose("got accept")
            
            // send token
            let tokenCommand = "TOKEN \(testToken)\n"
            writeLine(tokenCommand, withTimeout: QOS_CONTROL_CONNECTION_TIMEOUT_SEC, tag: TAG_TOKEN)
            
            // read token response
            readLine(TAG_TOKEN, withTimeout: QOS_CONTROL_CONNECTION_TIMEOUT_SEC)
            
        case TAG_TOKEN:
            // response from token command
            logger.verbose("got ok")
            
            // read second accept
            readLine(TAG_SECOND_ACCEPT, withTimeout: QOS_CONTROL_CONNECTION_TIMEOUT_SEC)
            
        case TAG_SECOND_ACCEPT:
            // got second accept
            logger.verbose("got second accept")
            
            // now connection is ready
            logger.verbose("CONNECTION READY")
            
            connected = true // set connected to true to unlock
            connectCountDownLatch.countDown()
            
            // call delegate method // TODO: on which queue?
            self.delegate?.controlConnectionReadyToUse(self)
            
            //
        case TAG_SET_TIMEOUT:
            // return from REQUEST CONN TIMEOUT
            if (str == "OK\n") {
                logger.debug("set timeout ok")
                
                currentTimeout = pendingTimeout
                
                // OK
            } else {
                logger.debug("set timeout fail \(str)")
                // FAIL
            }
            
        default:
            //case TAG_TASK_COMMAND:
            // got reply from task command
            
            if (isTaskCommandTag(taskCommandTag: tag)) {
                if let (taskId, _tag) = parseTaskCommandTag(taskCommandTag: tag) {
                
                    logger.verbose("got reply from task command")
                    logger.verbose("taskId: \(taskId), _tag: \(_tag)")
                    
                    
                    if let taskId = matchAndGetTestIdFromResponse(str) {
                        logger.verbose("TASK ID: \(taskId)")
                        
                        //logger.verbose("\(taskDelegateDictionary.count)")
                        //logger.verbose("\(taskDelegateDictionary.indexForKey(1))")
                        
                        if let taskDelegate = taskDelegateDictionary[taskId] {
                            logger.verbose("TASK DELEGATE: \(taskDelegate)")
                            
                            // call delegate method // TODO: dispatch delegate methods with dispatch queue of delegate
                            taskDelegate.controlConnection(self, didReceiveTaskResponse: str, withTaskId: taskId, tag: _tag)
                        }
                    }
                }
            }
        }
    }
    
    ///
    func socket(sock: GCDAsyncSocket!, didReadPartialDataOfLength partialLength: UInt, tag: Int) {
        logger.verbose("didReadPartialDataOfLength \(partialLength), tag: \(tag)")
    }
    
    ///
    func socket(sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        logger.verbose("didWriteDataWithTag \(tag)")
    }
    
    ///
    func socket(sock: GCDAsyncSocket!, didWritePartialDataOfLength partialLength: UInt, tag: Int) {
        logger.verbose("didWritePartialDataOfLength \(partialLength), tag: \(tag)")
    }
    
    ///
    func socket(sock: GCDAsyncSocket!, shouldTimeoutReadWithTag tag: Int, elapsed: NSTimeInterval, bytesDone length: UInt) -> NSTimeInterval {
        logger.verbose("shouldTimeoutReadWithTag \(tag), elapsed: \(elapsed), bytesDone: \(length)")
        
        //if (tag < TAG_TASK_COMMAND) {
        if (isTaskCommandTag(taskCommandTag: tag)) {
            //let taskId = UInt(-tag + TAG_TASK_COMMAND)
            if let (taskId, _tag) = parseTaskCommandTag(taskCommandTag: tag) {
            
                logger.verbose("TASK ID: \(taskId)")
                
                if let taskDelegate = taskDelegateDictionary[taskId] {
                    logger.verbose("TASK DELEGATE: \(taskDelegate)")
                    
                    // call delegate method // TODO: dispatch delegate methods with dispatch queue of delegate
                    taskDelegate.controlConnection(self, didReceiveTimeout: elapsed, withTaskId: taskId, tag: _tag)
                    logger.debug("!!! AFTER DID_RECEIVE_TIMEOUT !!!!")
                }
            }
        }
        
        //return -1 // always let this timeout
        return 10000 // extend timeout ... because of the weird timeout handling of GCDAsyncSocket (socket would close)
    }
    
    ///
    func socket(sock: GCDAsyncSocket!, shouldTimeoutWriteWithTag tag: Int, elapsed: NSTimeInterval, bytesDone length: UInt) -> NSTimeInterval {
        logger.verbose("shouldTimeoutReadWithTag \(tag), elapsed: \(elapsed), bytesDone: \(length)")
        
        //if (tag < TAG_TASK_COMMAND) {
        if (isTaskCommandTag(taskCommandTag: tag)) {
            //let taskId = UInt(-tag + TAG_TASK_COMMAND)
            if let (taskId, _tag) = parseTaskCommandTag(taskCommandTag: tag) {
                
                logger.verbose("TASK ID: \(taskId)")
                
                if let taskDelegate = taskDelegateDictionary[taskId] {
                    logger.verbose("TASK DELEGATE: \(taskDelegate)")
                    
                    // call delegate method // TODO: dispatch delegate methods with dispatch queue of delegate
                    taskDelegate.controlConnection(self, didReceiveTimeout: elapsed, withTaskId: taskId, tag: _tag)
                }
            }
        }
        
        //return -1 // always let this timeout
        return 10000 // extend timeout ... because of the weird timeout handling of GCDAsyncSocket (socket would close)
    }
    
    ///
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        if (err == nil) {
            logger.debug("QOS CC: socket closed by server after sending QUIT")
            return // if the server closed the connection error is nil (this happens after sending QUIT to the server)
        }
        
        logger.debug("QOS CC: disconnected with error \(err)")
    }
}
