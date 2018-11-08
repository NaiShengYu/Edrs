//
//  CustomAccount.h
//  edrs
//
//  Created by 余文君, July on 15/8/17.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "AccountModel.h"
#import "Disaster.h"

@interface CustomAccount : NSObject

@property AccountModel*                 user;
@property NSString*                     stationUrl;
@property Disaster*                     selectedDisaster;
@property (nonatomic,unsafe_unretained) BOOL isNewVersion;

+(CustomAccount *)sharedCustomAccount;


@end
