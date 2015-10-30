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
//  GCDTimer.swift
//  RMBT
//
//  Created by Benjamin Pucher on 09.02.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import Foundation

///
class GCDTimer {
   
    typealias TimerCallback = () -> ()
    
    ///
    var timerCallback: TimerCallback?
    
    ///
    var interval: Double?
    
    ///
    private var timerSource: dispatch_source_t!
    
    ///
    private let timerQueue: dispatch_queue_t
    
    ///
    init() {
        timerQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) // 0?
    }
    
    ///
    deinit {
        stop()
    }
    
    ///
    func start() {
        if let interval = self.interval {
            stop() // stop any previous timer
            
            // start new timer
            timerSource = createTimer(interval, timerQueue: timerQueue) {
                logger.debug("timer fired")
                self.stop()
                
                self.timerCallback?()
            }
        }
    }
    
    ///
    func stop() {
        if (timerSource != nil) {
            dispatch_source_cancel(timerSource)
        }
    }
    
    ///
    private func createTimer(interval: Double, timerQueue: dispatch_queue_t, block: dispatch_block_t) -> dispatch_source_t {
        let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, timerQueue) // 0?, 0?
        if (timer != nil) {
            let nsecPerSec = Double(NSEC_PER_SEC)
            let dt = dispatch_time(DISPATCH_TIME_NOW, Int64(interval * nsecPerSec))
            
            dispatch_source_set_timer(timer, dt, /*UInt64(interval * nsecPerSec)*/DISPATCH_TIME_FOREVER, /*UInt64(nsecPerSec / 10)*/0)
            
            dispatch_source_set_event_handler(timer, block)
            dispatch_resume(timer)
        }
        
        return timer
    }
}