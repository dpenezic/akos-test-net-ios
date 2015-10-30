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
//  CLLocation+RMBTFormat.swift
//  RMBT
//
//  Created by Benjamin Pucher on 24.09.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

protocol RMBTFormat {
    // - (NSString*)rmbtFormattedString;
}

/*
static NSDateFormatter *timestampFormatter = nil;
static dispatch_once_t onceToken;
dispatch_once(&onceToken, ^{
    timestampFormatter = [[NSDateFormatter alloc] init];
    [timestampFormatter setDateFormat:@"HH:mm:ss"];
});
*/
//let _cllocation_timestampFormatter: NSDateFormatter = NSDateFormatter()
//_cllocation_timestampFormatter.dateFormat = "HH:mm:ss"

///
extension CLLocation : RMBTFormat {

    ///
    func rmbtFormattedString() -> String {
        let _cllocation_timestampFormatter: NSDateFormatter = NSDateFormatter()
        _cllocation_timestampFormatter.dateFormat = "HH:mm:ss"
        
        var latSeconds: Int = Int(round(abs(self.coordinate.latitude * 3600)))
        let latDegrees = latSeconds / 3600
        latSeconds = latSeconds % 3600
        let latMinutes: CLLocationDegrees = Double(latSeconds) / 60.0
        
        var longSeconds: Int = Int(round(abs(self.coordinate.longitude * 3600)))
        var longDegrees: Int = longSeconds / 3600
        longSeconds = longSeconds % 3600
        let longMinutes: CLLocationDegrees = Double(longSeconds) / 60.0
        
        let latDirection: String = (self.coordinate.latitude  >= 0) ? "N" : "S"
        let longDirection: String = (self.coordinate.longitude >= 0) ? "E" : "W"
        
        return String(format: "%@ %ld° %.3f' %@ %ld° %.3f' (+/- %.0fm)\n@%@", latDirection, latDegrees as CLong, latMinutes, longDirection, longDegrees as CLong, longMinutes, self.horizontalAccuracy, _cllocation_timestampFormatter.stringFromDate(self.timestamp))
    }
    
    ///
    func rmbtFormattedArray() -> Array<String> {
        let _cllocation_timestampFormatter: NSDateFormatter = NSDateFormatter()
        _cllocation_timestampFormatter.dateFormat = "HH:mm:ss"
        
        var latSeconds: Int = Int(round(abs(self.coordinate.latitude * 3600)))
        let latDegrees = latSeconds / 3600
        latSeconds = latSeconds % 3600
        let latMinutes: CLLocationDegrees = Double(latSeconds) / 60.0
        
        var longSeconds: Int = Int(round(abs(self.coordinate.longitude * 3600)))
        var longDegrees: Int = longSeconds / 3600
        longSeconds = longSeconds % 3600
        let longMinutes: CLLocationDegrees = Double(longSeconds) / 60.0
        
        let latDirection: String = (self.coordinate.latitude  >= 0) ? "N" : "S"
        let longDirection: String = (self.coordinate.longitude >= 0) ? "E" : "W"
        
        let position = String(format: "%@ %ld° %.3f' %@ %ld° %.3f'", latDirection, latDegrees as CLong, latMinutes, longDirection, longDegrees as CLong, longMinutes)
        let longMin = String(format: "(+/- %.0fm)", self.horizontalAccuracy)
        let locAltitude = String(format: "%.0f m", self.altitude)  // ("\(self.altitude) m")
        
        var locationItems: [String] = [position, longMin, _cllocation_timestampFormatter.stringFromDate(self.timestamp), locAltitude]
        
        return locationItems
    }
    
    ///
    func paramsDictionary() -> NSDictionary {
        return [
            "long":     NSNumber(double: coordinate.longitude),
            "lat":      NSNumber(double: coordinate.latitude),
            "time":     RMBTTimestampWithNSDate(timestamp),
            "accuracy": NSNumber(double: horizontalAccuracy),
            "altitude": NSNumber(double: altitude),
            "speed":    NSNumber(double: (speed > 0 ? self.speed : 0.0))
        ]
    }
}
