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
//  RMBTHistoryResult.swift
//  RMBT
//
//  Created by Benjamin Pucher on 31.03.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import Foundation

///
@objc class RMBTHistoryResultItem {
    
    ///
    let title: String
    
    ///
    let value: String
    
    ///
    let classification: Int
    
    //
    
    ///
    init(response: [String:AnyObject]) {
        self.title = response["title"] as! String
        self.value = response["value"]!.description
        
        if let responseClassification = response["classification"] as? NSNumber {
            self.classification = responseClassification.unsignedIntegerValue
        } else {
            self.classification = -1
        }
    }
}

///
enum RMBTHistoryResultDataState {
    case Index
    case Basic
    case Full
}

///
@objc class RMBTHistoryResult : NSObject {

    ///
    var dataState: RMBTHistoryResultDataState = .Index

    var uuid: String!
    var timestamp: NSDate!
    var timeString: String = ""
    var downloadSpeedMbpsString: String!
    var uploadSpeedMbpsString: String!
    var shortestPingMillisString: String!
    var deviceModel: String!
    var coordinate: CLLocationCoordinate2D!
    var locationString: String!
    
    /// "WLAN", "2G/3G" etc.
    let networkTypeServerDescription: String!

    /// Available in basic details
    var networkType: RMBTNetworkType!
    var shareText: String!
    var shareURL: NSURL!
    var netItems = [RMBTHistoryResultItem]()
    var measurementItems = [RMBTHistoryResultItem]()
    
    /// Full details
    var fullDetailsItems = [RMBTHistoryResultItem]()
    
    //
    
    ///
    private var currentYearFormatter = NSDateFormatter()
    
    ///
    private var previousYearFormatter = NSDateFormatter()
    
    //
    
    ///
    init(response: [String:AnyObject]) { // this methods takes only ["test_uuid": ...] after a new test...
        downloadSpeedMbpsString = response["speed_download"] as? String
        uploadSpeedMbpsString = response["speed_upload"] as? String
        shortestPingMillisString = response["ping_shortest"] as? String
        
        // Note: here network_type is a string with full description (i.e. "WLAN") and in the basic details response it's a numeric code
        networkTypeServerDescription = response["network_type"] as? String
        uuid = response["test_uuid"] as? String
        
        if let model = response["model"] as? String {
            self.deviceModel = UIDeviceHardware.getDeviceNameFromPlatform(model)
        }/* else {
            self.deviceModel = "Unknown" // TODO: translate?
        }*/
        
        if let time = response["time"] as? NSNumber {
            let t: NSTimeInterval = time.doubleValue / 1000.0
            self.timestamp = NSDate(timeIntervalSince1970: t)
        }

        coordinate = kCLLocationCoordinate2DInvalid
        
        //
        
        currentYearFormatter.dateFormat = "MMM dd HH:mm"
        previousYearFormatter.dateFormat = "MMM dd YYYY"
        
        super.init()
    }

    ///
    func formattedTimestamp() -> String {
        let historyDateComponents = NSCalendar.currentCalendar().components(.DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit, fromDate: timestamp)
        let currentDateComponents = NSCalendar.currentCalendar().components(.DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit, fromDate: NSDate())
        
        var result = ""
        
        if (currentDateComponents.year == historyDateComponents.year) {
            result = currentYearFormatter.stringFromDate(timestamp)
        } else {
            result = previousYearFormatter.stringFromDate(timestamp)
        }
        
        // For some reason MMM on iOS7 returns "Aug." with a trailing dot, let's strip the dot manually
        return result.stringByReplacingOccurrencesOfString(".", withString: "")
    }

    ///
    func ensureBasicDetails(success: EmptyCallback) { // TODO: rewrite, always get full results...
        if (dataState != .Index) {
            success()
        } else {
            ControlServer.sharedControlServer.getHistoryResultWithUUID(uuid, fullDetails: false, success: { response in
                
                if let networkType = response["network_type"] as? NSNumber {
                    self.networkType = RMBTNetworkTypeMake(networkType.integerValue)//RMBTNetworkType(rawValue: networkType.integerValue)!
                }
                
                self.shareURL = nil
                if let shareText = response["share_text"] as? String {
                    // http://stackoverflow.com/questions/14226300/i-am-getting-an-implicit-conversion-from-enumeration-type-warning-in-xcode-for
                    // TODO: verify if fixed on iOS7
                    
                    if let linkDetector = NSDataDetector(types: NSTextCheckingType.Link.rawValue, error: nil) {
                        let matches = linkDetector.matchesInString(shareText, options: NSMatchingOptions(0), range: NSRange(location: 0, length:count(shareText)))
                        
                        if (matches.count > 0) {
                            let r = matches.last! as! NSTextCheckingResult
                            
                            assert(r.resultType == NSTextCheckingType.Link, "Invalid match type")
                            
                            self.shareText = (shareText as NSString).stringByReplacingCharactersInRange(r.range, withString: "")
                            self.shareURL = r.URL
                        }
                    }
                }
                
                for r in (response["net"] as! [[String:AnyObject]]) {
                    self.netItems.append(RMBTHistoryResultItem(response: r))
                }
                
                for r in (response["measurement"] as! [[String:AnyObject]]) {
                    self.measurementItems.append(RMBTHistoryResultItem(response: r))
                }
                
                // TODO: rewrite with double if-let statement when using swift 1.2
                if let geoLat = response["geo_lat"] as? NSNumber {
                    if let geoLon = response["geo_long"] as? NSNumber {
                        self.coordinate = CLLocationCoordinate2DMake(geoLat.doubleValue, geoLon.doubleValue)
                    }
                }
                
                if let timeString = response["time_string"] as? String {
                    self.timeString = timeString
                }
                
                self.locationString = response["location"] as? String
                
                self.dataState = .Basic
                
                success()
                
            }, error: { error, info in
                // TODO: handle error
            })
        }
    }

    ///
    func ensureFullDetails(success: EmptyCallback) {
        if (dataState == .Full) {
            success()
        } else {
            ControlServer.sharedControlServer.getHistoryResultWithUUID(uuid, fullDetails: true, success: { response in

                for r in (response as! [[String:AnyObject]]) {
                    self.fullDetailsItems.append(RMBTHistoryResultItem(response: r))
                }
                
                self.dataState = .Full

                success()
                
            }, error: { error, info in
                // TODO: handle error
            })
        }
    }
}
