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
//  RMBTTOS.swift
//  RMBT
//
//  Created by Benjamin Pucher on 18.09.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
@objc class RMBTTOS : NSObject {
    
    ///
    private let TOS_VERSION_KEY: String = "tos_version"
    
    ///
    dynamic var lastAcceptedVersion: UInt // UInt correct?
    
    ///
    var currentVersion: UInt // UInt correct?
    
    ///
    class var sharedTOS: RMBTTOS {
        
        ///
        struct Singleton {
            
            ///
            static let instance = RMBTTOS()
        }

        return Singleton.instance
    }
    
    ///
    override init() {
        if let tosVersionNumber = NSUserDefaults.standardUserDefaults().objectForKey(TOS_VERSION_KEY) as? UInt {
            self.lastAcceptedVersion = tosVersionNumber
        } else {
            self.lastAcceptedVersion = 0
        }
        
        self.currentVersion = UInt(RMBT_TOS_VERSION)
        
        super.init()
    }
    
    ///
    func isCurrentVersionAccepted() -> Bool {
        return self.lastAcceptedVersion >= UInt(currentVersion) // is this correct?
    }
    
    ///
    func acceptCurrentVersion() {
        lastAcceptedVersion = UInt(currentVersion)
        
        NSUserDefaults.standardUserDefaults().setObject(lastAcceptedVersion, forKey: TOS_VERSION_KEY)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    ///
    func declineCurrentVersion() {
        lastAcceptedVersion = UInt(currentVersion) > 0 ? UInt(currentVersion) - 1 : 0 // go to previous version or 0 if not accepted
        
        NSUserDefaults.standardUserDefaults().setObject(lastAcceptedVersion, forKey: TOS_VERSION_KEY)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}
