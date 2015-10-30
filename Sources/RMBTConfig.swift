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
//  RMBTConfig.swift
//  RMBT
//
//  Created by Tomáš Baculák on 14/01/15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

// MARK: - Fixed test parameters

/// Maximum number of tests to perform in loop mode
let RMBT_TEST_LOOPMODE_LIMIT = 100

///
let RMBT_TEST_LOOPMODE_WAIT_BETWEEN_RETRIES_S = 5

///
let RMBT_TEST_PRETEST_MIN_CHUNKS_FOR_MULTITHREADED_TEST = 4

///
let RMBT_TEST_PRETEST_DURATION_S = 2.0

///
let RMBT_TEST_PING_COUNT = 10

///
let RMBT_CONTROL_SERVER_PATH = "/RMBTControlServer"

///
let RMBT_MAP_SERVER_PATH = "/RMBTMapServer"

//////////
// FIXME: Please provide correct server URLs. Change localhost to your server name or address.
//////////

// MARK: - Default control server URLs

let RMBT_CONTROL_SERVER_URL        = "https://localhost\(RMBT_CONTROL_SERVER_PATH)"
let RMBT_CONTROL_SERVER_IPV4_URL   = "https://localhost\(RMBT_CONTROL_SERVER_PATH)"
let RMBT_CONTROL_SERVER_IPV6_URL   = "https://localhost\(RMBT_CONTROL_SERVER_PATH)"

// MARK:- Other URLs used in the app

let RMBT_URL_HOST = "https://localhost"

/// Note: $lang will be replaced by the device language (de, en, sl, etc.)
let RMBT_STATS_URL       = "\(RMBT_URL_HOST)/$lang/statistics"
let RMBT_HELP_URL        = "\(RMBT_URL_HOST)/$lang/help"
let RMBT_HELP_RESULT_URL = "\(RMBT_URL_HOST)/$lang/help"

let RMBT_PRIVACY_TOS_URL = "\(RMBT_URL_HOST)/$lang/tc"

//

let RMBT_ABOUT_URL       = "https://specure.com"
let RMBT_PROJECT_URL     = RMBT_URL_HOST
//let RMBT_PROJECT_EMAIL   = "nettest@specure.com"
let RMBT_PROJECT_EMAIL   = "test@example.com"

let RMBT_REPO_URL        = "https://specure.com"
let RMBT_DEVELOPER_URL   = "https://specure.com"

// MARK: - Map options

let RMBT_MAP_SERVER_URL = "https://localhost\(RMBT_MAP_SERVER_PATH)"

/// Initial map center coordinates and zoom level
let RMBT_MAP_INITIAL_LAT: CLLocationDegrees = 46.049053 // Slovenska cesta 15, 1000 Ljubljana, Slovenia
let RMBT_MAP_INITIAL_LNG: CLLocationDegrees = 14.501973

let RMBT_MAP_INITIAL_ZOOM: Float = 12.0

/// Zoom level to use when showing a test result location
let RMBT_MAP_POINT_ZOOM: Float = 12.0

/// In "auto" mode, when zoomed in past this level, map switches to points
let RMBT_MAP_AUTO_TRESHOLD_ZOOM: Float = 12.0

// Google Maps API Key

//////////
// FIXME: Please supply a valid Google Maps API Key. See https://developers.google.com/maps/documentation/ios/start#the_google_maps_api_key
//////////

let RMBT_GMAPS_API_KEY = ""

// MARK: - Misc

/// Current TOS version. Bump to force displaying TOS to users again.
let RMBT_TOS_VERSION = 1

///////////////////////////////
// COLORS
///////////////////////////////

let RMBT_DARK_COLOR     = UIColor(rgb: 0x001028) //UIColor(red: 0.0, green: 0.0666, blue: 0.16, alpha: 1)
let RMBT_TINT_COLOR     = UIColor(rgb: 0x00ABE7) //UIColor(red: 0.0, green: 0.671, blue: 0.906, alpha: 1)

// start button
let TEST_START_BUTTON_TEXT_COLOR                = UIColor(rgb: 0x2F4867) //UIColor.whiteColor()
let TEST_START_BUTTON_BACKGROUND_COLOR          = UIColor(rgb: 0xAAC0E9)
let TEST_START_BUTTON_DISABLED_BACKGROUND_COLOR = UIColor(rgb: 0x555555)

// initial view background (incl. gradient)
let INITIAL_VIEW_BACKGROUND_COLOR           = UIColor.whiteColor()
let INITIAL_BOTTOM_VIEW_BACKGROUND_COLOR    = UIColor(rgb: 0x2F4867)

let INITIAL_VIEW_USE_GRADIENT = true

let INITIAL_VIEW_GRADIENT_TOP_COLOR     = UIColor(rgb: 0x2F4867)
let INITIAL_VIEW_GRADIENT_BOTTOM_COLOR  = UIColor(rgb: 0x6D829D)

//

let INITIAL_SCREEN_TEXT_COLOR = UIColor.whiteColor()

let PROGRESS_INDICATOR_FILL_COLOR = UIColor.whiteColor() // UIColor.blackColor()

//

let COLOR_LIGHT_BLUE    = UIColor(rgb: 0xAAC0E9) //UIColor(red: 170/255, green: 192/255, blue: 233/255, alpha: 1)

let TEST_TABLE_BACKGROUND_COLOR = UIColor(rgb: 0x0C0A22)

let BACKGROUND_COLOR    = UIColor(rgb: 0x2D313A) //UIColor(red: 45/255, green: 49/255, blue: 58/255, alpha: 1)
let TEXT_LIGHT_COLOR    = UIColor.whiteColor() // UIColor(rgb: 0xFFFFFF)
let TEXT_MEDIUM_COLOR   = UIColor(rgb: 0xB6B6B6) //UIColor(red: 182/255, green: 182/255, blue: 182/255, alpha: 1)
let FRAMES_LINES_COLOR  = UIColor(rgb: 0xABADB0) //UIColor(red: 171/255, green: 173/255, blue: 176/255, alpha: 1)
let COLOR_CHECK_YELLOW  = UIColor(rgb: 0xFEC826) //UIColor(red: 254/255, green: 200/255, blue: 38/255, alpha: 1)
let COLOR_CHECK_GREEN   = UIColor(rgb: 0x59B100) //UIColor(red: 89/255, green: 177/255, blue: 0/255, alpha: 1)
let COLOR_CHECK_RED     = UIColor(rgb: 0xB22D00) //UIColor(red: 178/255, green: 45/255, blue: 0/255, alpha: 1)

let COLOR_GRAY          = UIColor(rgb: 0x555555) //UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1)
let COLOR_GRAY_HISTORY  = UIColor(rgb: 0x555555) //UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1)

let PROGRESS_COLOR      = UIColor(rgb: 0xAAC0E9) //UIColor(red: 170/255, green: 192/255, blue: 233/255, alpha: 1)

// MARK: - Font options

let MAIN_FONT = "LaoSangamMN"
