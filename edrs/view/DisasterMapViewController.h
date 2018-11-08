//
//  DataLocMapViewController.h
//  edrs
//
//  Created by bchan on 15/12/19.
//  Copyright © 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import <MapKit/MapKit.h>
#import "CustomHttp.h"
#import "CommonDefinition.h"
#import "CustomUtil.h"


@protocol DisasterMapDelegate <NSObject>

-(void)setDataLocLocation:(CLLocationCoordinate2D)coor;

@end

@interface DisasterMapViewController : UIViewController<BMKMapViewDelegate,BMKLocationServiceDelegate, UIActionSheetDelegate,BMKGeoCodeSearchDelegate>{
    BMKMapView *mMapView;
    BMKLocationService *mLocService;
    //BMKPointAnnotation *mPointAnnotation;
    CLLocationCoordinate2D mLocationCoor;
    
    NSTimer *mGetLocationTimer;
    
    NSMutableArray<DataLoc*>* mDataLocList; // a local reference to all loaded datalocs, keep all deleted ones in the list as well
    
    
    NSMutableArray *mDataLocAnnotationList;
    NSMutableArray *mDataAnnotationList;
    NSMutableDictionary *mIdDataLocDict;
    
    
    BMKPointAnnotation *mPollutionCenter;
    BMKPointAnnotation *mMyLocAnnotation;
    BMKCircle *mPollCtrCircleOverlay;
    bool first;

    NSTimer *mGetRelatedDataTime;
}

@property (weak, nonatomic) NSString *disasterId;
@property (retain, nonatomic) NSString *locationStr;
@property (retain, nonatomic) NSMutableArray *availableMaps;
@property (strong,nonatomic) NSString *windStr;
@property (strong,nonatomic) NSArray *taskArray;
@property (retain, nonatomic) id<DisasterMapDelegate> delegate;
@property (nonatomic,unsafe_unretained) BOOL hadLocation;
-(void)mapViewSettings;

-(void)availableMapsApps:(CLLocationCoordinate2D)targetCoordinate targetName:(NSString*)toName;

-(void)navigateAction:(id)sender;

-(void)addDataMarkers:(NSArray<InputBatch*>*)items;
-(void)addDataLocMarkers:(NSArray<DataLoc*>*)items;
-(void)updateMiscMarkers;

@end
