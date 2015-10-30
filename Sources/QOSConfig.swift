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
//  QOSConfig.swift
//  RMBT
//
//  Created by Benjamin Pucher on 06.02.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

//////////////////
// QOS
//////////////////

/// default qos socket character encoding
let QOS_SOCKET_DEFAULT_CHARACTER_ENCODING: UInt = NSUTF8StringEncoding

///
let QOS_CONTROL_CONNECTION_TIMEOUT_NS: UInt64 = 10_000_000_000
let QOS_CONTROL_CONNECTION_TIMEOUT_SEC: NSTimeInterval = NSTimeInterval(QOS_CONTROL_CONNECTION_TIMEOUT_NS / NSEC_PER_SEC)

///
let QOS_DEFAULT_TIMEOUT_NS: UInt64 = 10_000_000_000 // default timeout value in nano seconds

///
let QOS_TLS_SETTINGS = [
    GCDAsyncSocketSSLCipherSuites: [
        SSL_RSA_WITH_RC4_128_MD5
    ],
    GCDAsyncSocketManuallyEvaluateTrust: true
]

///
let WALLED_GARDEN_URL: String = "https://www.akostest.net/generate_204" // TODO: use url from settings request

///
let WALLED_GARDEN_SOCKET_TIMEOUT_MS: Double = 10_000

///
#if DEBUG

let QOS_ENABLED_TESTS: [QOSTestType] = [
    .HTTP_PROXY,
    .NON_TRANSPARENT_PROXY,
    //.WEBSITE,
    .DNS,
    .TCP,
    .UDP,
    .VOIP,
    .TRACEROUTE
]
    
/// determine the tests which should show log messages
let QOS_ENABLED_TESTS_LOG: [QOSTestType] = [
//    .HTTP_PROXY,
//    .NON_TRANSPARENT_PROXY,
//    .WEBSITE,
//    .DNS,
//    .TCP,
//    .UDP,
    .VOIP,
//    .TRACEROUTE
]
    
#else

// BETA / PRODUCTION
    
let QOS_ENABLED_TESTS: [QOSTestType] = [
    .HTTP_PROXY,
    .NON_TRANSPARENT_PROXY,
    //.WEBSITE,
    .DNS,
    .TCP,
    .UDP,
    .VOIP,
    .TRACEROUTE
]
    
/// determine the tests which should show log messages
let QOS_ENABLED_TESTS_LOG: [QOSTestType] = [
    .HTTP_PROXY,
    .NON_TRANSPARENT_PROXY,
    //    .WEBSITE,
    .DNS,
    .TCP,
    .UDP,
    .VOIP,
    .TRACEROUTE
]

#endif
