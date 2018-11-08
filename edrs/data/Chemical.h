//
//  Chemical.h
//  edrs
//
//  Created by 余文君, July on 15/8/18.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Chemical : NSObject

@property NSString *cid;

@property NSString *gb;
@property NSString *cas;
@property NSString *name;
@property NSString *ename;
@property NSString *alias;

@property NSString *molecularstr;
@property NSString *molecularmass;
@property NSString *meltingpoint;
@property NSString *density;
@property NSString *dangermark;

@property NSString *characteristics;
@property NSString *vapourpressure;
@property NSString *dissolvability;
@property NSString *stability;
@property NSString *application;

@property NSString *envimpact;
@property NSString *fieldtest;
@property NSString *response;
@property NSString *category;
@property NSString *priority;

@property NSString *boilingpoint;
@property NSString *flashpoint;

-(Chemical *)setData:(NSDictionary *)dict;

@end
