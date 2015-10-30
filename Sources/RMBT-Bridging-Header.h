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
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#include <ifaddrs.h>

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>

// for md5 etc.
#import <CommonCrypto/CommonCrypto.h>

#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/BlocksKit+UIKit.h>
#import <BlocksKit/BlocksKit+MessageUI.h>

#import <GoogleMaps/GoogleMaps.h>

// Needed by AFNetworking
#import <MobileCoreServices/MobileCoreServices.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import <AFNetworking/AFNetworking.h>

#import <TUSafariActivity/TUSafariActivity.h>

#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>

#import <BCGenieEffect/UIView+Genie.h>

#import <KINWebBrowser/KINWebBrowserViewController.h>

#import "SwiftTryCatch.h"

#import "RMBTBlockTypes.h"

#import "RMBTConnectivityTracker.h"

#import "RMBTHelpers.h"
#import "RMBTSettings.h"

// qos prototype

#import "RMBTTrafficCounter.h"
#import "RMBTRAMMonitor.h"
#import "RMBTCPUMonitor.h"

// dns
#include "dns_sd.h"
#import "GetDNSIP.h"

// traceroute
#import "NSString+IPAddress.h"
#import "PingUtil.h"

// reveal controllers solution
#import "SWRevealViewController.h"

// Pop up
#import "KLCPopup.h"

//
#import "RMBTTestRunner.h"

#import "RMBTNetworkType.h"
