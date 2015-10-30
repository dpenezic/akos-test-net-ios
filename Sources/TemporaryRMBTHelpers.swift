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
//  TemporaryRMBTHelpers.swift
//  RMBT
//
//  Created by Benjamin Pucher on 02.04.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import Foundation

/// taken from http://stackoverflow.com/questions/24051904/how-do-you-add-a-dictionary-of-items-into-another-dictionary
/// this should be in the swift standard library!
//func +=<K, V>(inout left: Dictionary<K, V>, right: Dictionary<K, V>) -> Dictionary<K, V> {
//    for (k, v) in right {
//        left.updateValue(v, forKey: k)
//    }
//
//    return left
//}
func +=<K, V>(inout left: [K:V], right: [K:V]) {
    for (k, v) in right {
        left[k] = v
    }
}

/// Returns a string containing git commit, branch and commit count from Info.plist fields written by the build script
func RMBTBuildInfoString() -> String {
    let info = NSBundle.mainBundle().infoDictionary!

    let gitBranch       = info["GitBranch"] as! String
    let gitCommitCount  = info["GitCommitCount"] as! String
    let gitCommit       = info["GitCommit"] as! String

    return "\(gitBranch)-\(gitCommitCount)-\(gitCommit)"
    //return String(format: "%@-%@-%@", info["GitBranch"], info["GitCommitCount"], info["GitCommit"])
}

///
func RMBTBuildDateString() -> String {
    let info = NSBundle.mainBundle().infoDictionary!

    return info["BuildDate"] as! String
}

func RMBTPreferredLanguage() -> String? {
    let preferredLanguages = NSLocale.preferredLanguages()

    if (preferredLanguages.count < 1) {
        return nil
    }

    return preferredLanguages[0] as? String
}

/// Replaces $lang in template with the current locale.
/// Fallback to english for non-translated languages is done on the server side.
func RMBTLocalizeURLString(urlString: NSString) -> String {
    let r = urlString.rangeOfString("$lang")

    if (r.location == NSNotFound) {
        return urlString as String // return same string if no $lang was found
    }

    let lang = RMBTPreferredLanguage() ?? "en"

    let replacedURL = urlString.stringByReplacingOccurrencesOfString("$lang", withString: lang)

    //logger.debug("replaced $lang in string, output: \(replacedURL)")

    return replacedURL
}

///
func RMBTIsRunningOnWideScreen() -> Bool{
    return (UIScreen.mainScreen().bounds.size.height >= 568)
}

// Returns bundle name from Info.plist (i.e. RTR-NetTest or RTR-Netztest)
func RMBTAppTitle() -> String {
    let info = NSBundle.mainBundle().infoDictionary!

    return info["CFBundleDisplayName"] as! String
}

///
//func RMBTValueOrNull(value: AnyObject!) -> AnyObject {
//    return (value != nil) ? value : NSNull()
//}

///
//func RMBTValueOrString(value: AnyObject!, result: String) -> AnyObject {
//    return (value != nil) ? value : result
//}
