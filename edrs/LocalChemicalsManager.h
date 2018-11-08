//
//  LocalChemicalsManager.h
//  edrs
//
//  Created by 林鹏, Leon on 2017/6/7.
//  Copyright © 2017年 julyyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalChemicalsManager : NSObject

+(void)saveChemical:(NSString *)chemical   withDisasterId:(NSString *)disasterId;
+(NSString *)getChemicalsWithID:(NSString *)disasterId;
@end
