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
//  RMBTRAMMonitor.m
//  RMBT
//
//  Created by Benjamin Pucher on 16.12.14.
//  Copyright (c) 2014 Specure GmbH. All rights reserved.
//

#import "RMBTRAMMonitor.h"

@implementation RMBTRAMMonitor : NSObject

- (NSArray *)getRAMUsage {
    
    // using host_statistics? vm_statistics?
    // see http://stackoverflow.com/questions/5012886/determining-the-available-amount-of-ram-on-an-ios-device/8540665#8540665
    
    // or http://stackoverflow.com/questions/20211650/total-ram-size-of-an-ios-device
    // or http://stackoverflow.com/questions/23935149/ios-application-memory-used
    // or http://stackoverflow.com/questions/5182924/where-is-my-ipad-runtime-memory-going
    // or http://stackoverflow.com/questions/11427761/total-ram-in-iphone
    
    /////////////////////////////////////////
    
    //// App RAM usage
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    
    natural_t mem_used_app = 0;
    if( kerr == KERN_SUCCESS ) {
        //NSLog(@"Memory in use (in bytes): %u", info.resident_size);
        mem_used_app = (natural_t) info.resident_size;
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
    //////////////////////////////////////////////////////
    // mem_total -> [NSProcessInfo processInfo].physicalMemory
    //NSLog(@"total physical memory: %llu", [NSProcessInfo processInfo].physicalMemory);
    
    // iPhone device RAM usage
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        NSLog(@"Failed to fetch vm statistics");
    }
    
    /* Stats in bytes */
    natural_t mem_used = (vm_stat.active_count +
                          vm_stat.inactive_count +
                          vm_stat.wire_count) * (natural_t) pagesize;
    natural_t mem_free = vm_stat.free_count * (natural_t) pagesize;
    natural_t mem_total = mem_used + mem_free;
   // NSLog(@"used: %u free: %u total: %u", mem_used, mem_free, mem_total);
    
    NSArray *array = @[[NSNumber numberWithLongLong: mem_used],
                       [NSNumber numberWithLongLong: mem_free],
                       [NSNumber numberWithLongLong: mem_total],
                       [NSNumber numberWithLongLong: mem_used_app]];
    
    return array;
}

- (float)getRAMUsagePercentFree {
    NSArray *ramUsageArray = [self getRAMUsage];
    
    if (ramUsageArray) {
        float physicalMemory = [NSNumber numberWithUnsignedLongLong: [NSProcessInfo processInfo].physicalMemory].floatValue;
        
        return (((NSNumber *)ramUsageArray[0]).floatValue / physicalMemory) * 100.0;
    } else {
        return 0;
    }
}

@end