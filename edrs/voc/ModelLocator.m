//
//  ModelLocator.m
//  VOC
//
//  Created by 林鹏, Leon on 2017/3/13.
//  Copyright © 2017年 林鹏, Leon. All rights reserved.
//

#import "ModelLocator.h"

@implementation ModelLocator
static ModelLocator *sharedInstacne = nil ;

+(ModelLocator *)sharedInstance{
    if(sharedInstacne == nil){
        sharedInstacne = [[super allocWithZone:NULL] init];
    }
  
    return sharedInstacne;
}


-(id)init{
    self = [super init];
    if(self){
        self.uploadDic = [[NSMutableDictionary alloc]init];
    }
    
    return self;
}
@end
