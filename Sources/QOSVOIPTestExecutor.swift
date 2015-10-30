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
//  QOSVOIPTestExecutor.swift
//  RMBT
//
//  Created by Benjamin Pucher on 29.01.15.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
typealias VOIPTestExecutor = QOSVOIPTestExecutor<QOSVOIPTest>

///
class QOSVOIPTestExecutor<T : QOSVOIPTest> : QOSTestExecutorClass<T>, UDPStreamSenderDelegate {

    let RESULT_VOIP_PREFIX          = "voip_result"
    let RESULT_VOIP_PREFIX_INCOMING = "_in_"
    let RESULT_VOIP_PREFIX_OUTGOING = "_out_"

    ///

    let RESULT_VOIP_PAYLOAD             = "voip_objective_payload"
    let RESULT_VOIP_IN_PORT             = "voip_objective_in_port"
    let RESULT_VOIP_OUT_PORT            = "voip_objective_out_port"
    let RESULT_VOIP_CALL_DURATION       = "voip_objective_call_duration"
    let RESULT_VOIP_BITS_PER_SAMPLE     = "voip_objective_bits_per_sample"
    let RESULT_VOIP_SAMPLE_RATE         = "voip_objective_sample_rate"
    let RESULT_VOIP_DELAY               = "voip_objective_delay"
    let RESULT_VOIP_STATUS              = "voip_result_status"
    let RESULT_VOIP_VOIP_PREFIX         = "voip_result"
    let RESULT_VOIP_INCOMING_PREFIX     = "_in_"
    let RESULT_VOIP_OUTGOING_PREFIX     = "_out_"
    let RESULT_VOIP_SHORT_SEQUENTIAL    = "short_seq"
    let RESULT_VOIP_LONG_SEQUENTIAL     = "long_seq"
    let RESULT_VOIP_MAX_JITTER          = "max_jitter"
    let RESULT_VOIP_MEAN_JITTER         = "mean_jitter"
    let RESULT_VOIP_MAX_DELTA           = "max_delta"
    let RESULT_VOIP_SKEW                = "skew"
    let RESULT_VOIP_NUM_PACKETS         = "num_packets"
    let RESULT_VOIP_SEQUENCE_ERRORS     = "sequence_error"
    let RESULT_VOIP_TIMEOUT             = "voip_objective_timeout"

    //

    let TAG_TASK_VOIPTEST = 4001
    let TAG_TASK_VOIPRESULT = 4002

    //

    ///
    private var udpStreamSender: UDPStreamSender!

    ///
    private var initialSequenceNumber: UInt16!

    ///
    private var ssrc: UInt32!

    ///
    private var initialRTPPacket: RTPPacket!

    ///
    private var rtpControlDataList = [UInt16:RTPControlData]()

    ///
    private var payloadSize: Int!

    ///
    private var payloadTimestamp: UInt32!

    ///
    private var cdl: CountDownLatch!
    
    //

    ///
    override init(controlConnection: QOSControlConnection, delegateQueue: dispatch_queue_t, testObject: T, speedtestStartTime: UInt64) {
        super.init(controlConnection: controlConnection, delegateQueue: delegateQueue, testObject: testObject, speedtestStartTime: speedtestStartTime)
    }
    
    ///
    override func startTest() {
        super.startTest()

        testResult.set(RESULT_VOIP_DELAY,           number: testObject.delay)
        testResult.set(RESULT_VOIP_BITS_PER_SAMPLE, number: testObject.bitsPerSample)
        testResult.set(RESULT_VOIP_CALL_DURATION,   number: testObject.callDuration)
        testResult.set(RESULT_VOIP_OUT_PORT,        number: testObject.portOut)
        testResult.set(RESULT_VOIP_IN_PORT,         number: testObject.portIn)
        testResult.set(RESULT_VOIP_SAMPLE_RATE,     number: testObject.sampleRate)
        testResult.set(RESULT_VOIP_PAYLOAD,         number: testObject.payloadType)
        testResult.set(RESULT_VOIP_STATUS,          value: "OK") // !
        testResult.set(RESULT_VOIP_TIMEOUT,         number: testObject.timeout)

        initialSequenceNumber = UInt16(arc4random_uniform(10000) + 1)
    }

