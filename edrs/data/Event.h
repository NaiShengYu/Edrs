//
//  Event.h
//  edrs
//
//  Created by 余文君, July on 15/8/14.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject

@property NSString *eventId;
@property NSString *eventName;
@property NSString *eventStartTime;
@property NSString *eventNature;
@property NSString *eventArea;

@property BOOL eventProgressing;

@end
