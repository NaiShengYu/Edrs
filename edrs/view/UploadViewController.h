//
//  UploadViewController.h
//  edrs
//
//  Created by 余文君, July on 15/8/20.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import "Constants.h"
#import "CommonDefinition.h"
#import "UploadDataViewController.h"
#import "UploadSpecTableViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import <CoreLocation/CoreLocation.h>


#define LINE_HEIGHT 44


#define MARGIN 10
#define PADDING 10
#define CONTENT_WIDTH SCREEN_WIDTH - MARGIN*2 - PADDING*2
//#define UUID (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, CFUUIDCreate(kCFAllocatorDefault)))
#define BUFFERMAX 1024000

typedef NS_ENUM(NSInteger, UploadState){
    UploadStateWait,
    UploadStateLoading,
    UploadStateSuccess,
    UploadStateFailure
};

@interface UploadViewController : UIViewController<UITextFieldDelegate,
UIImagePickerControllerDelegate,UINavigationControllerDelegate,
UploadDataDelegate,
UploadSpecDelegate,
UIAlertViewDelegate,
CLLocationManagerDelegate>{
    UITextField *mUploadTextField;
    NSMutableArray *mUploadList;
    NSMutableArray *mUploadCellList;
    NSMutableArray *mUploadCellHeight;
   //NSMutableArray *mWaitingUploadImages;
    NSMutableArray *mWaitingUploadVoices;
    NSMutableDictionary *mWaitingUploadImages;
    
//    BMKLocationService *mLocationService;
    CLLocationCoordinate2D mLocationCoor;
    CLLocationManager *mLocationManager;
    
    CGFloat mOffsetYBlockInScrollView;
    
    NSString *mStaffId;
}

@property (weak, nonatomic) NSString *did;
@property (weak, nonatomic) NSString *sid;
@property (weak, nonatomic) NSString *mChemicalsList;
@property (strong,nonatomic) NSString *locationStr;
@property (strong,nonatomic) NSArray *taskArray;
@property (weak, nonatomic) NSMutableArray *chemicals;

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@property (weak, nonatomic) IBOutlet UIToolbar *uploadToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *uploadPhotoButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *uploadVoiceButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *uploadDataButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *uploadSpecButton;
@property (weak, nonatomic) IBOutlet UIScrollView *uploadScrollView;
@property (nonatomic,unsafe_unretained) BOOL showLocationInfo;

-(UITextField *)createTextField;
- (IBAction)actionCamera:(id)sender;
- (void)actionUploadInputbatch:(id)sender;

-(BOOL)cameraSupportMedia:(NSString *)mediatype sourceType:(UIImagePickerControllerSourceType)sourcetype;
-(BOOL)isCameraAvailable;
-(BOOL)isPhotoLibraryAvailable;
-(BOOL)isCameraSupportTakingPhotos;

@end
