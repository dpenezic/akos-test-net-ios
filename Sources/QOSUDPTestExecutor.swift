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
//  QOSUDPTestExecutor.swift
//  RMBT
//
//  Created by Benjamin Pucher on 29.01.15.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
struct UDPPacketData {
    
    ///
    var remotePort: UInt16
    
    ///
    var numPackets: Int//UInt16
    
    ///
    var dupNumPackets: Int//UInt16
   
    ///
    var rcvServerResponse: Int = 0
    
    ///
    init() {
        self.init(remotePort: 0, numPackets: 0, dupNumPackets: 0)
    }
    
    ///
    init(remotePort: UInt16, numPackets: Int/*UInt16*/, dupNumPackets: Int/*UInt16*/) {
        self.remotePort = remotePort
        self.numPackets = numPackets
        self.dupNumPackets = dupNumPackets
    }
}

///
typealias UDPTestExecutor = QOSUDPTestExecutor<QOSUDPTest>

///
class QOSUDPTestExecutor<T : QOSUDPTest> : QOSTestExecutorClass<T>, UDPStreamSenderDelegate, UDPStreamReceiverDelegate /*swift compiler segfault if moved to extension*/ {

    let RESULT_UDP_OUTGOING_PACKETS                 = "udp_result_out_num_packets"
    let RESULT_UDP_INCOMING_PACKETS                 = "udp_result_in_num_packets"
    let RESULT_UDP_OUTGOING_PLR                     = "udp_result_out_packet_loss_rate"
    let RESULT_UDP_NUM_PACKETS_OUTGOING_RESPONSE    = "udp_result_out_response_num_packets"
    let RESULT_UDP_INCOMING_PLR                     = "udp_result_in_packet_loss_rate"
    let RESULT_UDP_NUM_PACKETS_INCOMING_RESPONSE    = "udp_result_in_response_num_packets"
    let RESULT_UDP_PORT_OUTGOING                    = "udp_objective_out_port"
    let RESULT_UDP_PORT_INCOMING                    = "udp_objective_in_port"
    let RESULT_UDP_NUM_PACKETS_OUTGOING             = "udp_objective_out_num_packets"
    let RESULT_UDP_NUM_PACKETS_INCOMING             = "udp_objective_in_num_packets"
    let RESULT_UDP_DELAY                            = "udp_objective_delay"
    let RESULT_UDP_TIMEOUT                          = "udp_objective_timeout"
    
    //
    
    /// have to be var to be used in withUsafe*Pointer
    var FLAG_UDP_TEST_ONE_DIRECTION: UInt8 = 1
    var FLAG_UDP_TEST_RESPONSE: UInt8 = 2
    var FLAG_UDP_TEST_AWAIT_RESPONSE: UInt8 = 3
    
    //
    
    let TAG_TASK_UDPTEST_OUT = 3001
    let TAG_TASK_GET_UDPPORT = 3002
    let TAG_TASK_UDPTEST_IN = 3003
    let TAG_TASK_UDPRESULT_OUT = 3004
    
    //
    
    ///
    private var udpStreamSender: UDPStreamSender!
    
    ///
    private var udpStreamReceiver: UDPStreamReceiver!
    
    //
    private var packetsReceived = [UInt8]()
    private var packetsDuplicate = [UInt8]()
    
    private var resultPacketData = UDPPacketData()
    
    //
    
    ///
    override init(controlConnection: QOSControlConnection, delegateQueue: dispatch_queue_t, testObject: T, speedtestStartTime: UInt64) {
        super.init(controlConnection: controlConnection, delegateQueue: delegateQueue, testObject: testObject, speedtestStartTime: speedtestStartTime)
    }
    
    ///
    override func startTest() {
        super.startTest()
        
        testResult.set(RESULT_UDP_DELAY, number: testObject.delay)
        testResult.set(RESULT_UDP_TIMEOUT, number: testObject.timeout)
    }
    
    ///
    override func endTest() {
        super.endTest()
        
        udpStreamSender?.stop()
        udpStreamReceiver?.stop()
    }
    
