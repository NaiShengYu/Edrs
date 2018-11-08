//
//  ModelLocator.h
//  VOC
//
//  Created by 林鹏, Leon on 2017/3/13.
//  Copyright © 2017年 林鹏, Leon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelLocator : NSObject

@property(nonatomic,strong) NSString *stationID ;
@property(nonatomic,strong) NSString *stationName ;
@property(nonatomic,strong) NSString *userID;
@property(nonatomic,strong) NSString *token ;
@property (strong, nonatomic) NSMutableDictionary *uploadDic;

+(ModelLocator *)sharedInstance ;
@end
