//
//  DisasterDetailViewController.h
//  edrs
//
//  Created by 余文君, July on 15/8/14.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonDefinition.h"
#import "DisasterChemicalViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "CustomUtil.h"
#import "UploadViewController.h"
#import "DisasterDetailCellView.h"
#import "MBProgressHUD.h"
#import "DetectionSchemeViewController.h"
#import "MWPhotoBrowser.h"
#import "YYLabel.h"
#define ENDTIME @"0001-01-01T00:00:00"
#define MARGIN 10

@interface DisasterDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,MWPhotoBrowserDelegate,BMKGeoCodeSearchDelegate>{
    UIButton *mStarttimeButton;
    UITableView *mBaseinfoTableView;
    UIScrollView *mDetailScrollView;
    UIView *mDetailScrollViewIndicatorView;
    UIButton *mDetailScrollViewIndicator;
    BOOL mScrollViewIndicatorFlag;
    
    NSMutableArray *mBaseinfoList;  // holds the contents of the nature and chemicals tableview
    NSMutableArray *mChemicalsList;
    
    NSMutableArray *mDisasterImageIds;
    NSMutableDictionary *mDisasterImageViews;
    NSMutableDictionary *mDisasterLoadViews;
    
    NSMutableArray *mBlockViews;
    NSMutableArray *mImageViewsInBlockView;
    NSMutableArray *mTimelineViews;
    NSMutableArray *mBlockHeights;
    NSMutableArray *mBlockOffsets;
    CGFloat mBlockOffsetY;
        
    NSTimer *mCountDateTimer;
    NSTimer *mGetRelatedDataTime;
    NSTimer *mGetImagesTimer;
    
    float imgScaleSize;
    
    MBProgressHUD *mProgresshud;
    
    BOOL mIsNotInit;
}

@property (weak, nonatomic) NSString *did;
@property (weak, nonatomic) NSString *starttime;
@property (weak, nonatomic) NSString *address;

@property (strong, nonatomic) MWPhotoBrowser *photoBrowser;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *uploadButton;

-(UIButton *)createProcessingDisasterStartTime:(NSString *)str;
-(UITableView *)createDisasterBaseinfo;
-(UIScrollView *)createDetailScrollView;

-(void)getDisasterDetailData;
-(void)createDisasterDetailView;
-(void)checkDetectionScheme:(UIButton *)btn;

@end

