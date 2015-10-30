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
//  GetDNSIP.m
//  DNSTest
//
//  Created by Benjamin Pucher on 08.03.15.
//  Copyright (c) 2015 Benjamin Pucher. All rights reserved.
//

#import "GetDNSIP.h"

@implementation GetDNSIP

// http://stackoverflow.com/questions/10999612/iphone-get-3g-dns-host-name-and-ip-address

+(NSString *)getdnsip {
    
    /*NSMutableString *addresses = [[NSMutableString alloc]initWithString:@"DNS Addresses \n"];
    
    res_state res = malloc(sizeof(struct __res_state));
    
    int result = res_ninit(res);
    
    if ( result == 0 ) {
        for ( int i = 0; i < res->nscount; i++ ) {
            NSString *s = [NSString stringWithUTF8String :  inet_ntoa(res->nsaddr_list[i].sin_addr)];
            [addresses appendFormat:@"%@\n",s];
            NSLog(@"%@",s);
        }
    } else {
        [addresses appendString:@" res_init result != 0"];
    }
    
    free(res);
     
    return addresses;*/
    
    NSString *address;
    
    res_state res = malloc(sizeof(struct __res_state));
    
    int result = res_ninit(res);
    
    if ( result == 0 ) {
//        for ( int i = 0; i < res->nscount; i++ ) {
        if (res->nscount > 0) {
            address = [NSString stringWithUTF8String: inet_ntoa(res->nsaddr_list[0].sin_addr)];
            NSLog(@"found dns server ip: %@, port: %u", address, htons(res->nsaddr_list[0].sin_port));
        }
//        }
    }/* else {
        
    }*/
    
    free(res);
    
    return address;
}

+(NSDictionary *)getdnsIPandPort {
    
    NSString *address;
    uint16_t port = 0;
    
    res_state res = malloc(sizeof(struct __res_state));
    
    int result = res_ninit(res);
    
    if ( result == 0 ) {
        //        for ( int i = 0; i < res->nscount; i++ ) {
        if (res->nscount > 0) {
            address = [NSString stringWithUTF8String: inet_ntoa(res->nsaddr_list[0].sin_addr)];
            port = htons(res->nsaddr_list[0].sin_port);
            NSLog(@"found dns server ip: %@, port: %u", address, port);
        }
        //        }
    }/* else {
      
      }*/
    
    free(res);
    
    if (address) {
        return @{
            @"host": address,
            @"port": [NSNumber numberWithUnsignedShort: port]
        };
    } else {
        return nil;
    }
}

@end