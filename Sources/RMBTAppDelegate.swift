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
//  RMBTAppDelegate.swift
//  RMBT
//
//  Created by Benjamin Pucher on 19.09.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

import Foundation

///
@UIApplicationMain
class RMBTAppDelegate : UIResponder, UIApplicationDelegate {

    ///
    var window: UIWindow?
    
    ///
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        LogConfig.initLoggingFramework()
        
        checkFirstLaunch()
        
        logger.debug("START APP")
        
        setDefaultUserAgent()
        
        // Supply Google Maps API Key only once during whole app lifecycle
        GMSServices.provideAPIKey(RMBT_GMAPS_API_KEY)
        
        applyAppearance()
        onStart(true)
        
        return true
    }
    
    ///
    func applicationDidEnterBackground(application: UIApplication) {
        RMBTLocationTracker.sharedTracker.stop()
    }
    
    ///
    func applicationWillEnterForeground(application: UIApplication) {
        onStart(false)
    }
    
    ///
    func checkFirstLaunch() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if (!userDefaults.boolForKey("was_launched_once")) {
            logger.info("FIRST LAUNCH OF APP")
            
            userDefaults.setBool(true, forKey: "was_launched_once")
            
            firstLaunch(userDefaults)
            
            userDefaults.synchronize()
        }
    }
    
    ///
    func firstLaunch(userDefaults: NSUserDefaults) {
        //userDefaults.setBool(true, forKey: "publishPublicData")
        RMBTSettings.sharedSettings().publishPublicData = true
        logger.debug("setting publishPublicData to true")
    }
    
    ///
    func onStart(isNewlyLaunched: Bool) {
        checkDevMode()
        
        logger.debug("App started")
    
        // If user has authorized location services, we should start tracking location now, so that when test starts,
        // we already have a more accurate location
        RMBTLocationTracker.sharedTracker.startIfAuthorized()
        
        //// TODO: let control server initialize
        //ControlServer.sharedControlServer.systemInfoParams()
        ////
        
        let tos: RMBTTOS = RMBTTOS()
        
        if (tos.isCurrentVersionAccepted()) {
            checkNews()
        } else if (isNewlyLaunched) {
            
            // Re-check after TOS gets accepted, but don't re-add listener on every foreground
            tos.bk_addObserverForKeyPath("lastAcceptedVersion", task: { (target: AnyObject!) -> Void in
                //RMBTLog("TOS accepted, checking news...");
                self.checkNews()
            }) // TODO: is this block working? is this keypath working?
        }
    }
    
    ///
    func checkNews() {
        ControlServer.sharedControlServer.getNews({ (newsObj: AnyObject!) in
            let news = newsObj as! [RMBTNews]
            
            for n in news {
                UIAlertView.bk_showAlertViewWithTitle(
                    n.title,
                    message: n.text,
                    cancelButtonTitle: NSLocalizedString("general.alertview.dismiss", value: "Dismiss", comment: "News alert view button"),
                    otherButtonTitles: nil,
                    handler: nil)
            }
        })
    }
    
    ///
    private func checkDevMode() {
        let RMBT_DEV_MODE_ENABLED_KEY = "RMBT_DEV_MODE_ENABLED"
        let enabled = SharedKeychain.getBool(RMBT_DEV_MODE_ENABLED_KEY)
        
        RMBTSettings.sharedSettings().debugUnlocked = (enabled != nil && enabled!)
        logger.debug("DEBUG UNLOCKED: \(RMBTSettings.sharedSettings().debugUnlocked)")
    }
    
    ///
    private func setDefaultUserAgent() {
        let info = NSBundle.mainBundle().infoDictionary!

        let bundleName = (info["CFBundleName"] as! String).stringByReplacingOccurrencesOfString(" ", withString: "")
        let bundleVersion = info["CFBundleShortVersionString"] as! String
        
        let iosVersion = UIDevice.currentDevice().systemVersion

        let lang: String = RMBTPreferredLanguage() ?? "en"
        var locale = NSLocale.canonicalLanguageIdentifierFromString(lang)
        
        if let countryCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String {
            locale += "_\(countryCode)"
        }
        
        // set global user agent
        let specureUserAgent = "SpecureNetTest/2.0 (iOS; \(locale); \(iosVersion)) \(bundleName)/\(bundleVersion)"
        NSUserDefaults.standardUserDefaults().registerDefaults(["UserAgent": specureUserAgent])
        
        logger.info("USER AGENT: \(specureUserAgent)")
    }
    
    ///
    func applyAppearance() {
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // Background color
        UINavigationBar.appearance().barTintColor = RMBT_DARK_COLOR

        // Tint color
        UINavigationBar.appearance().tintColor = RMBT_TINT_COLOR
        UITabBar.appearance().tintColor = RMBT_TINT_COLOR
        
        // Text color
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: TEXT_LIGHT_COLOR]
    }    
}
