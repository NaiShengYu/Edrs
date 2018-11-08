 //
//  Disaster.m
//  edrs
//
//  Created by bchan on 15/12/27.
//  Copyright © 2015年 julyyu. All rights reserved.
//

#import "Constants.h"
#import "Common.h"
#import "Disaster.h"
#import "CustomUtil.h"
#import "CustomHttp.h"

@implementation Disaster

-(id)init{
    self=[super init];
    
    if (self!=nil){
        _nature=-1;
        _natureSummary=-1;
        _inputBatches=nil;
        _dataLocs=nil;
        _locationSummary=@"";
    }
    
    return self;
}

-(void)populateDataWithDictionary:(NSDictionary*)dict{
    
    if(![dict[@"id"] isKindOfClass:[NSNull class]]){
        _uniqueID=[[NSUUID alloc] initWithUUIDString:dict[@"id"]];
    }
   
    _name=dict[@"name"];
    
    _starttime = [Common dateFromString:dict[@"starttime"]];
    
    NSString *etstr=dict[@"endtime"];
    if ([etstr isEqualToString:@"0001-01-01T00:00:00"]){
        _endtime=nil;
    } else {
        _endtime = [Common dateFromString:etstr];
    }
    
    if (dict[@"nature"]==nil){
        _nature=DN_UNDEFINED;
    }
    else{
        NSInteger  value = [dict[@"nature"] intValue];
        if(value==0){
            _natureName= @"未知";
        }else if(value==1){
            _natureName = @"土";
        }else if (value==10){
            _natureName = @"水";
        }else if (value==11){
            _natureName = @"水,土";
        }else if (value==100){
            _natureName = @"气";
        }else if (value==101){
            _natureName = @"气,土";
        }else if (value==110){
            _natureName = @"气,水";
        }else if (value==111){
            _natureName = @"气,水,土";
        }
//        _nature = (DISASTER_NATURE)[dict[@"nature"] intValue];
    }
    
}

-(void)updateSummary{
    if (_inputBatches==nil) return;
    
    if (_nature!=DN_UNDEFINED) _natureSummary=_nature;
    
    for(int i=0;i<_inputBatches.count;i++){
        InputBatch* ib=_inputBatches[i];
        if (ib.type==IT_SPECIAL){
            SpecialContent* sc=(SpecialContent*)ib.inputs[0].contents;
            if (sc.type == ST_NATURE_IDENTIFIED) _natureSummary=(DISASTER_NATURE)[sc.remarks intValue];
            else if (sc.type==ST_LOCATION_CHANGED){
                _locationSummary=sc.remarks;
            }
        }
    }
    
    if (![_locationSummary isEqualToString:@""]){
        NSArray *tmplocarr = [_locationSummary componentsSeparatedByString:@","];
        _location=CLLocationCoordinate2DMake([tmplocarr[1] doubleValue], [tmplocarr[0] doubleValue]);
    }
}

// load input batches from server incrementally, return new items
- (void)retrieveInputBatchesFromServerWithNewItems:(void (^)(id))processNewItems
{
    NSString* lastTime=@"";
    if (_inputBatches.count > 0) {
        lastTime = [Common stringFromDate:[_inputBatches lastObject].time];
    }else{
        lastTime= [Common stringFromDate:_starttime];
        _inputBatches=[[NSMutableArray<InputBatch*> alloc] init];
    }

    
    
    [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@", EDRSHTTP , EDRSHTTP_GETDISASTER_DETAIL_INPUTS]
                  params:@{@"time":lastTime, @"disasterid":[_uniqueID UUIDString]}
                 success:^(id responseObj) {
                     NSLog(@"get disaster detail inputbatches successfully , response = %@", responseObj);
                     

                     if ([responseObj count] > 0) {
                         NSMutableArray<InputBatch*>* newItems=[[NSMutableArray<InputBatch*> alloc]init];
                         for (int i = 0 ; i < [responseObj count]; i++) {
                             InputBatch* ib=[[InputBatch alloc] initWithDictionary:responseObj[i]];
                             [_inputBatches addObject:ib];
                             [newItems addObject:ib];
                         }
                         
                         [self updateSummary];
                         [self saveInputBatches];
                         
                         if (processNewItems!=nil) processNewItems(newItems);
                     } else {
                         if (processNewItems!=nil) processNewItems(nil);
                     }
                    
                 }
                 failure:^(NSError *err) {
                     NSLog(@"fail to get disaster detail inputs, error = %@", err);
                 }];
}


