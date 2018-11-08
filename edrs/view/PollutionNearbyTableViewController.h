//
//  PollutionNearbyTableViewController.h
//  edrs
//
//  Created by 余文君, July on 15/9/2.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomHttp.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "CommonDefinition.h"
#import "PollutionDetailViewController.h"

@interface PollutionNearbyTableViewController : UITableViewController<UIGestureRecognizerDelegate,BMKMapViewDelegate>{
    NSMutableArray *mPollutionNearbyList;
    
    BMKMapView *mMapView;
    
    UIGestureRecognizer *rec;
    
    BMKCircle *mCircle;
    BMKPointAnnotation *mCenterPoint;
    NSMutableArray *mPointArray;
}

@property NSString *lat;
@property NSString *lng;

-(void)getPollutionNearbyData;
-(void)createMap;
@end
