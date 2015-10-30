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
//  UDPStreamSender.swift
//  RMBT
//
//  Created by Benjamin Pucher on 27.02.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import Foundation

///
struct UDPStreamSenderSettings {
    var host: String
    var port: UInt16 = 0
    var delegateQueue: dispatch_queue_t
    var sendResponse: Bool = false
    var maxPackets: UInt16 = 5
    var timeout: UInt64 = 10_000_000_000
    var delay: UInt64 = 10_000
    var writeOnly: Bool = false
    var portIn: UInt16?
}

///
class UDPStreamSender : NSObject, GCDAsyncUdpSocketDelegate {
    
    ///
    private let streamSenderQueue: dispatch_queue_t = /*dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)*/dispatch_queue_create("com.specure.rmbt.udp.streamSenderQueue", DISPATCH_QUEUE_CONCURRENT)
    
    ///
    private var udpSocket: GCDAsyncUdpSocket!
    
    ///
    private let countDownLatch = CountDownLatch()
    
    ///
    //private var running: AtomicBoolean = AtomicBoolean()
    private var running: Bool = false
    
    //
    
    ///
    var delegate: UDPStreamSenderDelegate?
    
    ///
    private let settings: UDPStreamSenderSettings
    
    //
    
    ///
    private var packetsReceived: UInt16 = 0
    
    ///
    private var packetsSent: UInt16 = 0
    
    ///
    private let delayMS: UInt64
    
    ///
    private let timeoutMS: UInt64
    
    ///
    private let timeoutSec: Double
    
    ///
    private var lastSentTimestampMS: UInt64 = 0
    
    ///
    required init(settings: UDPStreamSenderSettings) {
        self.settings = settings
        
        delayMS = settings.delay / NSEC_PER_MSEC
        timeoutMS = settings.timeout / NSEC_PER_MSEC
        
        timeoutSec = nsToSec(settings.timeout)
    }
    
    ///
    func stop() {
        //countDownLatch.countDown()
        running = false
    }
    
    ///
    private func connect() {
        logger.debug("connecting udp socket")
        udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: /*settings.delegateQueue*/streamSenderQueue)
        
        var error: NSError?
        
        //
        
        if let portIn = settings.portIn {
            udpSocket.bindToPort(portIn, error: &error)
            logger.debug("bindToPort error?: \(error)")
        }
        
        udpSocket.connectToHost(settings.host, onPort: settings.port, error: &error)
        
        logger.debug("connectToHost error?: \(error)") // TODO: check error (i.e. fail if error)
        
        countDownLatch.await(200 * NSEC_PER_MSEC)
        
        //
        
        if (!settings.writeOnly) {
            udpSocket.beginReceiving(&error) // TODO: check error (i.e. fail if error)
            
            logger.debug("receive error?: \(error)")
        }
    }
    
    ///
    private func close() {
        logger.debug("closing udp socket")
        udpSocket?.closeAfterSending()
    }
    
    ///
