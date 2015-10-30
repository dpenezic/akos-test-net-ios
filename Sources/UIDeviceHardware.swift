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
//  UIDeviceHardware.swift
//  RMBT
//
//  Created by Benjamin Pucher on 27.03.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import Foundation

// these values are stored on the server side and kept here just for backup

let IOS_MODEL_DICTIONARY = [
    "iPhone1,1": "iPhone 1G",
    "iPhone1,2": "iPhone 3G",
    "iPhone2,1": "iPhone 3GS",
    "iPhone3,1": "iPhone 4 (GSM)",
    "iPhone3,2": "iPhone 4 Rev A",
    "iPhone3,3": "iPhone 4 (CDMA)",
    "iPhone4,1": "iPhone 4S",
    "iPhone5,1": "iPhone 5 (GSM)",
    "iPhone5,2": "iPhone 5 (GSM+CDMA)",
    "iPhone5,3": "iPhone 5c (GSM)",
    "iPhone5,4": "iPhone 5c (GSM+CDMA)",
    "iPhone6,1": "iPhone 5s (GSM)",
    "iPhone6,2": "iPhone 5s (GSM+CDMA)",
    "iPhone7,1": "iPhone 6 Plus",
    "iPhone7,2": "iPhone 6",
    
    "iPod1,1": "iPod Touch 1G",
    "iPod2,1": "iPod Touch 2G",
    "iPod3,1": "iPod Touch 3G",
    "iPod4,1": "iPod Touch 4G",
    "iPod5,1": "iPod Touch 5G",
    
    "iPad1,1": "iPad",
    "iPad2,1": "iPad 2 (WiFi)",
    "iPad2,2": "iPad 2 (GSM)",
    "iPad2,3": "iPad 2 (CDMA)",
    "iPad2,4": "iPad 2 (WiFi)",
    "iPad2,5": "iPad Mini (WiFi)",
    "iPad2,6": "iPad Mini (GSM)",
    "iPad2,7": "iPad Mini (GSM+CDMA)",
    "iPad3,1": "iPad 3 (WiFi)",
    "iPad3,2": "iPad 3 (GSM+CDMA)",
    "iPad3,3": "iPad 3 (GSM)",
    "iPad3,4": "iPad 4 (WiFi)",
    "iPad3,5": "iPad 4 (GSM)",
    "iPad3,6": "iPad 4 (GSM+CDMA)",
    "iPad4,1": "iPad Air (WiFi)",
    "iPad4,2": "iPad Air (GSM)",
    "iPad4,3": "iPad Air (LTE)",
    "iPad4,4": "iPad Mini 2 (WiFi)",
    "iPad4,5": "iPad Mini 2 (GSM)",
    "iPad4,6": "iPad Mini 2 (LTE)",
    "iPad4,7": "iPad Mini 3 (WiFi)",
    "iPad4,8": "iPad Mini 3 (GSM)",
    "iPad4,9": "iPad Mini 3 (LTE)",
    "iPad5,3": "iPad Air 2 (WiFi)",
    "iPad5,4": "iPad Air 2 (GSM)",
    
    "i386":            "iOS Simulator",
    "x86_64":          "iOS Simulator",
    "Emulator x86_64": "iOS Simulator"
]

///
public class UIDeviceHardware {
    
    ///
    public class func platform() -> String {
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        
        var machine = [CChar](count: Int(size), repeatedValue: 0)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        
        return String.fromCString(machine)!
    }
    
    ///
    public class func platformString() -> String {
        return getDeviceNameFromPlatform(platform())
    }

    ///
    public class func getDeviceNameFromPlatform(platform: String) -> String {
        return IOS_MODEL_DICTIONARY[platform] ?? platform
    }
}
