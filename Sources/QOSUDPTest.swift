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
//  QOSUDPTest.swift
//  RMBT
//
//  Created by Benjamin Pucher on 05.12.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
class QOSUDPTest : QOSTest {
    
    let PARAM_NUM_PACKETS_OUT = "out_num_packets"
    let PARAM_NUM_PACKETS_IN = "in_num_packets"
    
    let PARAM_PORT_OUT = "out_port"
    let PARAM_PORT_IN = "in_port"
    
    let PARAM_DELAY = "delay"
    
    //
    
    var packetCountOut: UInt16?
    var packetCountIn: UInt16?
    
    var portOut: UInt16?
    var portIn: UInt16?
    
    var delay: UInt64 = 300_000_000 // 300 ms
    
    //
    
    ///
    override var description: String {
        return super.description + ", [packetCountOut: \(packetCountOut), packetCountIn: \(packetCountIn), portOut: \(portOut), portIn: \(portIn), delay: \(delay)]"
    }
    
    //
    
    ///
    override init(testParameters: QOSTestParameters) {
        // packetCountOut
        if let packetCountOutString = testParameters[PARAM_NUM_PACKETS_OUT] as? String {
            if let packetCountOut = packetCountOutString.toInt() {
                self.packetCountOut = UInt16(packetCountOut)
            }
        }
        
        // packetCountIn
        if let packetCountInString = testParameters[PARAM_NUM_PACKETS_IN] as? String {
            if let packetCountIn = packetCountInString.toInt() {
                self.packetCountIn = UInt16(packetCountIn)
            }
        }
        
        // portOut
        if let portOutString = testParameters[PARAM_PORT_OUT] as? String {
            if let portOut = portOutString.toInt() {
                self.portOut = UInt16(portOut)
            }
        }
        
        // portIn
        if let portInString = testParameters[PARAM_PORT_IN] as? String {
            if let portIn = portInString.toInt() {
                self.portIn = UInt16(portIn)
            }
        }
        
        // delay
        if let delayString = testParameters[PARAM_DELAY] as? NSString {
            let delay = delayString.longLongValue
            if (delay > 0) {
                self.delay = UInt64(delay)
            }
        }
        
        super.init(testParameters: testParameters)
    }
    
    ///
    override func getType() -> QOSTestType! {
        return .UDP
    }
}