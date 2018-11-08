//
//  InputBatch.h
//  edrs
//
//  Created by bchan on 15/12/27.
//  Copyright © 2015年 julyyu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    IT_UNDEFINED=-1,
    IT_TEXT=0, //文字
    IT_IMAGE=1,//图片
    IT_DATA=2,//数据
    IT_VOICE=3,
    IT_SPECIAL=4,
    IT_VIDEO=5,
} INPUT_TYPE;

typedef enum{
    ST_UNDEFINED=-1,
    ST_NATURE_IDENTIFIED=0,
    ST_STARTTIME_CHANGED=1,
    ST_NAME_CHANGED=2,
    ST_LOCATION_CHANGED=3,
    ST_CHEMICAL_IDENTIFIED=4,
    ST_SIM_RESULT_OBTAINED=5,
    ST_HEALTH_RISK_ASSESSED=6,
    ST_WIND_CONDITION_SET=7,
    ST_DETECTION_REPORT = 8,
    ST_DETECTION_SCHEME = 9,
} SPECIALINPUT_TYPE;

@interface InputContentBase : NSObject

@end

@interface Input: NSObject<NSCoding>

@property INPUT_TYPE       type;
@property NSUUID*               uniqueID;
@property int                   index;
@property InputContentBase*     contents;

- (id)initWithDictionary:(NSDictionary*)dict;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end

@interface TextContent : InputContentBase<NSCoding>

@property NSString*             text;

- (id)initWithDictionary:(NSDictionary*)dict;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end

@interface ImageContent : InputContentBase<NSCoding>

@property int                   width;
@property int                   height;
@property NSString*             path;
@property int                   size;
@property NSUUID*               uploadKey;

- (id)initWithDictionary:(NSDictionary*)dict;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end

@interface DataContent : InputContentBase<NSCoding>

@property NSUUID*               chemid;
@property NSString*             chemname;
@property NSUUID*               eqid;
@property NSString*             eqname;
@property NSString*             metric;
@property int                   sampleType;
@property NSUUID*               methodid;
@property NSString*             unit;
@property int                   unitid;
@property double                value;

- (id)initWithDictionary:(NSDictionary*)dict;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end

@interface SpecialContent : InputContentBase<NSCoding>

@property NSUUID*               refid1;
@property NSUUID*               refid2;
@property NSString*             remarks;
@property SPECIALINPUT_TYPE     type;

- (id)initWithDictionary:(NSDictionary*)dict;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end


@interface InputBatch : NSObject<NSCoding>

@property NSUUID*                   uniqueID;
@property double                    longitude;
@property double                    latitude;
@property NSUUID*                   staffID;
@property INPUT_TYPE           type;
@property NSDate*                   time;
@property NSString*                 newcontents;
@property NSString*                 staffName;
@property NSMutableArray<Input*>*    inputs;

- (id)initWithDictionary:(NSDictionary*)dict;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end

