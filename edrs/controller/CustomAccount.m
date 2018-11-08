//
//  CustomAccount.m
//  edrs
//
//  Created by 余文君, July on 15/8/17.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "CustomAccount.h"

@implementation CustomAccount

+(CustomAccount *)sharedCustomAccount{
    static CustomAccount *sharedCustomAccountInstance = nil;
    static dispatch_once_t tar;
    dispatch_once(&tar,^{
        sharedCustomAccountInstance = [[CustomAccount alloc]init];
    });
    return sharedCustomAccountInstance;
}



@end