    ///
    override func executeTest() {
        qosLog.debug("EXECUTING UDP TEST")
        
        // outgoing
        if let packetCountOut = testObject.packetCountOut {
            if let portOut = testObject.portOut {
                
                announceOutgoingTest(portOut, packetCountOut)
            } else {
                
                // ask for port
                controlConnection.sendTaskCommand("GET UDPPORT", withTimeout: timeoutInSec, forTaskId: testObject.qosTestId, tag: TAG_TASK_GET_UDPPORT)
            }
        }
        
        // incoming
        if let packetCountIn = testObject.packetCountIn {
            if let portIn = testObject.portIn {
                
                announceIncomingTest(portIn, testObject.packetCountIn!)
            } else {
                // do nothing...
            }
        }
        
        // check if both params aren't set
        if (testObject.packetCountOut == nil && testObject.packetCountIn == nil) {
            testResult.set(RESULT_UDP_NUM_PACKETS_OUTGOING_RESPONSE, value: "NOT_SET")
            testResult.set(RESULT_UDP_NUM_PACKETS_INCOMING_RESPONSE, value: "NOT_SET")
            
            callFinishCallback()
        }
    }
    
    ///
    override func testDidSucceed() {
        super.testDidSucceed()
    }
    
    ///
    override func testDidTimeout() {
        //testResult.set(RESULT_UDP_TIMEOUT, value: "")
        
        super.testDidTimeout()
    }
    
    ///
    override func testDidFail() {
        super.testDidFail()
    }
    
// MARK: test methods
    
    ///
    private func announceOutgoingTest(portOut: UInt16, _ packetCountOut: UInt16) {
        qosLog.debug("announceOutgoingTest \(portOut), \(packetCountOut)")
        
        testResult.set(RESULT_UDP_NUM_PACKETS_OUTGOING, number: testObject.packetCountOut!)
        testResult.set(RESULT_UDP_PORT_OUTGOING,        number: testObject.portOut!)
        
        controlConnection.sendTaskCommand("UDPTEST OUT \(portOut) \(packetCountOut)", withTimeout: timeoutInSec, forTaskId: testObject.qosTestId, tag: TAG_TASK_UDPTEST_OUT)
    }
    
    ///
    private func announceIncomingTest(portIn: UInt16, _ packetCountIn: UInt16) {
        qosLog.debug("announceIncomingTest \(portIn), \(packetCountIn)")
        
        testResult.set(RESULT_UDP_NUM_PACKETS_INCOMING, number: testObject.packetCountIn!)
        testResult.set(RESULT_UDP_PORT_INCOMING,        number: testObject.portIn!)
        
        controlConnection.sendTaskCommand("UDPTEST IN \(portIn) \(packetCountIn)", withTimeout: timeoutInSec, forTaskId: testObject.qosTestId, tag: TAG_TASK_UDPTEST_IN)
    }
    
    ///
    private func startOutgoingTest() {
        let settings: UDPStreamSenderSettings = UDPStreamSenderSettings(
            host: testObject.serverAddress,
            port: testObject.portOut!,
            delegateQueue: delegateQueue,
            sendResponse: true,
            maxPackets: testObject.packetCountOut!,
            timeout: testObject.timeout,
            delay: testObject.delay,
            writeOnly: false,
            portIn: nil
        )
        
        udpStreamSender = UDPStreamSender(settings: settings)
        udpStreamSender.delegate = self
        
        qosLog.debug("before send udpStreamSender")
        
        let boolOk = udpStreamSender.send()
        
        qosLog.debug("after send udpStreamSender (\(boolOk))")
        
        if (!boolOk) {
            testDidTimeout()
            return
        }
        
        // request results
        // wait short time (last udp packet could reach destination after this request resulting in strange server behaviour)
        usleep(100000) /*100 * 1000*/
        controlConnection.sendTaskCommand("GET UDPRESULT OUT \(testObject.portOut!)", withTimeout: timeoutInSec, forTaskId: testObject.qosTestId, tag: TAG_TASK_UDPRESULT_OUT)
    }
    
