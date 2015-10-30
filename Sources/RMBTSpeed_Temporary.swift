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
//  RMBTSpeed_Temporary.swift
//  RMBT
//
//  Created by Benjamin Pucher on 02.04.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import Foundation

let GAUGE_PARTS = 4.25
let LOG10_MAX = log10(250.0)

///
func RMBTSpeedLogValue(kbps: UInt32) -> Double {
    let bps = UInt64(kbps * 1_000)
    var log: Double
    
    if (bps < 10_000) {
        log = 0
    } else {
        log = ((GAUGE_PARTS - LOG10_MAX) + log10(Double(bps) / Double(1e6))) / GAUGE_PARTS
    }
    
    //if (log > 1.0) {
    //    log = 1.0
    //}
    
    return log
}

///
func RMBTSpeedMbpsString(kbps: UInt32) -> String {
    let localizedMps = NSLocalizedString("test.speed.unit", value: "Mbps", comment: "Speed suffix")
    
    return String(format: "%@ %@", RMBTFormatNumber(NSNumber(double: Double(kbps) / 1000.0)), localizedMps)
}