// load data locs from server and pass new items and old items to the respective callbacks
- (void)retrieveDataLocsFromServerWithNewItems:(void (^)(id))processNewItems andOldItems:(void (^)(id))processOldItems
{
    if (_dataLocs==nil) _dataLocs=[[NSMutableArray<DataLoc*> alloc] init];
    if (idDataLocDict==nil) idDataLocDict=[[NSMutableDictionary<NSUUID*, DataLoc*> alloc] init];
    
    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@", EDRSHTTP, EDRSHTTP_GETDATALOC] params:@{@"disasterid":[_uniqueID UUIDString]} success:^(id responseObj) {
        NSLog(@"get dataloc list successfully, response = %@", responseObj);
        //获取历史事故
        
        NSMutableArray<DataLoc*>* loadedItems=[[NSMutableArray<DataLoc*> alloc]init];
        NSMutableDictionary<NSUUID*, DataLoc*>* idLoadedItemDict=[[NSMutableDictionary<NSUUID*, DataLoc*> alloc] init];
        
        for (int i = 0; i < [responseObj count]; i++) {
            DataLoc* dl=[[DataLoc alloc] initWithDictionary:responseObj[i]];
            [loadedItems addObject:dl];
            idLoadedItemDict[dl.uniqueID]=dl;
        }
        
        
        // remove old items
        NSMutableArray<DataLoc*>* oldItems=[[NSMutableArray<DataLoc*> alloc]init];
        for (int i = 0; i < [SD.dataLocs count]; i++) {
            // if loaded list does not contain this item, remove from SD and put in oldItem list
            if (idLoadedItemDict[SD.dataLocs[i].uniqueID]==nil){
                [idDataLocDict removeObjectForKey:SD.dataLocs[i].uniqueID];
                [oldItems addObject:SD.dataLocs[i]];
            }
        }
        [SD.dataLocs removeObjectsInArray:oldItems];
        
        // add new items
        NSMutableArray<DataLoc*>* newItems=[[NSMutableArray<DataLoc*> alloc]init];
        for (int i = 0; i < [loadedItems count]; i++) {
            if (idDataLocDict[loadedItems[i].uniqueID]==nil){
                idDataLocDict[loadedItems[i].uniqueID]=loadedItems[i];
                [newItems addObject:loadedItems[i]];
                [SD.dataLocs addObject:loadedItems[i]];
            }
        }
        
        [self saveDataLocs];
        if (processNewItems!=nil) processNewItems(newItems);
        if (processOldItems!=nil) processOldItems(oldItems);
    } failure:^(NSError *err) {
        NSLog(@"fail to get dataloc list , error = %@", err);
    }];
   
}

- (void)saveInputBatches
{
    NSString *path = [CustomUtil getFilePath:[NSString stringWithFormat:@"%@%@.cache", EDRS_UD_INFO, [_uniqueID UUIDString]]];
    
    if([NSKeyedArchiver archiveRootObject:_inputBatches toFile:path]==YES){
        NSLog(@"input batches saved");
    };
}

- (void)loadInputBatches
{
    NSString *path = [CustomUtil getFilePath:[NSString stringWithFormat:@"%@%@.cache", EDRS_UD_INFO, [_uniqueID UUIDString]]];
    
    _inputBatches = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (_inputBatches==nil){
        NSLog(@"input batches load failed");
    }
    [self updateSummary];
}

- (void)saveDataLocs
{
    NSString *path = [CustomUtil getFilePath:[NSString stringWithFormat:@"%@%@.cache", EDRS_UD_DATALOC, [_uniqueID UUIDString]]];
    
    if([NSKeyedArchiver archiveRootObject:_dataLocs toFile:path]==YES){
        NSLog(@"datalocs saved");
    };
}

- (void)loadDataLocs
{
    NSString *path = [CustomUtil getFilePath:[NSString stringWithFormat:@"%@%@.cache", EDRS_UD_DATALOC, [_uniqueID UUIDString]]];
    
    _dataLocs = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (_dataLocs==nil){
        NSLog(@"datalocs load failed");
    }
}


@end