    ///
    override func endTest() {
        super.endTest()

        udpStreamSender?.stop()
    }

    ///
    override func executeTest() {
        qosLog.debug("EXECUTING VOIP TEST")

        // announce voip test
        var voipCommand = "VOIPTEST \(testObject.portOut!) \(testObject.portIn!) \(testObject.sampleRate) \(testObject.bitsPerSample) "
        voipCommand += "\(testObject.delay / NSEC_PER_MSEC) \(testObject.callDuration / NSEC_PER_MSEC) "
        voipCommand += "\(initialSequenceNumber) \(testObject.payloadType)"

        sendTaskCommand(voipCommand, withTimeout: timeoutInSec, tag: TAG_TASK_VOIPTEST)
        
        cdlTimeout(500, forTag: "TAG_TASK_VOIPTEST")
    }

    ///
    override func testDidSucceed() {
        super.testDidSucceed()
    }

    ///
    override func testDidTimeout() {
        testResult.set(RESULT_VOIP_STATUS, value: "TIMEOUT")

        udpStreamSender?.stop()

        super.testDidTimeout()
    }

    ///
    override func testDidFail() {
        testResult.set(RESULT_VOIP_STATUS, value: "ERROR")

        udpStreamSender?.stop()
        
        super.testDidFail()
    }

// MARK: Other methods
    
    func cdlTimeout(timeoutMs: UInt64, forTag: String) {
        cdl = CountDownLatch()
        let noTimeout = cdl.await(timeoutMs * NSEC_PER_MSEC)
        cdl = nil
        if (!noTimeout) {
            qosLog.debug("CDL TIMEOUT: \(forTag)")
            testDidTimeout()
        }
    }
    
// MARK: QOSTestExecutorProtocol methods

    ///
    override func needsCustomTimeoutHandling() -> Bool {
        return true
    }

// MARK: test methods

    ///
    private func startOutgoingTest() {

        let dDelay          = Double(testObject.delay / NSEC_PER_MSEC)
        let dSampleRate     = Double(testObject.sampleRate)
        let dBitsPerSample  = Double(testObject.bitsPerSample)
        let dCallDuration   = Double(testObject.callDuration / NSEC_PER_MSEC)
        let numPackets      = UInt16(dCallDuration / dDelay)

        qosLog.debug("dDelay: \(dDelay)")
        qosLog.debug("dSampleRate: \(dSampleRate)")
        qosLog.debug("dBitsPerSample: \(dBitsPerSample)")
        qosLog.debug("dCallDuration: \(dCallDuration)")
        qosLog.debug("numPackets: \(numPackets)")

        //

        payloadSize         = Int(dSampleRate / (1000 / dDelay) * (dBitsPerSample / 8))
        payloadTimestamp    = UInt32(dSampleRate / (1000 / dDelay))

        qosLog.debug("payloadSize: \(payloadSize)")
        qosLog.debug("payloadTimestamp: \(payloadTimestamp)")

        //

        initialRTPPacket = RTPPacket()

        initialRTPPacket.header.payloadType = testObject.payloadType
        initialRTPPacket.header.ssrc = ssrc
        initialRTPPacket.header.sequenceNumber = initialSequenceNumber

        //

        let settings: UDPStreamSenderSettings = UDPStreamSenderSettings(
            host: testObject.serverAddress,
            port: testObject.portOut!,
            delegateQueue: delegateQueue,
            sendResponse: true,
            maxPackets: numPackets,
            timeout: testObject.timeout,
            delay: testObject.delay,
            writeOnly: false,
            portIn: testObject.portIn
        )

        udpStreamSender = UDPStreamSender(settings: settings)
        udpStreamSender.delegate = self

        // start timeout timer
        startTimer()

        qosLog.debug("before send udpStreamSender")

        let ticksBeforeSend = getCurrentTimeTicks()

        let boolOk = udpStreamSender.send()

        qosLog.debug("after send udpStreamSender (-> \(boolOk)) (took \(Double(getTimeDifferenceInNanoSeconds(ticksBeforeSend)) / Double(NSEC_PER_MSEC))ms)")

        udpStreamSender.stop()

        // stop timeout timer
        stopTimer()

        // timeout if sender ran into timeout
        if (!boolOk) {
            testDidTimeout()
            return
        }

        // request results
        // wait short time (last udp packet could reach destination after this request resulting in strange server behaviour)
        usleep(100000) /*100 * 1000*/
        
        controlConnection.sendTaskCommand("GET VOIPRESULT \(ssrc)", withTimeout: timeoutInSec, forTaskId: testObject.qosTestId, tag: TAG_TASK_VOIPRESULT)
        
        cdlTimeout(500, forTag: "TAG_TASK_VOIPRESULT")
    }

