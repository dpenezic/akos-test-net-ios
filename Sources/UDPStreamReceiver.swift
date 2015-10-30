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
//  UDPStreamReceiver.swift
//  RMBT
//
//  Created by Benjamin Pucher on 25.02.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import Foundation

///
struct UDPStreamReceiverSettings {
    var port: UInt16 = 0
    var delegateQueue: dispatch_queue_t
    var sendResponse: Bool = false
    var maxPackets: UInt16 = 5
    var timeout: UInt64 = 10_000_000_000
}

///
class UDPStreamReceiver : NSObject, GCDAsyncUdpSocketDelegate {
    
    ///
    private let socketQueue: dispatch_queue_t = dispatch_queue_create("com.specure.rmbt.udp.socketQueue", DISPATCH_QUEUE_CONCURRENT)
    
    ///
    private var udpSocket: GCDAsyncUdpSocket!
    
    ///
    private let countDownLatch: CountDownLatch = CountDownLatch()
    
    ///
    //private var running: AtomicBoolean = AtomicBoolean()
    private var running: Bool = false
    
    //
    
    ///
    var delegate: UDPStreamReceiverDelegate?
    
    ///
    private let settings: UDPStreamReceiverSettings
    
    ///
    private var packetsReceived: UInt16 = 0
    
    //
    
    ///
    required init(settings: UDPStreamReceiverSettings) {
        self.settings = settings
    }
    
    ///
    func stop() {
        countDownLatch.countDown()
    }
    
    ///
    private func connect() {
        logger.debug("connecting udp socket")
        udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: settings.delegateQueue, socketQueue: socketQueue)
        
        var error: NSError?
        udpSocket.bindToPort(settings.port, error: &error) // TODO: check error (i.e. fail if error)
        udpSocket.beginReceiving(&error) // TODO: check error (i.e. fail if error)
    }
    
    ///
    private func close() {
        logger.debug("closing udp socket")
        udpSocket?.close()
    }
    
    ///
    private func receivePacket(dataReceived: NSData, fromAddress address: NSData) { // TODO: use dataReceived
        packetsReceived++
        
        // didReceive callback
        
        var shouldStop: Bool = false
        
        dispatch_sync(settings.delegateQueue) {
            shouldStop = self.delegate?.udpStreamReceiver(self, didReceivePacket: dataReceived) ?? false
        }
        
        if (shouldStop || packetsReceived >= settings.maxPackets) {
            stop()
        }
        
        // send response
        
        if (settings.sendResponse) {
            var data = NSMutableData()
            
            var shouldSendResponse: Bool = false
            
            dispatch_sync(settings.delegateQueue) {
                shouldSendResponse = self.delegate?.udpStreamReceiver(self, willSendPacketWithNumber: self.packetsReceived, data: &data) ?? false
            }
            
            if (shouldSendResponse && data.length > 0) {
                udpSocket.sendData(data, toAddress: address, withTimeout: nsToSec(settings.timeout), tag: -1) // TODO: TAG
            }
        }
    }
    
    ///
    func receive() {
        connect()
        
        running = true
        
        // TODO: move timeout handling to other class! this class should be more generic!
        countDownLatch.await(settings.timeout) // TODO: timeout
        running = false
    
        close()
    }
}

// MARK: GCDAsyncUdpSocketDelegate methods

///
extension UDPStreamReceiver : GCDAsyncUdpSocketDelegate {

    ///
    func udpSocket(sock: GCDAsyncUdpSocket!, didConnectToAddress address: NSData!) {
        logger.debug("didConnectToAddress: \(address)")
    }

    ///
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotConnect error: NSError!) {
        logger.debug("didNotConnect: \(error)")
    }

    ///
    func udpSocket(sock: GCDAsyncUdpSocket!, didSendDataWithTag tag: Int) {
        logger.debug("didSendDataWithTag: \(tag)")
    }

    ///
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotSendDataWithTag tag: Int, dueToError error: NSError!) {
        logger.debug("didNotSendDataWithTag: \(error)")
    }

    ///
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        logger.debug("didReceiveData: \(data)")
        
        if (running) {
            receivePacket(data, fromAddress: address)
        }
    }

    ///
    func udpSocketDidClose(sock: GCDAsyncUdpSocket!, withError error: NSError!) {
        logger.debug("udpSocketDidClose: \(error)")
    }
}
