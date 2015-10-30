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
//  NSString+IPAddress.m
//  RMBT
//
//  Created by Benjamin Pucher on 06.02.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

#import "NSString+IPAddress.h"

#include <arpa/inet.h>

@implementation NSString (IPAddress)

-(BOOL)isValidIPAddress {
    const char *utf8 = [self UTF8String];
    int success;
    
    struct in_addr dst;
    success = inet_pton(AF_INET, utf8, &dst);
    if (success != 1) {
        struct in6_addr dst6;
        success = inet_pton(AF_INET6, utf8, &dst6);
    }
    
    return success == 1;
}

-(BOOL)isValidIPv4 {
    const char *utf8 = [self UTF8String];
    int success;
    
    struct in_addr dst;
    success = inet_pton(AF_INET, utf8, &dst);
    
    return success == 1;
}

-(BOOL)isValidIPv6 {
    const char *utf8 = [self UTF8String];
    int success;

    struct in6_addr dst6;
    success = inet_pton(AF_INET6, utf8, &dst6);
    
    return success == 1;
}

-(NSData *)convertIPToNSData {
    if ([self isValidIPv4]) {
        struct sockaddr_in ip;
        
        memset(&ip, 0, sizeof(ip));
        ip.sin_len = sizeof(ip);
        
        ip.sin_family = AF_INET;
        ip.sin_addr.s_addr = inet_addr([self UTF8String]);
        
        // inet_pton not working on ios 7.1
        //int success = inet_pton(AF_INET, /*[self UTF8String]*/"78.47.110.5", &ip.sin_addr);
        //NSLog(@"inet_pton success: %u", success);

        NSData *data = [NSData dataWithBytes:&ip length:ip.sin_len];
        
        return data;
    }
    
    if ([self isValidIPv6]) {
        struct sockaddr_in6 ip;
        
        memset(&ip, 0, sizeof(ip));
        ip.sin6_len = sizeof(ip);
        
        ip.sin6_family = AF_INET6;
        
        inet_pton(AF_INET6, [self UTF8String], &ip.sin6_addr.s6_addr);
        
        return [NSData dataWithBytes:&ip length:ip.sin6_len];
    }
    
    NSLog(@"returning nil");
    return nil;
}

@end