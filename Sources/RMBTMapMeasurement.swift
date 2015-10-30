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
//  RMBTMapMeasurement.swift
//  RMBT
//
//  Created by Benjamin Pucher on 30.03.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import Foundation

///
class RMBTMapMeasurement {
    
    ///
    var coordinate: CLLocationCoordinate2D

    ///
    var timeString: String
    
    ///
    var openTestUUID: String
    
    /// Arrays of RMBTHistoryResultItem
    var netItems = [RMBTHistoryResultItem]()
    
    ///
    var measurementItems = [RMBTHistoryResultItem]()
    
    ///
    init(response: [String:AnyObject]) {
        let lat = response["lat"] as! NSNumber
        let lon = response["lon"] as! NSNumber
        
        coordinate = CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue)
        
        timeString = response["time_string"] as! String
        openTestUUID = response["open_test_uuid"] as! String
        
        let responseMeasurement = response["measurement"] as! [[String:AnyObject]]
        for subresponse in responseMeasurement {
            measurementItems.append(RMBTHistoryResultItem(response: subresponse))
        }
        
        let responseNet = response["net"] as! [[String:AnyObject]]
        for subresponse in responseNet {
            netItems.append(RMBTHistoryResultItem(response: subresponse))
        }
    }
    
    ///
    func snippetText() -> String {
        var result: NSMutableString = ""
        
        for i in measurementItems {
            result.appendFormat("%@: %@\n", i.title, i.value)
        }
        
        for i in netItems {
            result.appendFormat("%@: %@\n", i.title, i.value)
        }
        
        return result as String
    }
}

///
extension RMBTMapMeasurement : Printable {
   
    ///
    var description: String {
        return String(format: "RMBTMapMarker (%f, %f)", coordinate.latitude, coordinate.longitude)
    }
}
