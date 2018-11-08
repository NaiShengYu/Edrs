//
//  PDFViewController.h
//  edrs
//
//  Created by bchan on 16/3/24.
//  Copyright © 2016年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "CustomAccount.h"
#import <WebKit/WebKit.h>
@interface MyPDFViewController : UIViewController<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *mPdfWebView;
@property (weak, nonatomic) NSUUID *mPdfId;
@property (weak, nonatomic) NSString *did;
-(void)showPdfInWebView;

@end
