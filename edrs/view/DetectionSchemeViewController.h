//
//  DetectionSchemeViewController.h
//  edrs
//
//  Created by bchan on 16/3/23.
//  Copyright © 2016年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomHttp.h"
#import "CustomAccount.h"
#import "MyPDFViewController.h"
#import "AFURLSessionManager.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <MapKit/MapKit.h>
#import "YYKit.h"
@interface DetectionSchemeViewController : UIViewController<BMKLocationServiceDelegate>{
    NSMutableArray *mPersonalSchemeList;
    CLLocationCoordinate2D mLocationCoor;
    NSString *name;
    BMKLocationService *mLocService;
}
@property (retain, nonatomic) NSMutableArray *availableMaps;
@property (weak, nonatomic) NSUUID *dsid;
@property (strong , nonatomic) NSString *did;
@property (strong , nonatomic) NSString *reportId;
@property (unsafe_unretained, nonatomic) BOOL isReport;
@property (weak, nonatomic) IBOutlet YYTextView *mTextView;
@property (weak, nonatomic) IBOutlet UIButton *mnavigatButton;
@property (weak, nonatomic) IBOutlet UIButton *mDownloadButton;
@property (weak, nonatomic) IBOutlet UIButton *mCheckPdfButton;
@property (weak, nonatomic) IBOutlet UILabel *mProgressLabel;

-(void)getDetectionScheme;
- (IBAction)actionDownloadPDF:(id)sender;

-(void)downloadPdf;
-(void)checkPdfExsit;
@end
