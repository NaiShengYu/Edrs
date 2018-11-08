//
//  Common.h
//  edrs
//
//  Created by bchan on 15/12/27.
//  Copyright © 2015年 julyyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Common : NSObject

+(NSDate*)dateFromString:(NSString*)string;
+(NSString*)stringFromDate:(NSDate*)datetime;
+(NSString*)stringFromDate2:(NSDate*)datetime;

@end
