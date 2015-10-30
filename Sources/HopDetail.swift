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
//  HopDetail.swift
//  RMBT
//
//  Created by Benjamin Pucher on 17.02.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import Foundation

///
public /*struct*/class HopDetail : NSObject {
    //    var transmitted: UInt64
    //    var received: UInt64
    //    var errors: UInt64
    //    var packetLoss: UInt64
    
    ///
    private var timeTries = [UInt64]()
    
    ///
    public var time: UInt64 { // return middle value
        var t: UInt64 = 0
        
        for ti: UInt64 in timeTries {
            t += ti
        }
        
        return t / UInt64(timeTries.count)
        //return UInt64.divideWithOverflow(t, UInt64(timeTries.count)).0
    }
    
    ///
    public var fromIp: String!
    
    ///
    public func addTry(time: UInt64) {
        timeTries.append(time)
    }
    
    ///
    public func getAsDictionary() -> [String:AnyObject] {
        return [
            "host": jsonValueOrNull(fromIp),
            "time": NSNumber(unsignedLongLong: time)
        ]
    }
}

///
extension HopDetail : Printable {
    
    ///
    public override var description: String {
        return "HopDetail: fromIp: \(fromIp), time: \(time)"
    }
}
