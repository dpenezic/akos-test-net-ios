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
//  SwiftExactTime.swift
//  RMBT
//
//  Created by Benjamin Pucher on 20.01.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import Foundation

///
func currentTimeMillis() -> UInt64 {
    //return UInt64(NSDate().timeIntervalSince1970 * 1000)
    return nanoTime() / NSEC_PER_MSEC // much faster!
}

///
func nanoTime() -> UInt64 {
    return ticksToNanoTime(getCurrentTimeTicks())
}

///
func getCurrentTimeTicks() -> UInt64 {
    return mach_absolute_time()
}

///
func ticksToNanoTime(ticks: UInt64) -> UInt64 {
    var sTimebaseInfo: mach_timebase_info = mach_timebase_info(numer: 0, denom: 0)
    mach_timebase_info(&sTimebaseInfo)
    
    let nano: UInt64 = (ticks * UInt64(sTimebaseInfo.numer) / UInt64(sTimebaseInfo.denom))
    
    return nano
}

///
func getTimeDifferenceInNanoSeconds(fromTicks: UInt64) -> UInt64 {
    let to: UInt64 = mach_absolute_time()
    let elapsed: UInt64 = to - fromTicks
    
    return ticksToNanoTime(elapsed)
}