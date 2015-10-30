/*********************************************************************************
* Copyright 2013 appscape gmbh
* Copyright 2014-2015 SPECURE GmbH
* 
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
* 
*   http://www.apache.org/licenses/LICENSE-2.0
* 
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*********************************************************************************/

//
//  RMBTPing.swift
//  RMBT
//
//  Created by Benjamin Pucher on 28.03.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import Foundation

///
@objc class RMBTPing : NSObject { // : NSObject because of alloc]

    ///
    let serverNanos: UInt64
    
    ///
    let clientNanos: UInt64
    
    /// relative to test start
    let relativeTimestampNanos: UInt64
    
    //

    ///
    init(serverNanos: UInt64, clientNanos: UInt64, relativeTimestampNanos timestampNanos: UInt64) {
        self.serverNanos = serverNanos
        self.clientNanos = clientNanos
        self.relativeTimestampNanos = timestampNanos
        
        super.init()
    }

    ///
    func testResultDictionary() -> [String:NSNumber] {
        return [
            "value_server": NSNumber(unsignedLongLong: serverNanos),
            "value":        NSNumber(unsignedLongLong: clientNanos),
            "time_ns":      NSNumber(unsignedLongLong: relativeTimestampNanos)
        ]
    }
}

///
extension RMBTPing : Printable {
    
    ///
    override var description: String {
        //return String(format: "RMBTPing (server=%" PRIu64 ", client=%" PRIu64 ")", serverNanos, clientNanos)
        return "RMBTPing  (server = \(serverNanos), client = \(clientNanos))"
    }
}
