//
//  QRCodeReaderViewController.h
//  ZTOA
//
//  Created by linPeng on 15-7-25.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Define.h"

@protocol QRCodeReaderViewControllerDelegate

-(void)getQRCodeWithSting:(NSString *)code;

@end
@interface QRCodeReaderViewController : UIViewController

@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;

@property (strong,nonatomic)AVCaptureMetadataOutput * output;

@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic) NSTimer *timer;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;
@property (unsafe_unretained,nonatomic) BOOL isMenu;
@property (nonatomic,unsafe_unretained) id<QRCodeReaderViewControllerDelegate>delegate;
@end
