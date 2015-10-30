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
//  CountDownLatch.swift
//  RMBT
//
//  Created by Benjamin Pucher on 12.02.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import Foundation

///
class CountDownLatch {

    ///
    private var count: UInt8 = 0
    
    ///
    private let mutualExclusionQueue = dispatch_queue_create("com.specure.rmbt.cdl.mutualExclusionQueue", DISPATCH_QUEUE_SERIAL)
    
    ///
    private let semaphore = dispatch_semaphore_create(0)
    
    ///
    convenience init() {
        self.init(1)
    }
    
    ///
    init(_ count: UInt8) {
        if (count > 0) {
            self.count = count
        }
    }
    
    ///
    func countDown() {
        dispatch_sync(mutualExclusionQueue) { // dispatch_sync
            if (self.count == 0) {
                return
            }
            
            self.count--
            if (self.count == 0) {
                logger.debug("signal semaphore")
                dispatch_semaphore_signal(self.semaphore)
            }
        }
    }

    ///
    func await(timeout: UInt64) -> Bool {
        let dt = dispatch_time(DISPATCH_TIME_NOW, Int64(timeout))
        let ret = dispatch_semaphore_wait(self.semaphore, dt)
        
        return (ret == 0)
    }
}
