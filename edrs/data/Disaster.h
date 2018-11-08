//
//  Disaster.h
//  edrs
//
//  Created by bchan on 15/12/27.
//  Copyright © 2015年 julyyu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "InputBatch.h"
#import "DataLoc.h"
@import CoreLocation;

typedef enum{
    DN_UNDEFINED=-1,
    DN_AIR=0,
    DN_WATER=1
} DISASTER_NATURE;


@interface Disaster : NSObject{
    NSMutableDictionary<NSUUID*, DataLoc*>* idDataLocDict;
}

@property NSUUID*                       uniqueID;
@property NSString*                     name;
@property NSDate*                       starttime;
@property NSDate*                       endtime;
@property DISASTER_NATURE               nature; // last nature recorded in disaster table
@property DISASTER_NATURE               natureSummary; // last nature recorded in the last special input batch

@property NSString*                     natureName;
@property NSString*                     locationSummary;
@property NSMutableArray<InputBatch*>*  inputBatches;
@property NSMutableArray<DataLoc*>*     dataLocs;
@property CLLocationCoordinate2D        location;

- (id)init;
- (void)populateDataWithDictionary:(NSDictionary*)dict;
- (void)updateSummary;

- (void)retrieveInputBatchesFromServerWithNewItems:(void (^)(id))processNewItems;
- (void)retrieveDataLocsFromServerWithNewItems:(void (^)(id))processNewItems andOldItems:(void (^)(id))processOldItems;


- (void)saveInputBatches;
- (void)loadInputBatches;

- (void)saveDataLocs;
- (void)loadDataLocs;

@end
