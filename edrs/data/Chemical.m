//
//  Chemical.m
//  edrs
//
//  Created by 余文君, July on 15/8/18.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "Chemical.h"

@implementation Chemical

-(Chemical *)setData:(NSDictionary *)dict{
    if (dict!=nil) {
        self.cid = dict[@"id"];
        self.gb = dict[@"gb"];
        self.cas = dict[@"cas"];
        self.name = dict[@"name"];
        self.ename = dict[@"ename"];
        self.alias = dict[@"alias"];
        self.molecularstr = dict[@"molecularstr"];
        self.molecularmass = dict[@"molecularmass"];
        self.meltingpoint = dict[@"meltingpoint"];
        self.density = dict[@"density"];
        self.dangermark = dict[@"dangermark"];
        self.characteristics = dict[@"characteristics"];
        self.vapourpressure = dict[@"vapourpressure"];
        self.dissolvability = dict[@"dissolvability"];
        self.stability = dict[@"stability"];
        self.application = dict[@"application"];
        self.envimpact = dict[@"envimpact"];
        self.fieldtest = dict[@"fieldtest"];
        self.response = dict[@"response"];
        self.category = dict[@"category"];
        self.priority = dict[@"priority"];
        self.boilingpoint = dict[@"boilingpoint"];
        self.flashpoint = dict[@"flashpoint"];
        return self;
    }
    else{
        return nil;
    }
}

@end
