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
//  QOSTestResult.swift
//  RMBT
//
//  Created by Benjamin Pucher on 09.12.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
class QOSTestResult {

    ///
    var resultDictionary = QOSTestResults()
    
    ///
    var testType: QOSTestType
    
    ///
    var fatalError = false
    
    ///
    var readOnly = false
    
    //
    
    ///
    init(type: QOSTestType) {
        self.testType = type
        
        resultDictionary["test_type"] = type.rawValue
    }
    
    ///
    func isEmpty() -> Bool {
        return !fatalError && resultDictionary.isEmpty
    }
    
    ///
    func freeze() {
        readOnly = true
    }
}

// MARK: Printable methods

///
extension QOSTestResult : Printable {
    
    ///
    var description: String {
        return "QOSTestResult: type: \(testType.rawValue), fatalError: \(fatalError), resultDictionary: \(resultDictionary)"
    }
}

// MARK: Custom set methods

///
extension QOSTestResult {

    ///
    func set(key: String, value: AnyObject?) {
        if (!readOnly) {
            resultDictionary[key] = jsonValueOrNull(value)
        }
    }
    
    // TODO: can this be improved?
    
    ///
    func set(key: String, number: UInt!) {
        set(key, value: (number != nil ? NSNumber(unsignedLong: number) : nil))
    }

    ///
    func set(key: String, number: UInt8!) {
        set(key, value: (number != nil ? NSNumber(unsignedChar: number) : nil))
    }

    ///
    func set(key: String, number: UInt16!) {
        set(key, value: (number != nil ? NSNumber(unsignedShort: number) : nil))
    }

    ///
    func set(key: String, number: UInt32!) {
        set(key, value: (number != nil ? NSNumber(unsignedInt: number) : nil))
    }

    ///
    func set(key: String, number: UInt64!) {
        set(key, value: (number != nil ? NSNumber(unsignedLongLong: number) : nil))
    }

    ///
    func set(key: String, number: Int!) {
        set(key, value: (number != nil ? NSNumber(long: number) : nil))
    }

    ///
    func set(key: String, number: Int8!) {
        set(key, value: (number != nil ? NSNumber(char: number) : nil))
    }

    ///
    func set(key: String, number: Int16!) {
        set(key, value: (number != nil ? NSNumber(short: number) : nil))
    }

    ///
    func set(key: String, number: Int32!) {
        set(key, value: (number != nil ? NSNumber(int: number) : nil))
    }
    
    ///
    func set(key: String, number: Int64!) {
        set(key, value: (number != nil ? NSNumber(longLong: number) : nil))
    }
}
