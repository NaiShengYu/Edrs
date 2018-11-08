//
//  DataLoc.m
//  edrs
//
//  Created by bchan on 15/12/28.
//  Copyright © 2015年 julyyu. All rights reserved.
//

#import "DataLoc.h"

@implementation DataLoc

- (id)initWithDictionary:(NSDictionary*)dict{
    self=[super init];
    
    if (self!=nil){
        if(![dict[@"id"] isKindOfClass:[NSNull class]]){
            _uniqueID=[[NSUUID alloc] initWithUUIDString:dict[@"id"]];
        }
        _name=dict[@"name"];
        _longitude=[dict[@"longtitude"] doubleValue];
        _latitude=[dict[@"latitude"] doubleValue];
        _radius=[dict[@"radius"] doubleValue];
        _type=(DATALOC_TYPE)[dict[@"type"] intValue];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_uniqueID forKey:@"id"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeDouble:_longitude forKey:@"lng"];
    [aCoder encodeDouble:_latitude forKey:@"lat"];
    [aCoder encodeDouble:_radius forKey:@"radius"];
    [aCoder encodeInt:(int)_type forKey:@"type"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self=[super init];
    
    if (self!=nil){
        _uniqueID= [aDecoder decodeObjectForKey:@"id"];
        _name= [aDecoder decodeObjectForKey:@"name"];
        _longitude= [aDecoder decodeDoubleForKey:@"lng"];
        _latitude= [aDecoder decodeDoubleForKey:@"lat"];
        _radius= [aDecoder decodeDoubleForKey:@"radius"];
        _type= [aDecoder decodeIntForKey:@"type"];
    }
    
    return self;
}

@end
