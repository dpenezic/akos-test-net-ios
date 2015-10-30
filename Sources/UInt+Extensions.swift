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
//  UInt+Extensions.swift
//  RMBT
//
//  Created by Benjamin Pucher on 13.03.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import Foundation

///
extension UInt8 {
    
    ///
    public mutating func setBits(value: UInt8, pos: UInt8) {
        let length = UInt8(floor(log2(Double(value))) + 1)
        
        self.setBits(value, pos: pos, length: length)
    }
    
    ///
    public mutating func setBits(value: UInt8, pos: UInt8, length: UInt8) {
        let sizeMinusLength = UInt8(sizeofValue(self) * 8) - length
        let sizeMinusLengthMinusPos = sizeMinusLength - pos
        
        var bitmask: UInt8 = UInt8.max
        bitmask <<= pos
        bitmask >>= sizeMinusLength
        bitmask <<= sizeMinusLengthMinusPos
        bitmask = ~bitmask
        
        var field = (self & bitmask) | (value << sizeMinusLengthMinusPos)
        
        self = field
    }
}

///
extension UInt16 {
    
    ///
    public mutating func setBits(value: UInt8, pos: UInt16, length: UInt16) {        
        self.setBits(UInt16(value), pos: pos, length: length)
    }
    
    ///
    public mutating func setBits(value: UInt16, pos: UInt16) {
        let length = UInt16(floor(log2(Double(value))) + 1)
        
        self.setBits(value, pos: pos, length: length)
    }
    
    ///
    public mutating func setBits(value: UInt16, pos: UInt16, length: UInt16) {
        let sizeMinusLength = UInt16(sizeofValue(self) * 8) - length
        let sizeMinusLengthMinusPos = sizeMinusLength - pos
        
        var bitmask: UInt16 = UInt16.max
        bitmask <<= pos
        bitmask >>= sizeMinusLength
        bitmask <<= sizeMinusLengthMinusPos
        bitmask = ~bitmask
        
        var field = (self & bitmask) | (value << sizeMinusLengthMinusPos)
        
        self = field
    }
}