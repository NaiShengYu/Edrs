//
//  DisasterChemicalViewController.h
//  edrs
//
//  Created by 余文君, July on 15/8/20.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import "ChemicalDetailViewController.h"
#import "PollutionNearbyTableViewController.h"

@interface DisasterChemicalViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,BMKLocationServiceDelegate>{
//    NSMutableArray *mDisasterChemicalList;
    NSMutableArray *mNearbyChemicalList;
    
    BOOL mShowRadiusInfo;
    
    BMKLocationService *mLocationService;
    CLLocationCoordinate2D mLocationCoor;
    
    NSTimer *mLocationTimer;
}

@property NSString *disasterId;
@property NSArray *chemicalList;
@property NSString *disasterLocation;

@property (weak, nonatomic) IBOutlet UITableView *disasterChemicalTableView;

-(void)getDisasterChemicalData;

@end
