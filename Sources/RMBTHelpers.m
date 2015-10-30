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

#import <mach/mach_time.h>
#import "RMBTHelpers.h"

NSString *RMBTFormatNumber(NSNumber *number) {
    static NSNumberFormatter *formatter;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        formatter = [[NSNumberFormatter alloc] init];
        formatter.decimalSeparator = @".";
        formatter.usesSignificantDigits = YES;
        formatter.minimumSignificantDigits = 2;
        formatter.maximumSignificantDigits = 2;
    });
    return [formatter stringFromNumber:number];
}

NSString* RMBTReformatHexIdentifier(NSString* identifier) {
    if (!identifier) return nil;
    NSMutableArray *tmp = [NSMutableArray array];
    for (NSString *c in [identifier componentsSeparatedByString:@":"]) {
        if (c.length == 0) {
            [tmp addObject:@"00"];
        } else if (c.length == 1) {
            [tmp addObject:[NSString stringWithFormat:@"0%@", c]];
        } else {
            [tmp addObject:c];
        }
    }
    return [tmp componentsJoinedByString:@":"];
}

NSString* RMBTMillisecondsStringWithNanos(uint64_t nanos) {
    NSNumber *ms = [NSNumber numberWithDouble:((double)nanos * 1.0e-6)];
    return [NSString stringWithFormat:@"%@ ms", RMBTFormatNumber(ms)];
}

NSString* RMBTSecondsStringWithNanos(uint64_t nanos) {
    return [NSString stringWithFormat:@"%f s", (double)nanos * 1.0e-9];
}

NSNumber* RMBTTimestampWithNSDate(NSDate* date) {
    return [NSNumber numberWithUnsignedLongLong:(unsigned long long)([date timeIntervalSince1970] * 1000ull)];
}

uint64_t RMBTCurrentNanos() {
    static dispatch_once_t onceToken;
    static mach_timebase_info_data_t info;
    dispatch_once(&onceToken, ^{
        mach_timebase_info(&info);
    });

	uint64_t now = mach_absolute_time();
	now *= info.numer;
	now /= info.denom;

    return now;
}
