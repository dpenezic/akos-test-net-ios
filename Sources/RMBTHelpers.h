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

#import <Foundation/Foundation.h>

// Format a number to two significant digits. See https://trac.rtr.at/iosrtrnetztest/ticket/17
extern NSString* RMBTFormatNumber(NSNumber *number);

// Normalize hexadecimal identifier, i.e. 0:1:c -> 00:01:0c
extern NSString* RMBTReformatHexIdentifier(NSString *identifier);

NS_INLINE id RMBTValueOrNull(id value) { return value ?: [NSNull null]; }
NS_INLINE id RMBTValueOrString(id value, NSString *result) { return value ?: result; }

NSString* RMBTMillisecondsStringWithNanos(uint64_t nanos);
NSString* RMBTSecondsStringWithNanos(uint64_t nanos);

NSNumber* RMBTTimestampWithNSDate(NSDate* date);
uint64_t RMBTCurrentNanos();