    ///
    private func finishOutgoingTest() {
        testResult.set(RESULT_UDP_OUTGOING_PACKETS,                 value: resultPacketData.rcvServerResponse)
        testResult.set(RESULT_UDP_NUM_PACKETS_OUTGOING_RESPONSE,    value: resultPacketData.numPackets)
        
        // calculate packet loss rate
        let lostPackets = Int(testObject.packetCountOut!) - resultPacketData.numPackets
        
        qosLog.debug("UDP Outgoing, all: \(resultPacketData.numPackets), lost: \(lostPackets)")
        
        if (lostPackets > 0) {
            
            let packetLossRate = Double(lostPackets) / Double(testObject.packetCountOut!) * 100
            qosLog.debug("packet loss rate: \(packetLossRate)")
            
            testResult.set(RESULT_UDP_OUTGOING_PLR, value: "\(packetLossRate)")
            
        } else {
            testResult.set(RESULT_UDP_OUTGOING_PLR, value: "0")
        }
        
        // TODO: call finish callback only when both incoming and outgoing are finished
        testDidSucceed()
    }

    ///
    private func startIncomingTest() {
        let settings = UDPStreamReceiverSettings(
            port: testObject.portIn!,
            delegateQueue: delegateQueue,
            sendResponse: true,
            maxPackets: testObject.packetCountIn!,
            timeout: testObject.timeout
        )
        
        udpStreamReceiver = UDPStreamReceiver(settings: settings)
        udpStreamReceiver.delegate = self
        
        qosLog.debug("before receive udpStreamReceiver")
        
        udpStreamReceiver.receive()
        
        qosLog.debug("after receive udpStreamReceiver")
    }
    
    ///
    private func finishIncomingTest() {
        // TODO
    }
    
// MARK: QOSControlConnectionDelegate methods
    
    ///
    override func controlConnection(connection: QOSControlConnection, didReceiveTaskResponse response: String, withTaskId taskId: UInt, tag: Int) {
        qosLog.debug("CONTROL CONNECTION DELEGATE FOR TASK ID \(taskId), WITH TAG \(tag), WITH STRING \(response)")
        
        switch tag {
            case TAG_TASK_UDPTEST_OUT:
                qosLog.debug("TAG_TASK_UDPTEST_OUT response: \(response)")
            
                if (response.hasPrefix("OK")) {
                    // send udp packets
                    qosLog.debug("send udp packets")
                    
                    // TODO: send udp packets
                    startOutgoingTest()
                    
                    //callFinishCallback()
                } else {
                    // TODO: fail
                    testDidFail()
                    //failTestWithFatalError() // TODO: stop tests and close sockets etc. ... // TODO: or just run in timeout?
                }
            
            case TAG_TASK_GET_UDPPORT:
                qosLog.debug("TAG_TASK_GET_UDPPORT response: \(response)")
            
                if (!response.hasPrefix("ERR")) {
                    if let portOut = response.toInt() {
                        announceOutgoingTest(UInt16(portOut), testObject.packetCountOut!)
                    } else {
                        // TODO: fail
                        testDidFail()
                        //failTestWithFatalError() // TODO: stop tests and close sockets etc. ... // TODO: or just run in timeout?
                    }
                } else {
                    // TODO: fail
                    testDidFail()
                    //failTestWithFatalError() // TODO: stop tests and close sockets etc. ... // TODO: or just run in timeout?
                }
            
            case TAG_TASK_UDPTEST_IN:
                qosLog.debug("TAG_TASK_UDPTEST_IN response: \(response)")
            
            case TAG_TASK_UDPRESULT_OUT:
                qosLog.debug("TAG_TASK_UDPRESULT_OUT response: \(response)")
            
                if (response.hasPrefix("RCV")) {
                    qosLog.debug("got RCV")
                    
                    // TODO: with regex?
                    let rcvArray: [String] = split(response) { $0 == " " }
                    
                    if (rcvArray.count > 1) {
                        if let rcvss = rcvArray[1].toInt() {
                            resultPacketData.rcvServerResponse = rcvss
                        }
                    }
                }
            
                finishOutgoingTest()
            
            default:
                // do nothing
                qosLog.debug("default case: do nothing")
        }
    }
    
    ///
    /*override func controlConnection(connection: QOSControlConnection, didReceiveTimeout elapsed: NSTimeInterval, withTaskId taskId: UInt, tag: Int) {
        // let test fail/timeout
    }*/

