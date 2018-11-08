//
//  SamplePlanModel.h
//  VOC
//
//  Created by 林鹏, Leon on 2017/3/14.
//  Copyright © 2017年 林鹏, Leon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SamplePlanModel : NSObject

@property(nonatomic,strong) NSString *id;
@property(nonatomic,strong) NSString *stationid;
@property(nonatomic,strong) NSString *createtime;
@property(nonatomic,strong) NSString *qctip;
@property(nonatomic,strong) NSString *refid;
@property(nonatomic,strong) NSString *security;
@property(nonatomic,strong) NSString *pretreatment;
@property(nonatomic,strong) NSString *remarks;
@property(nonatomic,strong) NSString *name;

@property(nonatomic,unsafe_unretained) BOOL ischeck;
@property(nonatomic,unsafe_unretained) NSInteger status;
@property(nonatomic,unsafe_unretained) CGFloat lat;
@property(nonatomic,unsafe_unretained) CGFloat lng;
@property(nonatomic,unsafe_unretained) CGFloat farmetter;


@end
