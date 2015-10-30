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
//  QOSVOIPTest.swift
//  RMBT
//
//  Created by Benjamin Pucher on 05.12.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
class QOSVOIPTest : QOSTest {
   
    let PARAM_BITS_PER_SAMLE = "bits_per_sample"
    let PARAM_SAMPLE_RATE = "sample_rate"
    let PARAM_DURATION = "call_duration" //call duration in ns
    let PARAM_PORT_OUT = "out_port"
    let PARAM_PORT_IN = "in_port"
    let PARAM_DELAY = "delay"
    let PARAM_PAYLOAD = "payload"
    
    // TODO: parameter list not final
    
    var portOut: UInt16?
    var portIn: UInt16?
    
    var delay: UInt64 = 20_000_000 // 20ms
    var callDuration: UInt64 = 1_000_000_000 // 1s
    
    var sampleRate: UInt16 = 8000 // 8 kHz
    var bitsPerSample: UInt8 = 8

    var payloadType: UInt8 = 8 // PCMA(8, 8000, 1, CodecType.AUDIO)

    //
    
    ///
    override var description: String {
        return super.description + ", [outgoingPort: \(portOut), incomingPort: \(portIn), callDuration: \(callDuration), delay: \(delay), sampleRate: \(sampleRate), bitsPerSample: \(bitsPerSample)]"
    }
    
    //
    
    ///
    override init(testParameters: QOSTestParameters) {
        // TODO: parse testParameters
        
        // portOut
        if let portOutString = testParameters[PARAM_PORT_OUT] as? String {
            if let portOut = portOutString.toInt() {
                self.portOut = UInt16(portOut)
                //logger.debug("setting portOut: \(self.portOut)")
            }
        }
        
        // portIn
        if let portInString = testParameters[PARAM_PORT_IN] as? String {
            if let portIn = portInString.toInt() {
                self.portIn = UInt16(portIn)
                //logger.debug("setting portIn: \(self.portIn)")
            }
        }
        
        // delay
        if let delayString = testParameters[PARAM_DELAY] as? NSString {
            let delay = delayString.longLongValue
            if (delay > 0) {
                self.delay = UInt64(delay)
                //logger.debug("setting delay: \(self.delay)")
            }
        }
        
        // callDuration
        if let callDurationString = testParameters[PARAM_DURATION] as? NSString {
            let callDuration = callDurationString.longLongValue
            if (callDuration > 0) {
                self.callDuration = UInt64(callDuration)
                //logger.debug("setting callDuration: \(self.callDuration)")
            }
        }
        
        // sampleRate
        if let sampleRateString = testParameters[PARAM_SAMPLE_RATE] as? String {
            if let sampleRate = sampleRateString.toInt() {
                self.sampleRate = UInt16(sampleRate)
                //logger.debug("setting sampleRate: \(self.sampleRate)")
            }
        }
        
        // bitsPerSample
        if let bitsPerSampleString = testParameters[PARAM_BITS_PER_SAMLE] as? String {
            if let bitsPerSample = bitsPerSampleString.toInt() {
                self.bitsPerSample = UInt8(bitsPerSample)
                //logger.debug("setting bitsPerSample: \(self.bitsPerSample)")
            }
        }
        
        // payloadType
        if let payloadTypeString = testParameters[PARAM_PAYLOAD] as? String {
            if let payloadType = payloadTypeString.toInt() {
                self.payloadType = UInt8(payloadType)
                //logger.debug("setting payloadType: \(self.payloadType)")
            }
        }
        
        super.init(testParameters: testParameters)
    }
    
    ///
    override func getType() -> QOSTestType! {
        return .VOIP
    }
    
}