    ///
    private func finishOutgoingTest() {
        qosLog.debug("FINISH OUTGOING VOIP TEST")

        let prefix = RESULT_VOIP_PREFIX + RESULT_VOIP_PREFIX_INCOMING

        let _start = getCurrentTimeTicks()
        qosLog.debug("_calculateQOS start")

        // calculate QOS
        if let rtpResult = calculateQOS() {

            qosLog.debug("_calculateQOS took \(getTimeDifferenceInNanoSeconds(_start) / NSEC_PER_MSEC) ms")

            qosLog.debug("rtpResult: \(rtpResult)")

            testResult.set(prefix + RESULT_VOIP_MAX_JITTER,         number: rtpResult.maxJitter)
            testResult.set(prefix + RESULT_VOIP_MEAN_JITTER,        number: rtpResult.meanJitter)
            testResult.set(prefix + RESULT_VOIP_MAX_DELTA,          number: rtpResult.maxDelta)
            testResult.set(prefix + RESULT_VOIP_SKEW,               number: rtpResult.skew)
            testResult.set(prefix + RESULT_VOIP_NUM_PACKETS,        number: rtpResult.receivedPackets)
            testResult.set(prefix + RESULT_VOIP_SEQUENCE_ERRORS,    number: rtpResult.outOfOrder)
            testResult.set(prefix + RESULT_VOIP_SHORT_SEQUENTIAL,   number: rtpResult.minSequential)
            testResult.set(prefix + RESULT_VOIP_LONG_SEQUENTIAL,    number: rtpResult.maxSequential)

        } else {

            testResult.set(prefix + RESULT_VOIP_MAX_JITTER,         value: nil)
            testResult.set(prefix + RESULT_VOIP_MEAN_JITTER,        value: nil)
            testResult.set(prefix + RESULT_VOIP_MAX_DELTA,          value: nil)
            testResult.set(prefix + RESULT_VOIP_SKEW,               value: nil)
            testResult.set(prefix + RESULT_VOIP_NUM_PACKETS,        number: 0)
            testResult.set(prefix + RESULT_VOIP_SEQUENCE_ERRORS,    value: nil)
            testResult.set(prefix + RESULT_VOIP_SHORT_SEQUENTIAL,   value: nil)
            testResult.set(prefix + RESULT_VOIP_LONG_SEQUENTIAL,    value: nil)
        }

        testDidSucceed()
    }

// MARK: calculate qos

