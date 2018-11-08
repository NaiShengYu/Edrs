//
//  PollutionMapViewController.h
//  edrs
//
//  Created by 余文君, July on 15/8/20.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import "CommonDefinition.h"
#import "CustomUtil.h"
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
@protocol PollutionMapDelegate <NSObject>

-(void)setPollutionLocation:(CLLocationCoordinate2D)coor;

@end

@interface PollutionMapViewController : UIViewController<BMKMapViewDelegate,BMKLocationServiceDelegate,UITableViewDataSource, UITableViewDelegate,BMKGeoCodeSearchDelegate>{
    BMKMapView *mMapView;
    BMKLocationService *mLocService;
    BMKPointAnnotation *mPointAnnotation;
//    CGFloat mLocationLat;
//    CGFloat mLocationLng;
    CLLocationCoordinate2D mLocationCoor;
    
    UILabel *mMarkLocationLabel;
    
    NSInteger mSelectedIndex;
    
    NSTimer *mGetLocationTimer;
    
    BMKPointAnnotation *mPollutionCenter;
    BMKCircle *mPollCtrCircleOverlay;
}

@property (retain, nonatomic) id<PollutionMapDelegate> delegate;
@property (strong,nonatomic) NSString *disasterid;
@property (strong,nonatomic) NSString *staffid;
@property (nonatomic,unsafe_unretained) BOOL isPoint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableHeight;
@property (weak, nonatomic) IBOutlet UITableView *locationTableView;

-(void)mapViewSettings;

//- (IBAction)actionSubmitPollutionLocation:(id)sender;

@end
