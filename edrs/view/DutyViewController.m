//
//  DutyViewController.m
//  edrs
//
//  Created by 余文君, July on 15/9/26.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "DutyViewController.h"

@interface DutyViewController ()

@end

@implementation DutyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    mDutyDict = [[NSMutableDictionary alloc]init];
    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@", EDRSHTTP, EDRSHTTP_DUTY_INFO] params:@{} success:^(id responseObj) {
        NSLog(@"get dutyinfo successfully, response= %@", responseObj);
        
        NSString *start_str = @"0";
        NSString *end_str;
        NSDate *start_date;
        NSDate *end_date;
        
        
        for (int i = 0; i < [responseObj count]; i++) {
            if ([[CustomAccount sharedCustomAccount].user.userId isEqualToString:responseObj[i][@"Id"]]) {
                start_str = [responseObj[i][@"duty_starttime"] substringToIndex:10];
                end_str = [responseObj[i][@"duty_endtime"] substringToIndex:10];
                start_date = [dateFormatter dateFromString:start_str];
                end_date = [dateFormatter dateFromString:end_str];
                break;
            }
        }
        
        
        NSTimeInterval timeinterval = [end_date timeIntervalSinceDate:start_date];
        int day = (int)(timeinterval/3600/24);
        
        [mDutyDict setObject:@"1" forKey:start_str];
        NSDate *preDate;
        for (int i = 0; i < day; i++) {
            if(i == 0){
                preDate = start_date;
            }
            NSDate *nextDate = [[NSDate alloc]initWithTimeIntervalSinceReferenceDate:([preDate timeIntervalSinceReferenceDate] + 24*3600)];
            preDate = nextDate;
            
            NSString *nextDateStr = [[dateFormatter stringFromDate:nextDate] substringToIndex:10];
            [mDutyDict setObject:@"1" forKey:nextDateStr];
        }
        
        [self.mDutyCalendar reloadData];
        
    } failure:^(NSError *err) {
        NSLog(@"fail to get dutyinfo , err = %@", err);
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    NSLog(@"dealloc");
}

#pragma mark - calendar delegate
-(BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [mDutyDict objectForKey:[dateFormatter stringFromDate:date]];
}

@end
