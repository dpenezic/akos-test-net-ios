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
//  ServiceTypeMapping.swift
//  DNSTest
//
//  Created by Benjamin Pucher on 10.03.15.
//  Copyright (c) 2015 Benjamin Pucher. All rights reserved.
//

import Foundation

// TODO: is this the Rcode?
/*enum DNSStatus {
OK = 0
BAD_HANDLE = 1
MALFORMED_QUERY = 2
TIMEOUT = 3
SEND_FAILED = 4
RECEIVE_FAILED = 5
CONNECTION_FAILED = 6
WRONG_SERVER = 7
WRONG_XID = 8
WRONG_QUESTION = 9
}*/

let DNSServiceTypeStrToInt: [String:Int] = [
    "A":        kDNSServiceType_A,
    //    "NS":       kDNSServiceType_NS,
    "CNAME":    kDNSServiceType_CNAME,
    //    "SOA":      kDNSServiceType_SOA,
    //    "PTR":      kDNSServiceType_PTR,
    "MX":       kDNSServiceType_MX,
    //    "TXT":      kDNSServiceType_TXT,
    "AAAA":     kDNSServiceType_AAAA,
    //    "SRV":      kDNSServiceType_SRV,
    //"A6":       kDNSServiceType_A6,
    //    "SPF":      kDNSServiceType_SPF
]

let DNSServiceTypeIntToStr: [Int:String] = [
    kDNSServiceType_A:      "A",
    //    kDNSServiceType_NS:     "NS",
    kDNSServiceType_CNAME:  "CNAME",
    //    kDNSServiceType_SOA:    "SOA",
    //    kDNSServiceType_PTR:    "PTR",
    kDNSServiceType_MX:     "MX",
    //    kDNSServiceType_TXT:    "TXT",
    kDNSServiceType_AAAA:   "AAAA",
    //    kDNSServiceType_SRV:    "SRV",
    //kDNSServiceType_A6:     "A6",
    //    kDNSServiceType_SPF:    "SPF"
]