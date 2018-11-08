//
//  CasesInfomationViewController.m
//  edrs
//
//  Created by 俞乃胜, Stephen on 2017/12/7.
//  Copyright © 2017年 julyyu. All rights reserved.
//

#import "CasesInfomationViewController.h"
#import "CustomHttp.h"

@interface CasesInfomationViewController ()<UIWebViewDelegate>
@end

@implementation CasesInfomationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customNavigationBar];
    
    if ([self isFileExist:self.archiveId]) {
        DMLog(@"已存在");
        [self showFile];
        
    }{
        DMLog(@"不存在");
        [self downLoad];

    }
    
}

#pragma mark --判断是否已经在下载过
- (BOOL) isFileExist:(NSString *)fileName{
    NSString *sandboxpath = NSHomeDirectory();
    NSString *forlderpath = [sandboxpath stringByAppendingPathComponent:[NSString stringWithFormat:@"/Documents/edrsCache/Download"]];
    NSString *filePath =[forlderpath stringByAppendingString:[NSString stringWithFormat:@"/%@%@",fileName,self.fileType]];
    NSFileManager *fileManager =[NSFileManager defaultManager];
    BOOL result =[fileManager fileExistsAtPath:filePath];
    return result;
    
}

#pragma mark --下载word
- (void)downLoad{
    
    NSString *sandboxpath = NSHomeDirectory();
    NSString *forlderpath = [sandboxpath stringByAppendingPathComponent:[NSString stringWithFormat:@"/Documents/edrsCache/Download"]];
    BOOL isdir;
    if(![[NSFileManager defaultManager] fileExistsAtPath:forlderpath isDirectory:&isdir]){
        [[NSFileManager defaultManager] createDirectoryAtPath:forlderpath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *filepath = [forlderpath stringByAppendingString:[NSString stringWithFormat:@"/%@%@",self.archiveId,self.fileType]];
    NSURL *url;
    
    url =[NSURL URLWithString:[NSString stringWithFormat:@"https://%@/api/archive/GetArchiveAttByArchiveId?archiveId=%@",[CustomAccount sharedCustomAccount].stationUrl,self.archiveId]];
        DMLog(@"url==%@",url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    DMLog(@"token====%@",[CustomAccount sharedCustomAccount].user.token);
    [request setValue: [CustomAccount sharedCustomAccount].user.token forHTTPHeaderField:@"Authorization"];

    AFURLConnectionOperation *operation = [[AFURLConnectionOperation alloc]initWithRequest:request];
    operation.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    operation.securityPolicy.validatesDomainName = NO;
    operation.securityPolicy.allowInvalidCertificates = YES;
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filepath append:NO];
    DMLog(@"filepath=%@",filepath);

    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float progress = (float)totalBytesRead/ totalBytesExpectedToRead;
        DMLog(@"没有权限下载：%f",progress);
      //  [self.mProgressLabel setText:[NSString stringWithFormat:@"%0.0f%%",progress*100]];
        if(progress == 1.0){
            NSLog(@"下载结束");
            DMLog(@"0000====%@",forlderpath);
            [self showFile];
        }
    }];
    
    [operation setCompletionBlock:^{
        NSLog(@"complete");
        [self showFile];
    }];
    [operation start];
}

#pragma mark --展示文件
- (void)showFile{
    NSString *sandboxpath = NSHomeDirectory();
    NSString *forlderpath = [sandboxpath stringByAppendingPathComponent:[NSString stringWithFormat:@"/Documents/edrsCache/Download"]];
    NSString *filePath =[forlderpath stringByAppendingString:[NSString stringWithFormat:@"/%@%@",self.archiveId,self.fileType]];
    
    UIWebView *webV =[[UIWebView alloc]init];
    webV.delegate =self;
    webV.scalesPageToFit =YES;
    [self.view addSubview:webV];
    [webV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets =UIEdgeInsetsMake(0, 0, 0, 0);
    }];
    [webV loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:filePath]]];
    
}


#pragma mark --自定义导航栏
- (void)customNavigationBar{
        self.automaticallyAdjustsScrollViewInsets =NO;
        self.navigationController.navigationBar.hidden =NO;
        self.tabBarController.tabBar.hidden =YES;
    
        UIButton *img =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 18, 18)];
        [img addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        [img setImage:[UIImage imageNamed:@"back_fistpage"]
             forState:UIControlStateNormal];
        [img setImageEdgeInsets:UIEdgeInsetsMake(0, -8, 0, 8)];
        UIBarButtonItem *left =[[UIBarButtonItem alloc]initWithCustomView:img];
        left.tintColor =[UIColor lightGrayColor];
        self.navigationItem.leftBarButtonItem =left;
   
}

- (void)goBack{

    [self.navigationController popViewControllerAnimated:YES];
}

@end
