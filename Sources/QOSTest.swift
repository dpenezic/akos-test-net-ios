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
//  QOSTest.swift
//  RMBT
//
//  Created by Benjamin Pucher on 05.12.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
class QOSTest : Printable /* TODO: declarations in extensions cannot be overriden yet */ { // should be abstract

    let PARAM_TEST_UID = "qos_test_uid"
    let PARAM_CONCURRENCY_GROUP = "concurrency_group"
    let PARAM_SERVER_ADDRESS = "server_addr"
    let PARAM_SERVER_PORT = "server_port"
    let PARAM_TIMEOUT = "timeout"
    
    // values from server
    
    /// The id of this QOS test (provided by control server)
    var qosTestId: UInt = 0 // TODO: make this field optional?
    
    /// The concurrency group of this QOS test (provided by control server)
    var concurrencyGroup: UInt = 0 // TODO: make this field optional?
    
    /// The server address of this QOS test (provided by control server)
    var serverAddress: String = "_server_address"// TODO: make this field optional?
    
    /// The server port of this QOS test (provided by control server)
    var serverPort: UInt16 = 443 // TODO: make this field optional?
    
    /// The general timeout in nano seconds of this QOS test (provided by control server)
    var timeout: UInt64 = QOS_DEFAULT_TIMEOUT_NS
    
    /// the set of additional test paramters
    let testParameters: QOSTestParameters // TODO: neccessary to save reference to dictionary? I don't think that we need this
    
    //
    
    var testStartTimestampNS: UInt64?
    var testEndTimestampNS: UInt64?
    
    var hasStarted: Bool = false
    var hasFinished: Bool = false
    
    //
    
    ///
    var description: String {
        return "QOSTest(\(getType().rawValue)) [id: \(qosTestId), concurrencyGroup: \(concurrencyGroup), serverAddress: \(serverAddress), serverPort: \(serverPort), timeout: \(timeout)]"
    }
    
    //
    
    ///
    init(testParameters: QOSTestParameters) {
        self.testParameters = testParameters
        
        // qosTestId
        //if let qosTestId = testParameters[PARAM_TEST_UID]? as? Int {
        if let qosTestIdString = testParameters[PARAM_TEST_UID] as? String {
            //self.qosTestId = UInt(qosTestId)
            if let qosTestId = qosTestIdString.toInt() {
                self.qosTestId = UInt(qosTestId)
            }
        }
        
        // concurrencyGroup
        //if let concurrencyGroup = testParameters[PARAM_CONCURRENCY_GROUP]? as? Int {
        if let concurrencyGroupString = testParameters[PARAM_CONCURRENCY_GROUP] as? String {
            //self.concurrencyGroup = UInt(concurrencyGroup)
            if let concurrencyGroup = concurrencyGroupString.toInt() {
                self.concurrencyGroup = UInt(concurrencyGroup)
            }
        }
        
        // serverAddress
        if let serverAddress = testParameters[PARAM_SERVER_ADDRESS] as? String {
            // TODO: length check on url?
            self.serverAddress = serverAddress
        }
        
        // serverPort
        //if let serverPort = testParameters[PARAM_SERVER_PORT]? as? Int {
        if let serverPortString = testParameters[PARAM_SERVER_PORT] as? String {
            //self.serverPort = UInt16(serverPort)
            if let serverPort = serverPortString.toInt() {
                self.serverPort = UInt16(serverPort)
            }
        }
        
        // timeout
        //if let timeout = testParameters[PARAM_TIMEOUT]? as? Int {
        if let timeoutString = testParameters[PARAM_TIMEOUT] as? NSString {
            //self.timeout = UInt64(timeout)
            let timeout = timeoutString.longLongValue
            if (timeout > 0) {
                self.timeout = UInt64(timeout)
            }
        }
    }
    
    //
    
    /// returns the type of this test object
    func getType() -> QOSTestType! {
        return nil
    }
}

// MARK: Printable methods

///
//extension QOSTest : Printable {
//
//    ///
//    var description: String {
//        return "QOSTest(\(getType().rawValue)) [id: \(qosTestId), concurrencyGroup: \(concurrencyGroup), serverAddress: \(serverAddress), serverPort: \(serverPort), timeout: \(timeout)]"
//    }
//}
