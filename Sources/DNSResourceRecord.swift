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
//  DNSResourceRecord.swift
//  DNSTest
//
//  Created by Benjamin Pucher on 10.03.15.
//  Copyright (c) 2015 Benjamin Pucher. All rights reserved.
//

import Foundation

///
struct DNSResourceRecord : Printable {
    var namePointer: UInt16
    var dnsType: UInt16
    var dnsClass: UInt16
    var ttl: UInt32
    //var ttl1: UInt16
    //var ttl2: UInt16
    var dataLength: UInt16
    
    var description: String {
        return "DNSResourceRecord: [namePointer: \(namePointer), dnsType: \(dnsType), dnsClass: \(dnsClass), ttl: \(ttl), dataLength: \(dataLength)]"
        //return "DNSResourceRecord: [namePointer: \(namePointer), dnsType: \(dnsType), dnsClass: \(dnsClass), ttl: \(ttl1), \(ttl2), dataLength: \(dataLength)]"
    }
    
    // 16 bit => name pointer?
    // 16 bit => service type
    // 16 bit => service class
    // 32 bit => ttl
    // 16 bit => data length
    // data-length * 8 bit => data
    
    init() {
        namePointer = 0
        dnsType = 0
        dnsClass = 0
        ttl = 0
        //ttl1 = 0
        //ttl2 = 0
        dataLength = 0
    }
}