    ///
    private func appendPacketData(inout data: NSMutableData, flag: UInt8, packetNumber: UInt16) {

        // write flag
        data.appendValue(flag)
        
        // write packetNumber
        data.appendValue(UInt8(packetNumber)) // make sure only 1 byte is used for packageNumber here
        
        // write uuid
        assert(testToken != nil, "testToken must not be nil")
        let uuid = (split(testToken) { $0 == "_" })[0] // split uuid from testToken
        data.appendData(uuid.dataUsingEncoding(NSASCIIStringEncoding)!)
        
        // write current time
        let ctm = "\(currentTimeMillis())"
        data.appendData(ctm.dataUsingEncoding(NSASCIIStringEncoding)!)
    }

// MARK: UDPStreamSenderDelegate methods
    
    /// returns false if the class should stop
    func udpStreamSender(udpStreamSender: UDPStreamSender, didReceivePacket packetData: NSData) -> Bool {
        qosLog.debug("udpStreamSenderDidReceive: \(packetData)")
        
        var flag: UInt8 = 0
        packetData.getBytes(&flag, length: sizeof(UInt8))
        
        var packetNumber: UInt8 = 0
        packetData.getBytes(&packetNumber, range: NSRange(location: 1, length: 1))

        if (flag != FLAG_UDP_TEST_RESPONSE) {
            qosLog.error("BAD UDP IN TEST PACKET IDENTIFIER")
            return false // TODO ???
        }
        
        if (contains(packetsReceived, packetNumber)) {
            packetsDuplicate.append(packetNumber)
            
            qosLog.error("DUPLICATE UDP IN TEST PACKET ID")
            
            //if (false/*ABORT_ON_DUPLICATE_UDP_PACKETS*/) {
            //    return false // TODO ???
            //}
        } else {
            packetsReceived.append(packetNumber)
        }
        
        resultPacketData.numPackets = packetsReceived.count
        resultPacketData.dupNumPackets = packetsDuplicate.count
        
        return true
    }
    
    /// returns false if the class should stop
    func udpStreamSender(udpStreamSender: UDPStreamSender, willSendPacketWithNumber packetNumber: UInt16, inout data: NSMutableData/*outputStream: OutputStream*/) -> Bool {
        qosLog.debug("udpStreamSenderwillSendPacketWithNumber: \(packetNumber)")
        
        appendPacketData(&data, flag: FLAG_UDP_TEST_AWAIT_RESPONSE, packetNumber: packetNumber)
        
        return true
    }
    
    ///
    func udpStreamSender(udpStreamSender: UDPStreamSender, didBindToPort port: UInt16) {
        // do nothing
    }
    
// MARK: UDPStreamReceiverDelegate methods

    ///
    func udpStreamReceiver(udpStreamReceiver: UDPStreamReceiver, didReceivePacket packetData: NSData) -> Bool {
        qosLog.debug("udpStreamReceiverDidReceive: \(packetData)")
        
        // TODO
        
        return true
    }
    
    ///
    func udpStreamReceiver(udpStreamReceiver: UDPStreamReceiver, willSendPacketWithNumber packetNumber: UInt16, inout data: NSMutableData) -> Bool {
        qosLog.debug("udpStreamReceiverwillSendPacketWithNumber: \(packetNumber)")
        
        appendPacketData(&data, flag: FLAG_UDP_TEST_RESPONSE, packetNumber: packetNumber)

        return true
    }
}

/*
//        let futurePacketData: Future<UDPPacketData> = {
//
//            let promise = Promise<UDPPacketData>()
//            Queue.global.async {
//                self.qosLog.debug("future before sleep")
//                sleep(1)
//                self.qosLog.debug("future after sleep")
//                promise.success(UDPPacketData())
//
//            }
//
//            return promise.future
//        }()
//
//        /*futurePacketData.onSuccess() { packetData in
//            self.qosLog.debug("got packet data: \(packetData)")
//        }
//
//        futurePacketData.onFailure() { error in
//            self.qosLog.debug("got packet error: \(error)")
//        }*/
//
//        self.qosLog.debug("before forced")
//
//        if let result = futurePacketData.forced(0.5) {
//            self.qosLog.debug("forced result: \(result)")
//        } else {
//            self.qosLog.debug("forced result = nil")
//        }
//
//        self.qosLog.debug("after forced")
*/