//    func send() -> Bool {
//        var b = false
//        
//        dispatch_sync(streamSenderQueue) {
//            b = self._send()
//        }
//        
//        return b
//    }
    
    ///
    func send() -> Bool {
        connect()
        
        let startTimeMS = currentTimeMillis()
        let stopTimeMS: UInt64 = (timeoutMS > 0) ? timeoutMS + startTimeMS : 0
        
        //

        var dataToSend: NSMutableData = NSMutableData()
        var shouldSend: Bool = false
        
        //
        
        var hasTimeout = false
        
        //
        
        //var usleepOverhead: UInt64 = 0
        
        //
        
        running = true
        
        while (running) {
            
            let currentTimeMS = currentTimeMillis()
            
            ////////////////////////////////////
            // check if should stop
            
            if (stopTimeMS > 0 && stopTimeMS < currentTimeMS) {
                logger.debug("stopping because of stopTimeMS")
                stop()
                
                hasTimeout = true
                
                break // why neccessary? -> because of bug in AtomicBoolean
            }
            
            ////////////////////////////////////
            // check delay
            
            var currentDelay = currentTimeMS - lastSentTimestampMS
            currentDelay = (currentDelay > delayMS) ? 0 : delayMS - currentDelay

            if (currentDelay > 0) {
                let sleepMicroSeconds = UInt32(currentDelay * 1000)
                
                //let sleepDelay = currentTimeMillis()
                
                usleep(sleepMicroSeconds) // TODO: usleep has an average overhead of about 5ms!
                
                //var t = timespec(tv_sec: 0, tv_nsec: Int(currentDelay) * 1000)
                //nanosleep(&t, nil)
                
                /*var usleepCurrentOverhead = currentTimeMillis() - sleepDelay
                //usleepOverhead += (usleepCurrentOverhead - currentDelay)
                logger.verbose("usleep for \(currentDelay)ms took \(usleepCurrentOverhead)ms")*/
            }
            
            ////////////////////////////////////
            // send packet
            
            if (packetsSent < settings.maxPackets) {
                dataToSend.length = 0
                
                shouldSend = self.delegate?.udpStreamSender(self, willSendPacketWithNumber: self.packetsSent, data: &dataToSend) ?? false
                
                if (shouldSend) {
                    udpSocket.sendData(dataToSend, withTimeout: timeoutSec, tag: Int(packetsSent)) // TAG == packet number
                    
                    packetsSent++
                    
                    lastSentTimestampMS = currentTimeMillis()
                }
            }
            
            ////////////////////////////////////
            // check for stop
            
            if (settings.writeOnly) {
                if (packetsSent >= settings.maxPackets) {
                    logger.debug("stopping because packetsSent >= settings.maxPackets")
                    stop()
                    break // why neccessary? -> because of bug in AtomicBoolean
                }
            } else {
                if (packetsSent >= settings.maxPackets && packetsReceived >= settings.maxPackets) {
                    logger.debug("stopping because packetsSent >= settings.maxPackets && packetsReceived >= settings.maxPackets")
                    stop()
                    break // why neccessary? -> because of bug in AtomicBoolean
                }
            }
            
            //logger.verbose("while took (without delay) \(currentTimeMillis() - currentTimeMS - currentDelay) ms, packetsSent: \(packetsSent)")
        }
        
        running = false
        
        close()
        
        //logger.verbose("usleep overhead was: \(usleepOverhead)")
        
        return !hasTimeout
    }
    
    ///
    private func receivePacket(dataReceived: NSData, fromAddress address: NSData) { // TODO: use dataReceived
        if (packetsReceived < settings.maxPackets) {
            packetsReceived++
            
            // call callback
            dispatch_async(settings.delegateQueue) {
                self.delegate?.udpStreamSender(self, didReceivePacket: dataReceived)
                return
            }
        }
    }
}

// MARK: GCDAsyncUdpSocketDelegate methods

///
extension UDPStreamSender : GCDAsyncUdpSocketDelegate {
    
    ///
    func udpSocket(sock: GCDAsyncUdpSocket!, didConnectToAddress address: NSData!) {
        logger.debug("didConnectToAddress: address: \(address)")
        logger.debug("didConnectToAddress: local port: \(udpSocket.localPort())")
        
        dispatch_async(settings.delegateQueue) {
            self.delegate?.udpStreamSender(self, didBindToPort: self.udpSocket.localPort())
            return
        }
        
        countDownLatch.countDown()
    }
    
    ///
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotConnect error: NSError!) {
        logger.debug("didNotConnect: \(error)")
    }
    
    ///
    func udpSocket(sock: GCDAsyncUdpSocket!, didSendDataWithTag tag: Int) {
//        logger.debug("didSendDataWithTag: \(tag)")
    }
    
    ///
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotSendDataWithTag tag: Int, dueToError error: NSError!) {
        logger.debug("didNotSendDataWithTag: \(error)")
    }
    
    ///
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        //logger.debug("didReceiveData: \(data)")
        
        //dispatch_async(streamSenderQueue) {
            if (self.running) {
                self.receivePacket(data, fromAddress: address)
            }
        //}
    }
    
    ///
    func udpSocketDidClose(sock: GCDAsyncUdpSocket!, withError error: NSError!) {
        logger.debug("udpSocketDidClose: \(error)")
    }
}
