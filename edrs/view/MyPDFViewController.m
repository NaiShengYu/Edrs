//
//  PDFViewController.m
//  edrs
//
//  Created by bchan on 16/3/24.
//  Copyright © 2016年 julyyu. All rights reserved.
//

#import "MyPDFViewController.h"

@interface MyPDFViewController ()

@end

@implementation MyPDFViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [Utility configuerNavigationBackItem:self];
    //self.pdfFileName = @"testpdf";
    NSLog(@"%@",[self.mPdfId UUIDString]);
    self.mPdfWebView.delegate= self;
    [self.mPdfWebView.scrollView setZoomScale:0.2];
    [self showPdfInWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)showPdfInWebView{
    //阅读本地文件
    NSURLRequest *requesturl ;
    if(self.did !=nil){
        //在线阅读
        NSString *teststr =[NSString stringWithFormat:@"https://%@/Home/MonitoringPlan?did=%@&srcs=1",[CustomAccount sharedCustomAccount].stationUrl,self.did];
        NSURL *testtmpurl = [NSURL URLWithString:teststr];
        requesturl = [NSURLRequest requestWithURL:testtmpurl];
    }else{
        NSString *sandboxpath = NSHomeDirectory();
        NSString *filepath = [sandboxpath stringByAppendingPathComponent:[NSString stringWithFormat:@"/Documents/edrsCache/Download/%@.pdf", [self.mPdfId UUIDString]]];
        NSLog(@"%@",filepath);
        NSURL *tmpurl = [[NSURL alloc]initWithString:filepath];
        requesturl = [[NSURLRequest alloc]initWithURL:tmpurl];
    }
    
    
    [self.mPdfWebView loadRequest:requesturl];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    
    CGFloat webViewWidth= [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollWidth"] floatValue];
    
    NSString *jsStr = [NSString stringWithFormat:@"document.body.style.zoom=%0.1f", SCREEN_WIDTH/webViewWidth];
     [webView stringByEvaluatingJavaScriptFromString:jsStr];

}
@end
