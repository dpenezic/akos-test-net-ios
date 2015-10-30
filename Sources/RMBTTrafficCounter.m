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
//  RMBTTrafficCounter.m
//  RMBT
//
//  Created by Benjamin Pucher on 16.12.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

#import "RMBTTrafficCounter.h"

@implementation RMBTTrafficCounter : NSObject

- (NSDictionary *)getTrafficCount {
    
    // see http://stackoverflow.com/questions/7946699/iphone-data-usage-tracking-monitoring/8014012#8014012
    
    BOOL   success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;
    
    int WiFiSent = 0;
    int WiFiReceived = 0;
    int WWANSent = 0;
    int WWANReceived = 0;
    
    NSString *name= [[NSString alloc] init];
    
    success = getifaddrs(&addrs) == 0;
    if (success)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            name = [NSString stringWithFormat:@"%s",cursor->ifa_name];
            //NSLog(@"ifa_name %s == %@\n", cursor->ifa_name,name);
            // names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN
            
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                // there are other interfaces as well...
                if ([name hasPrefix:@"en"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WiFiSent += networkStatisc->ifi_obytes;
                    WiFiReceived += networkStatisc->ifi_ibytes;
                    //NSLog(@"WiFiSent %d ==%d",WiFiSent,networkStatisc->ifi_obytes);
                    //NSLog(@"WiFiReceived %d ==%d",WiFiReceived,networkStatisc->ifi_ibytes);
                }
                
                if ([name hasPrefix:@"pdp_ip"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WWANSent += networkStatisc->ifi_obytes;
                    WWANReceived += networkStatisc->ifi_ibytes;
                    //NSLog(@"WWANSent %d ==%d",WWANSent,networkStatisc->ifi_obytes);
                    //NSLog(@"WWANReceived %d ==%d",WWANReceived,networkStatisc->ifi_ibytes);
                }
            }
            
            cursor = cursor->ifa_next;
        }
        
        freeifaddrs(addrs);
    }
    
    if (WiFiSent < 0)       WiFiSent = 0;
    if (WiFiReceived < 0)   WiFiReceived = 0;
    if (WWANSent < 0)       WWANSent = 0;
    if (WWANReceived < 0)   WWANReceived = 0;
    
    /*if (WiFiSent < 0 || WiFiReceived < 0 || WWANSent < 0 || WWANReceived < 0) {
        return nil;
    }*/
    
    NSDictionary *dict = @{
        @"wifi_sent": [NSNumber numberWithInt:WiFiSent],
        @"wifi_received": [NSNumber numberWithInt:WiFiReceived],
        @"wwan_sent": [NSNumber numberWithInt:WWANSent],
        @"wwan_received": [NSNumber numberWithInt:WWANReceived]
    };
    
    return dict;
}

- (NSDictionary *)getTrafficCount:(NSString *)interfaceName {
    
    int interfaceSent = 0;
    int interfaceReceived = 0;
    
    BOOL success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStat;
    
    success = getifaddrs(&addrs) == 0;
    if (success)
    {
        NSString *name= [[NSString alloc] init];
        
        cursor = addrs;
        while (cursor != NULL)
        {
            name = [NSString stringWithFormat:@"%s",cursor->ifa_name];
            
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                if ([name hasPrefix: interfaceName])
                {
                    networkStat = (const struct if_data *) cursor->ifa_data;
                    interfaceSent += networkStat->ifi_obytes;
                    interfaceReceived += networkStat->ifi_ibytes;
                }
            }
            
            cursor = cursor->ifa_next;
        }
        
        freeifaddrs(addrs);
    }
    
    NSDictionary *dict = @{
        @"sent": [NSNumber numberWithInt: interfaceSent],
        @"received": [NSNumber numberWithInt: interfaceReceived]
    };
    
    return dict;
}

@end