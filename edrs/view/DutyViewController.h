//
//  DutyViewController.h
//  edrs
//
//  Created by 余文君, July on 15/9/26.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"
#import "NSDate+FSExtension.h"
#import "CustomHttp.h"
#import "CustomUtil.h"

@interface DutyViewController : UIViewController<FSCalendarDataSource, FSCalendarDelegate>{
    NSMutableDictionary *mDutyDict;
}

@property (weak, nonatomic) IBOutlet FSCalendar *mDutyCalendar;
@end
