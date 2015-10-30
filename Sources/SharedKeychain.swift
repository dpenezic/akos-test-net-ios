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
//  SharedKeychain.swift
//  RMBT
//
//  Created by Benjamin Pucher on 10.02.15.
//  Copyright (c) 2015 SPECURE GmbH. All rights reserved.
//

import Foundation
import Security

///
public class SharedKeychain {

    ///
    private init() {
        
    }
    
// MARK: get functions
    
    ///
    public class func getBool(key: String) -> Bool? {
        if let stringValue = get(key) {
            return stringValue == "true"
        }
        
        return nil
    }
    
    ///
    public class func get(key: String) -> String? {
        if let currentData = getData(key) {
            return NSString(data: currentData, encoding: NSUTF8StringEncoding) as String?
        }
        
        return nil
    }
    
    ///
    public class func getData(key: String) -> NSData? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: Unmanaged<AnyObject>?
        let status: OSStatus = SecItemCopyMatching(query, &dataTypeRef)
        
        if status == noErr {
            if let currentDataTypeRef = dataTypeRef {
                return currentDataTypeRef.takeRetainedValue() as? NSData
            }
        }
        
        return nil
    }
    
// MARK: set functions
    
    ///
    public class func set(key: String, value: Bool) -> Bool {
        return set(key, value: "\(value)")
    }
    
    ///
    public class func set(key: String, value: Int) -> Bool {
        return set(key, value: "\(value)")
    }
    
    ///
    public class func set(key: String, value: String) -> Bool {
        if let currentData = value.dataUsingEncoding(NSUTF8StringEncoding) {
            return set(key, value: currentData)
        }
        return false
    }
    
    ///
    public class func set(key: String, value: NSData) -> Bool {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: value
        ]
        
        SecItemDelete(query as CFDictionaryRef)
        
        let status: OSStatus = SecItemAdd(query as CFDictionaryRef, nil)
        return status == noErr
    }
    
// MARK: delete functions
    
    ///
    public class func delete(key: String) -> Bool {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status: OSStatus = SecItemDelete(query as CFDictionaryRef)
        return status == noErr
    }
    
// MARK: clear functions
    
    ///
    public class func clear() -> Bool {
        let query = [
            kSecClass as String: kSecClassGenericPassword
        ]
        
        let status: OSStatus = SecItemDelete(query as CFDictionaryRef)
        return status == noErr
    }
}
