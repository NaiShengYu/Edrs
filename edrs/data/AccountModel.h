//
//  AccountModel.h
//  edrs
//
//  Created by 余文君, July on 15/8/17.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountModel : NSObject

@property NSString *stationId;
@property NSString *stationName;
@property NSString *userName;
@property NSString *userId;
@property NSString *password;
@property NSString *token;
////修改 20161122  添加token 验证
//@property NSString *userToken;

@property NSInteger loginTime;
@end
