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
//  UIColor+Hex.swift
//  RMBT
//
//  Created by Benjamin Pucher on 20.03.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import Foundation

///
extension UIColor {
    
    ///
    var rgbaValue: String {
        let rgbaComponents = self.rgbaComponents()
        return String(format: "#%02lX%02lX%02lX%02lX", rgbaComponents[0], rgbaComponents[1], rgbaComponents[2], rgbaComponents[3])
    }
    
    ///
    var rgbValue: String {
        let rgbaComponents = self.rgbaComponents()
        return String(format: "#%02lX%02lX%02lX", rgbaComponents[0], rgbaComponents[1], rgbaComponents[2])
    }
    
    ///
    convenience init(rgba: UInt32) {
        let r = (rgba >> 24) & 0xFF
        let g = (rgba >> 16) & 0xFF
        let b = (rgba >> 8) & 0xFF
        let a = (rgba) & 0xFF
        
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
    }
    
    ///
    convenience init(rgb: UInt32, alpha: CGFloat) {
        let r = (rgb >> 16) & 0xFF
        let g = (rgb >> 8) & 0xFF
        let b = (rgb) & 0xFF
        
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    
    ///
    convenience init(rgb: UInt32) {
        self.init(rgb: rgb, alpha: 1)
    }
    
    ///
    private func rgbaComponents() -> [Int] {
        let colorSpace = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor))
        var p = CGColorGetComponents(self.CGColor)
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        if (colorSpace.value == kCGColorSpaceModelMonochrome.value) {
            r = p[0]
            g = p[0]
            b = p[0]
            a = p[1]
            
        } else if (colorSpace.value == kCGColorSpaceModelRGB.value) {
            r = p[0]
            g = p[1]
            b = p[2]
            a = p[3]
        }
        
        return [lroundf(Float(r) * 255), lroundf(Float(g) * 255), lroundf(Float(b) * 255), lroundf(Float(a) * 255)]
    }
}
