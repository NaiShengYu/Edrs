//
//  Common.m
//  edrs
//
//  Created by bchan on 15/12/27.
//  Copyright © 2015年 julyyu. All rights reserved.
//

#import "Common.h"

@implementation Common

+(NSDate*)dateFromString:(NSString*)string
{
    static NSDateFormatter *rfc3339DateFormatter=nil;
    
    if (rfc3339DateFormatter==nil){
        if (rfc3339DateFormatter==nil){
            rfc3339DateFormatter=[[NSDateFormatter alloc] init];
            NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            
            [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
          
            [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS"];

            [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:28800]];
        }
    }
    
    return [rfc3339DateFormatter dateFromString:string];
}

// yyyy-MM-ddTHH:mm:ss.SSS
+(NSString*)stringFromDate:(NSDate*)datetime
{
    static NSDateFormatter *rfc3339DateFormatter=nil;
    
    if (rfc3339DateFormatter==nil){
        if (rfc3339DateFormatter==nil){
            rfc3339DateFormatter=[[NSDateFormatter alloc] init];
            NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            
            [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
            [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS"];
            [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:28800]];
        }
    }
    
    return [rfc3339DateFormatter stringFromDate:datetime];
}

// yyyy-MM-dd HH:mm
+(NSString*)stringFromDate2:(NSDate*)datetime
{
    static NSDateFormatter *dateFormater=nil;
    
    if (dateFormater==nil){
        if (dateFormater==nil){
            dateFormater=[[NSDateFormatter alloc] init];
            NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            
            [dateFormater setLocale:enUSPOSIXLocale];
            [dateFormater setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm'"];
            [dateFormater setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:28800]];
        }
    }
    
    return [dateFormater stringFromDate:datetime];
}

@end