    ///
    private func calculateQOS() -> RTPResult? {

        if (rtpControlDataList.count == 0) {
            return nil
        }

        //

        var jitterMap = [UInt16:Double]()

        var sequenceNumberArray = [UInt16](rtpControlDataList.keys.array)
        sort(&sequenceNumberArray) { $0 < $1 }  // TODO: delete when set datatype is available

        var sequenceArray = [RTPSequence]()
        //sort(&sequenceArray) { $0.timestampNS < $1.timestampNS }  // TODO: delete when set datatype is available

        //

        var maxJitter: /*U*/Int64 = 0
        var meanJitter: /*U*/Int64 = 0
        var skew: Int64 = 0
        var maxDelta: /*U*/Int64 = 0
        var tsDiff: /*U*/Int64 = 0

        //

        var prevSeqNr: UInt16? = nil
        for x in sequenceNumberArray {
            let j = rtpControlDataList[x]!

            //println("prevSeqNr: \(prevSeqNr)")
            //println("jitterMap: \(jitterMap)")

            if let _prevSeqNr = prevSeqNr {
                let i = rtpControlDataList[_prevSeqNr]!

                tsDiff = /*U*/Int64(j.receivedNS) - /*U*/Int64(i.receivedNS)

                let prevJitter: Double = jitterMap[_prevSeqNr]!
                let delta: /*U*/Int64 = /*U*/Int64(abs(calculateDelta(i, j, testObject.sampleRate)))
                let jitter: Double = prevJitter + (Double(delta) - prevJitter) / 16

                jitterMap[x] = jitter

                maxDelta = max(delta, maxDelta)

                skew += Int64((Double(j.rtpPacket.header.timestamp - i.rtpPacket.header.timestamp) / Double(testObject.sampleRate) * 1000) * Double(NSEC_PER_MSEC)) - Int64(tsDiff)
                maxJitter = max(/*U*/Int64(jitter), maxJitter)
                meanJitter += /*U*/Int64(jitter)
            } else {
                jitterMap[x] = 0
            }

            prevSeqNr = x
            sequenceArray.append(RTPSequence(timestampNS: j.receivedNS, seq: x))
            sort(&sequenceArray) { $0.timestampNS < $1.timestampNS } // TODO: delete when set datatype is available
        }

        //

        var nextSeq = initialSequenceNumber!
        var packetsOutOfOrder = 0
        var maxSequential = 0
        var minSequential = 0
        var curSequential = 0

        //

        for i in sequenceArray {

            if (i.seq != nextSeq) {
                packetsOutOfOrder++

                maxSequential = max(curSequential, maxSequential)

                if (curSequential > 1) {
                    minSequential = (curSequential < minSequential) ? curSequential : (minSequential == 0 ? curSequential : minSequential)
                }

                curSequential = 0
            } else {
                curSequential++
            }

            nextSeq++
        }

        maxSequential = max(curSequential, maxSequential)
        if (curSequential > 1) {
            minSequential = (curSequential < minSequential) ? curSequential : (minSequential == 0 ? curSequential : minSequential)
        }

        if (minSequential == 0 && maxSequential > 0) {
            minSequential = maxSequential
        }

        //

        return RTPResult(
            jitterMap: jitterMap,
            maxJitter: maxJitter,
            meanJitter: meanJitter / /*U*/Int64(jitterMap.count),
            skew: skew,
            maxDelta: maxDelta,
            outOfOrder: UInt16(packetsOutOfOrder),
            minSequential: UInt16(maxSequential),
            maxSequential: UInt16(minSequential)
        )
    }

    ///
    private func calculateDelta(i: RTPControlData, _ j: RTPControlData, _ sampleRate: UInt16) -> Int64 {
        let msDiff: Int64 = Int64(j.receivedNS) - Int64(i.receivedNS)
        let tsDiff: Int64 = Int64((Double(j.rtpPacket.header.timestamp - i.rtpPacket.header.timestamp) / Double(sampleRate) * 1000) * Double(NSEC_PER_MSEC))

        return msDiff - tsDiff
    }

// MARK: QOSControlConnectionDelegate methods

