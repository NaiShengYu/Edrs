//
//  InputBatch.m
//  edrs
//
//  Created by bchan on 15/12/27.
//  Copyright © 2015年 julyyu. All rights reserved.
//

#import "Common.h"
#import "InputBatch.h"

@implementation InputContentBase

@end

@implementation Input

- (id)initWithDictionary:(NSDictionary*)dict{
    self=[super init];
    
    if (self!=nil){
        if(![dict[@"id"] isKindOfClass:[NSNull class]]){
            _uniqueID=[[NSUUID alloc] initWithUUIDString:dict[@"id"]];
        }
      
        _type=(INPUT_TYPE)[dict[@"type"] intValue];
        _index=[dict[@"index"] intValue];
        switch (_type) {
            case IT_TEXT:
                _contents = [[TextContent alloc] initWithDictionary:dict[@"contents"]];
                break;
                
            case IT_IMAGE:
                _contents = [[ImageContent alloc] initWithDictionary:dict[@"contents"]];
                break;
                
            case IT_DATA:
                _contents = [[DataContent alloc] initWithDictionary:dict[@"contents"]];
                break;
                
            case IT_SPECIAL:
                _contents = [[SpecialContent alloc] initWithDictionary:dict[@"contents"]];
                break;
                
            default:
                break;
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_uniqueID forKey:@"id"];
    [aCoder encodeInt:_type forKey:@"type"];
    [aCoder encodeInt:_index forKey:@"index"];
    [aCoder encodeObject:_contents forKey:@"contents"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    Class classes[5]={[TextContent class], [ImageContent class], [DataContent class], nil, [SpecialContent class]};
    
    self=[super init];
    
    if (self!=nil){
        _uniqueID= [aDecoder decodeObjectForKey:@"id"];
        _type= [aDecoder decodeIntForKey:@"type"];
        _index= [aDecoder decodeIntForKey:@"index"];
        _contents=[aDecoder decodeObjectOfClass:classes[(int)_type] forKey:@"contents"];
    }
    
    return self;
}
@end


@implementation TextContent

- (id)initWithDictionary:(NSDictionary*)dict{
    self=[super init];
    
    if (self!=nil){
        _text=dict[@"text"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_text forKey:@"text"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self=[super init];
    
    if (self!=nil){
        _text= [aDecoder decodeObjectForKey:@"text"];
    }
    
    return self;
}
@end

@implementation ImageContent

- (id)initWithDictionary:(NSDictionary*)dict{
    self=[super init];
    
    if (self!=nil){
        _width=[dict[@"width"] intValue];
        _height=[dict[@"height"] intValue];
        _path=dict[@"path"];
        _size=[dict[@"size"] intValue];
        if(![dict[@"uploadkey"] isKindOfClass:[NSNull class]]){
            _uploadKey=[[NSUUID alloc] initWithUUIDString:dict[@"uploadkey"]];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInt:_width forKey:@"width"];
    [aCoder encodeInt:_height forKey:@"height"];
    [aCoder encodeObject:_path forKey:@"path"];
    [aCoder encodeInt:_size forKey:@"size"];
    [aCoder encodeObject:_uploadKey forKey:@"key"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self=[super init];
    
    if (self!=nil){
        _width= [aDecoder decodeIntForKey:@"width"];
        _height= [aDecoder decodeIntForKey:@"height"];
        _path= [aDecoder decodeObjectForKey:@"path"];
        _size= [aDecoder decodeIntForKey:@"size"];
        _uploadKey= [aDecoder decodeObjectForKey:@"key"];
    }
    
    return self;
}
@end

@implementation DataContent

- (id)initWithDictionary:(NSDictionary*)dict{
    self=[super init];
    
    if (self!=nil){
        if(![dict[@"chemical"] isKindOfClass:[NSNull class]]){
            _chemid=[[NSUUID alloc] initWithUUIDString:dict[@"chemical"]];
        }
       
        _chemname=dict[@"chemicalname"];
        
        if(![dict[@"equipment"] isKindOfClass:[NSNull class]]){
            _eqid=[[NSUUID alloc] initWithUUIDString:dict[@"equipment"]];
        }
       
        _eqname=dict[@"equipmentname"];
        _metric=dict[@"metric"];
        _sampleType=[dict[@"sampletype"] intValue];
        if(![dict[@"testmethod"] isKindOfClass:[NSNull class]]){
            _methodid=[[NSUUID alloc] initWithUUIDString:dict[@"testmethod"]];
        }
        _unit=dict[@"unit"];
        _unitid=[dict[@"unitid"] intValue];
        _value=[dict[@"value"] doubleValue];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_chemid forKey:@"chemid"];
    [aCoder encodeObject:_chemname forKey:@"chemname"];
    [aCoder encodeObject:_eqid forKey:@"eqid"];
    [aCoder encodeObject:_eqname forKey:@"eqname"];
    [aCoder encodeObject:_metric forKey:@"metric"];
    [aCoder encodeInt:_sampleType forKey:@"sampletype"];
    [aCoder encodeObject:_methodid forKey:@"methodid"];
    [aCoder encodeObject:_unit forKey:@"unit"];
    [aCoder encodeInt:_unitid forKey:@"unitid"];
    [aCoder encodeDouble:_value forKey:@"value"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self=[super init];
    
    if (self!=nil){
        _chemid= [aDecoder decodeObjectForKey:@"chemid"];
        _chemname= [aDecoder decodeObjectForKey:@"chemname"];
        _eqid= [aDecoder decodeObjectForKey:@"eqid"];
        _eqname= [aDecoder decodeObjectForKey:@"eqname"];
        _metric= [aDecoder decodeObjectForKey:@"metric"];
        _sampleType= [aDecoder decodeIntForKey:@"sampletype"];
        _methodid= [aDecoder decodeObjectForKey:@"methodid"];
        _unit= [aDecoder decodeObjectForKey:@"unit"];
        _unitid= [aDecoder decodeIntForKey:@"unitid"];
        _value= [aDecoder decodeDoubleForKey:@"value"];
    }
    
    return self;
}
@end


@implementation SpecialContent

- (id)initWithDictionary:(NSDictionary*)dict{
    self=[super init];
    
    if (self!=nil){
        if(![dict[@"refid1"] isKindOfClass:[NSNull class]]){
            _refid1=[[NSUUID alloc] initWithUUIDString:dict[@"refid1"]];
        }else{
            _refid1=nil;
        }
         if(![dict[@"refid2"] isKindOfClass:[NSNull class]]){
            _refid2=[[NSUUID alloc] initWithUUIDString:dict[@"refid2"]];
         }else{
             _refid2=nil;
         }
        _remarks=dict[@"remarks"];
        _type=(SPECIALINPUT_TYPE)[dict[@"specialtype"] intValue];
        
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_refid1 forKey:@"refid1"];
    [aCoder encodeObject:_refid2 forKey:@"refid2"];
    [aCoder encodeObject:_remarks forKey:@"remarks"];
    [aCoder encodeInt:(int)_type forKey:@"type"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self=[super init];
    
    if (self!=nil){
        _refid1= [aDecoder decodeObjectForKey:@"refid1"];
        _refid2= [aDecoder decodeObjectForKey:@"refid2"];
        _remarks= [aDecoder decodeObjectForKey:@"remarks"];
        _type= (SPECIALINPUT_TYPE)[aDecoder decodeIntForKey:@"type"];
    } 
    
    return self;
}
@end



@implementation InputBatch

- (id)initWithDictionary:(NSDictionary*)dict{
    self=[super init];
    
    if (self!=nil){
        if(![dict[@"id"] isKindOfClass:[NSNull class]]){
            _uniqueID=[[NSUUID alloc] initWithUUIDString:dict[@"id"]];
        }
        
        _type=[dict[@"type"] intValue];
        _longitude=_latitude=-1000.0;
        if (dict[@"lng"]!=nil) _longitude=[dict[@"lng"] doubleValue];
        if (dict[@"lat"]!=nil) _latitude=[dict[@"lat"] doubleValue];
        
        if(![dict[@"staff"] isKindOfClass:[NSNull class]]){
            _staffID=[[NSUUID alloc] initWithUUIDString:dict[@"staff"]];
        }
      
        _staffName=dict[@"users"];
        NSString *timeStr = dict[@"time"];
        if([timeStr length] == 19){
             _time = [Common dateFromString:[NSString stringWithFormat:@"%@.000",timeStr]];
        }else{
            _time = [Common dateFromString:timeStr];
        }
        
        _newcontents=dict[@"newcontents"];
        _inputs=[[NSMutableArray<Input*> alloc] init];
        for (int i=0; i<[dict[@"details"] count]; i++) {
            Input* inp=[[Input alloc] initWithDictionary:dict[@"details"][i]];
            [_inputs addObject:inp];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_uniqueID forKey:@"id"];
    [aCoder encodeInt:_type forKey:@"type"];
    [aCoder encodeDouble:_longitude forKey:@"lng"];
    [aCoder encodeDouble:_latitude forKey:@"lat"];
    [aCoder encodeObject:_staffID forKey:@"staffid"];
    [aCoder encodeObject:_staffName forKey:@"name"];
    [aCoder encodeObject:_time forKey:@"time"];
    [aCoder encodeObject:_newcontents forKey:@"newcont"];
    [aCoder encodeObject:_inputs forKey:@"details"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self=[super init];
    
    if (self!=nil){
        _uniqueID= [aDecoder decodeObjectForKey:@"id"];
        _type= [aDecoder decodeIntForKey:@"type"];
        _longitude=_latitude=-1000.0;
        if ([aDecoder containsValueForKey:@"lng"]) _longitude= [aDecoder decodeDoubleForKey:@"lng"];
        if ([aDecoder containsValueForKey:@"lat"]) _latitude= [aDecoder decodeDoubleForKey:@"lat"];
        _staffID= [aDecoder decodeObjectForKey:@"staffid"];
        _staffName= [aDecoder decodeObjectForKey:@"name"];
        _time= [aDecoder decodeObjectForKey:@"time"];
        _newcontents= [aDecoder decodeObjectForKey:@"newcont"];
        _inputs=[aDecoder decodeObjectForKey:@"details"];
    }
    
    return self;
}

@end
