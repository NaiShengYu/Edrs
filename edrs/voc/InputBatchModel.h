//
//  InputBatchModel.h
//  edrs
//
//  Created by 林鹏, Leon on 2017/9/14.
//  Copyright © 2017年 julyyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InputBatchModel : NSObject

@property (strong ,nonatomic) NSString *id;
@property (strong ,nonatomic) NSString *name;
@property (strong ,nonatomic) NSString *chemid;
@property (strong, nonatomic) NSString *factorid;
@property (strong ,nonatomic) NSString *inptValue;
@property (strong ,nonatomic) NSString *unitId;
@property (strong ,nonatomic) NSString *unitName;
@property (strong ,nonatomic) NSString *nature;
@property (strong ,nonatomic) NSString *disasterid;
@property (strong ,nonatomic) NSString *staffid;
@property (strong ,nonatomic) NSString *lng;
@property (strong ,nonatomic) NSString *lat;

@property (strong , nonatomic) NSString *codeStr;
@end