    ///
    override func controlConnection(connection: QOSControlConnection, didReceiveTaskResponse response: String, withTaskId taskId: UInt, tag: Int) {
        qosLog.debug("CONTROL CONNECTION DELEGATE FOR TASK ID \(taskId), WITH TAG \(tag), WITH STRING \(response)")

        switch tag {
            case TAG_TASK_VOIPTEST:
                qosLog.debug("TAG_TASK_VOIPTEST response: \(response)")

                if (response.hasPrefix("OK")) {
                    cdl?.countDown()

                    ssrc = UInt32((split(response) { $0 == " " })[1].toInt()!) // !
                    qosLog.info("got ssrc: \(ssrc)")

                    startOutgoingTest()
                }

            case TAG_TASK_VOIPRESULT:
                qosLog.debug("TAG_TASK_VOIPRESULT response: \(response)")

                if (response.hasPrefix("VOIPRESULT")) {

                    let voipResultArray = split(response) { $0 == " " }

                    if (voipResultArray.count >= 9) {
                        cdl?.countDown()

                        let prefix = RESULT_VOIP_PREFIX + RESULT_VOIP_PREFIX_OUTGOING

                        testResult.set(prefix + RESULT_VOIP_MAX_JITTER,         number: voipResultArray[1].toInt())
                        testResult.set(prefix + RESULT_VOIP_MEAN_JITTER,        number: voipResultArray[2].toInt())
                        testResult.set(prefix + RESULT_VOIP_MAX_DELTA,          number: voipResultArray[3].toInt())
                        testResult.set(prefix + RESULT_VOIP_SKEW,               number: voipResultArray[4].toInt())
                        testResult.set(prefix + RESULT_VOIP_NUM_PACKETS,        number: voipResultArray[5].toInt())
                        testResult.set(prefix + RESULT_VOIP_SEQUENCE_ERRORS,    number: voipResultArray[6].toInt())
                        testResult.set(prefix + RESULT_VOIP_SHORT_SEQUENTIAL,   number: voipResultArray[7].toInt())
                        testResult.set(prefix + RESULT_VOIP_LONG_SEQUENTIAL,    number: voipResultArray[8].toInt())

                        finishOutgoingTest()
                    }
                }

            default:
                assert(false, "should never happen")
        }
    }

// MARK: UDPStreamSenderDelegate methods

    /// returns false if the class should stop
    func udpStreamSender(udpStreamSender: UDPStreamSender, didReceivePacket packetData: NSData) -> Bool {
        //qosLog.debug("udpStreamSenderDidReceive: \(packetData)")

        let receivedNS = nanoTime()

        // assemble rtp packet
        if let rtpPacket = RTPPacket.fromData(packetData) {

            // put packet in data list
            rtpControlDataList[rtpPacket.header.sequenceNumber] = RTPControlData(rtpPacket: rtpPacket, receivedNS: receivedNS)
            // TODO: EXC_BAD_ACCESS at this line?
        }

        return true
    }

    /// returns false if the class should stop
    func udpStreamSender(udpStreamSender: UDPStreamSender, willSendPacketWithNumber packetNumber: UInt16, inout data: NSMutableData) -> Bool {
        if (packetNumber > 0) {
            initialRTPPacket.header.increaseSequenceNumberBy(1)
            initialRTPPacket.header.increaseTimestampBy(payloadTimestamp)
            initialRTPPacket.header.marker = 0
        } else {
            initialRTPPacket.header.marker = 1
        }

        // generate random bytes

        var payloadBytes = malloc(payloadSize) // CAUTION! this sends memory dump to server...
        initialRTPPacket.payload = NSData(bytes: &payloadBytes, length: Int(payloadSize))
        free(payloadBytes)

        //

        data.appendData(initialRTPPacket.toData())

        return true
    }

    ///
    func udpStreamSender(udpStreamSender: UDPStreamSender, didBindToPort port: UInt16) {
        testResult.set(RESULT_VOIP_IN_PORT, number: port)
    }
}
