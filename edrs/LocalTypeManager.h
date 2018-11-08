//
//  LocalTypeManager.h
//  edrs
//
//  Created by 林鹏, Leon on 2017/6/7.
//  Copyright © 2017年 julyyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalTypeManager : NSObject

+(void)saveType:(NSString *)type   withDisasterId:(NSString *)disasterId;

+(NSString *)getTypeStrWith:(NSString *)disasterId;
@end
