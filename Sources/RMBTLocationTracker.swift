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
//  RMBTLocationTracker.swift
//  RMBT
//
//  Created by Benjamin Pucher on 19.09.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

// TODO: how to make a static const with swift?

///
let RMBTLocationTrackerNotification: String = "RMBTLocationTrackerNotification"

///
@objc class RMBTLocationTracker : NSObject, CLLocationManagerDelegate {
   
    ///
    class var sharedTracker: RMBTLocationTracker {
        
        ///
        struct Singleton {
            
            ///
            static let instance = RMBTLocationTracker()
        }
        
        return Singleton.instance
    }
    
    ///
    let locationManager: CLLocationManager
    
    ///
    var authorizationCallback: RMBTBlock? // ?
    //let geocoder: CLGeocoder? // ?
    
    ///
    var location: CLLocation? {
        // TODO: if app is not allowed to get location this code fails! WORKS without ".copy() as? CLLocation", but are there any consequences?
        if let result:CLLocation = locationManager.location/*.copy() as? CLLocation*/ {
            if (CLLocationCoordinate2DIsValid(result.coordinate)) {
                return result
            }
        }
    
        return nil
    }
    
    ///
    override init() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 3.0
        // locationManager.requestAlwaysAuthorization()
        
        super.init()
        
        locationManager.delegate = self
    }
    
    ///
    func stop() {
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopUpdatingLocation()
    }
    
    ///
    func startIfAuthorized() -> Bool {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        // changed in Xcode 6.2: .Authorized not available anymore
        if (/*authorizationStatus == .Authorized ||*/ authorizationStatus == .AuthorizedWhenInUse || authorizationStatus == .AuthorizedAlways) {
            locationManager.startUpdatingLocation()
            return true
        }
        
        return false
    }
    
    ///
    func startAfterDeterminingAuthorizationStatus(callback: RMBTBlock) {
        if (startIfAuthorized()) {
            callback()
        } else if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined) {
            // Not determined yet
            authorizationCallback = callback
            
            if (locationManager.respondsToSelector("requestWhenInUseAuthorization")) {
                locationManager.requestWhenInUseAuthorization()
            } else {
                locationManager.startUpdatingLocation()
            }
        } else {
            //RMBTLog("User hasn't enabled or authorized location services") // TODO: use of unresolved identifier RMBTLog
            callback()
        }
    }
    
//    func startAfterDeterminingAuthorizationStatus_Location(callback: RMBTBlock) {
//        
//        if (startIfAuthorized()) {
//            
//            callback()
//        }
//        else /*(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined)*/ {
//            // Not determined yet
//            authorizationCallback = callback
//            
//            if (locationManager.respondsToSelector("requestWhenInUseAuthorization")) {
//                locationManager.requestWhenInUseAuthorization()
//            } else {
//                locationManager.startUpdatingLocation()
//            }
//        }
////        else {
////            //RMBTLog("User hasn't enabled or authorized location services") // TODO: use of unresolved identifier RMBTLog
////            callback()
////        }
//    }
    
    ///
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        NSNotificationCenter.defaultCenter().postNotificationName(RMBTLocationTrackerNotification, object: self, userInfo:["locations": locations])
    }
    
    ///
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (locationManager.respondsToSelector("requestWhenInUseAuthorization")) {
            locationManager.startUpdatingLocation()
        }
        
        if let authorizationCallback = self.authorizationCallback {
            authorizationCallback()
        }
    }
    
    ///
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        logger.error("Failed to obtain location \(error)")
    }
    
    ///
    func forceUpdate() {
        stop()
        startIfAuthorized()
    }
}
