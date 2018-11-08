//
//  DetectionSchemeViewController.m
//  edrs
//
//  Created by bchan on 16/3/23.
//  Copyright © 2016年 julyyu. All rights reserved.
//

#import "DetectionSchemeViewController.h"

@interface DetectionSchemeViewController ()<YYTextViewDelegate,UIActionSheetDelegate>{
    
    NSMutableDictionary *locationDic;
    CLLocationCoordinate2D toPoint ;
    NSString *_addressName ;
}

@end
#define SYSTEM_VERSION_LESS_THAN(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
@implementation DetectionSchemeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Utility configuerNavigationBackItem:self];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.availableMaps = [[NSMutableArray alloc]init];
    locationDic = [[NSMutableDictionary alloc]init];
    if(_isReport){
        self.title = @"监测报告";
        [_mDownloadButton setTitle:@"下载完整监测报告" forState:UIControlStateNormal];
        [_mCheckPdfButton setTitle:@"查看完整监测报告" forState:UIControlStateNormal];
    }else{
        self.title = @"监测方案";

        [_mDownloadButton setTitle:@"下载完整监测方案" forState:UIControlStateNormal];
        [_mCheckPdfButton setTitle:@"查看完整监测方案" forState:UIControlStateNormal];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self getDetectionScheme];
    });
    [self checkPdfExsit];
    
    //获取定位
    mLocService = [[BMKLocationService alloc]init];
    mLocService.delegate = self;
    // [BMKLocationService setLocationDistanceFilter:5.0f];    //变化精度5m
    mLocService.distanceFilter = 5.0f;
    [mLocService startUserLocationService];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getReportfile{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
  
    [dic setValue:self.did  forKey:@"disasterid"];
    [dic setValue:[self.dsid UUIDString]  forKey:@"reportid"];
    
    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@",EDRSHTTP, EDRSHTTP_GET_DETECTION_Repot_FILE] params:dic success:^(id responseObj) {
        //
        NSLog(@"get plan success , response = %@", responseObj);
        
    } failure:^(NSError *err) {
        //
        NSLog(@"err");
    }];

}



-(void)setYYLableTextWith:(NSString *)textStr addressList:(NSArray *)addressList{
     NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:textStr];
    attributeStr.font = [UIFont systemFontOfSize:17];
    attributeStr.color = [UIColor blackColor];
    for (NSInteger i = 0; i<addressList.count; i++) {
        NSRange addressRange = [textStr rangeOfString:addressList[i]];
        [attributeStr setTextHighlightRange:addressRange
                             color:[UIColor  blueColor]
                   backgroundColor:[UIColor clearColor]
                         tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
                             NSString *contet =[text.string substringWithRange:range];
                             NSString *locationStr = [locationDic valueForKey:contet];
                             NSArray *items = [locationStr componentsSeparatedByString:@","];
                             if(items.count ==2){
                                 CLLocationCoordinate2D location = {[items[0] floatValue],[items[1] floatValue]};
                                 [self navigateAction:location name:contet ];
                             }else{
                                 NSLog(@"经纬度异常");
                             }
                         }];
    }
   
    _mTextView.attributedText = attributeStr;
    _mTextView.selectable = NO;
}

- (BOOL)textViewShouldBeginEditing:(YYTextView *)textView{
    return NO;
}
-(void)getDetectionScheme{
//    NSString *staffid = [CustomAccount sharedCustomAccount].user.userId;
//    NSString *planid = [self.dsid UUIDString];
//   
//    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
//    [params setValue:staffid forKey:@"staffId"];
//    [params setValue:planid forKey:@"planId"];
//    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@?",EDRSHTTP, EDRSHTTP_DETECTION_SCHEME] params:params success:^(id responseObj) {
    NSString *staffid = [CustomAccount sharedCustomAccount].user.userId;
    NSString *planid = [self.dsid UUIDString];
    
    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@?staffId=%@&planId=%@",EDRSHTTP, EDRSHTTP_DETECTION_SCHEME, staffid, planid] params:@{} success:^(id responseObj) {
        //
        NSLog(@"get plan success , response = %@", responseObj);
        mPersonalSchemeList = responseObj;
        NSString *strs = @"";
        NSMutableArray *addressArray=[[NSMutableArray alloc]init];
        NSLog(@"%lu",(unsigned long)mPersonalSchemeList.count);
        for (int i = 0; i < mPersonalSchemeList.count; i++) {
            NSMutableDictionary *item = [[NSMutableDictionary alloc]initWithDictionary:mPersonalSchemeList[i]];
           
            [addressArray addObject:item[@"name"]];
            NSString *locationStr = [NSString stringWithFormat:@"%@,%@",item[@"lat"],item[@"lng"]];
            [locationDic setValue:locationStr forKey:item[@"name"]];
            NSString *tmptitle = [NSString stringWithFormat:@"监测地点：%@ \n", item[@"name"]];
            NSString *tmpcontents = @"";
            NSMutableArray *chems = item[@"chems"];
            for (int j = 0; j < chems.count; j++) {
                NSMutableDictionary *tmpchem = chems[j];
                
                NSString *tmpitemstr = [NSString stringWithFormat:@"监测项目：%@\n监测频次：%@\n监测方法：%@\n使用仪器：%@\n", tmpchem[@"name"],tmpchem[@"freq"],tmpchem[@"method"],tmpchem[@"equip"]];
                tmpcontents = [tmpcontents stringByAppendingString:tmpitemstr];
            }
            
            NSString *tmpstr = [tmptitle stringByAppendingString:tmpcontents];
            strs = [strs stringByAppendingString:tmpstr];
        }
        [self setYYLableTextWith:strs addressList:addressArray];
//        NSLog(@"%@",strs);
//        [self.mTextView setText:strs];
//        [self.mTextView setFont:[UIFont systemFontOfSize:17.0f]];
        
    } failure:^(NSError *err) {
        //
        NSLog(@"err");
    }];
}

- (IBAction)actionDownloadPDF:(id)sender {
    [self performSelector:@selector(downloadPdf) withObject:nil afterDelay:0.1];
//    [self downloadPdf];
}

-(void)downloadPdf{
    NSString *sandboxpath = NSHomeDirectory();
    NSString *forlderpath = [sandboxpath stringByAppendingPathComponent:[NSString stringWithFormat:@"/Documents/edrsCache/Download"]];
    BOOL isdir;
    if(![[NSFileManager defaultManager] fileExistsAtPath:forlderpath isDirectory:&isdir]){
        [[NSFileManager defaultManager] createDirectoryAtPath:forlderpath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *filepath = [forlderpath stringByAppendingString:[NSString stringWithFormat:@"/%@.pdf",[self.dsid UUIDString]]];
    NSURL *url;
    if(_isReport){
         url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/api/disaster/getreportfile?disasterid=%@&reportid=%@",[CustomAccount sharedCustomAccount].stationUrl,self.did  ,[self.dsid UUIDString]]];
    }else{
       url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/api/plan/getPdf?id=%@",[CustomAccount sharedCustomAccount].stationUrl, [self.dsid UUIDString]]];
    }
    
    DMLog(@"url==%@",url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue: [CustomAccount sharedCustomAccount].user.token forHTTPHeaderField:@"Authorization"];
    
  /*
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response)  {
         return nil;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"%@",error.description);
        
    }];
     [downloadTask resume];*/
    
   
    AFURLConnectionOperation *operation = [[AFURLConnectionOperation alloc]initWithRequest:request];
    operation.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    operation.securityPolicy.validatesDomainName = NO;
    operation.securityPolicy.allowInvalidCertificates = YES;
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filepath append:NO];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float progress = (float)totalBytesRead/ totalBytesExpectedToRead;
        
        [self.mProgressLabel setText:[NSString stringWithFormat:@"%0.0f%%",progress*100]];
        if(progress == 1.0){
            NSLog(@"下载结束");
            [self.mCheckPdfButton setHidden:NO];
            [self.mDownloadButton setHidden:YES];
            [self.mProgressLabel setHidden:YES];
        }
    }];
    
    [operation setCompletionBlock:^{
        NSLog(@"complete");
    }];
    
    [operation start];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"PdfViewSegue"]) {
        MyPDFViewController *targetVC = segue.destinationViewController;
        targetVC.mPdfId = self.dsid;
    }
}

-(void)checkPdfExsit{
    NSString *sandboxpath = NSHomeDirectory();
    NSString *filepath = [sandboxpath stringByAppendingPathComponent:[NSString stringWithFormat:@"/Documents/edrsCache/Download/%@.pdf", [self.dsid UUIDString]]];
    BOOL isdir;
    if(![[NSFileManager defaultManager] fileExistsAtPath:filepath isDirectory:&isdir]){
        //文件不存在 显示下载按钮
        [self.mDownloadButton setHidden:NO];
        [self.mCheckPdfButton setHidden:YES];
    }
    else{
        [self.mDownloadButton setHidden:YES];
        [self.mCheckPdfButton setHidden:NO];
    }
}

#pragma mark Navigation Using External Map Apps

- (void)availableMapsApps:(CLLocationCoordinate2D)targetCoordinate targetName:(NSString*)toName{
    [self.availableMaps removeAllObjects];
    
    CLLocationCoordinate2D startCoor = mLocationCoor;
    CLLocationCoordinate2D endCoor = targetCoordinate;
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://map/"]]){
        NSString *urlString = [NSString stringWithFormat:@"baidumap://map/direction?origin=latlng:%f,%f|name:我的位置&destination=latlng:%f,%f|name:%@&mode=transit",
                               startCoor.latitude, startCoor.longitude, endCoor.latitude, endCoor.longitude, toName];
        
        NSDictionary *dic = @{@"name": @"百度 ",
                              @"url": urlString};
        [self.availableMaps addObject:dic];
    }
    
    NSBundle*bundle =[NSBundle mainBundle];
    NSDictionary*info =[bundle infoDictionary];
    NSString*prodName =[info objectForKey:@"CFBundleDisplayName"];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        NSString *urlString = [NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=applicationScheme&poiname=%@&poiid=BGVIS&lat=%f&lon=%f&dev=0&style=3",
                               prodName,toName, endCoor.latitude, endCoor.longitude];
        
        NSDictionary *dic = @{@"name": @"高德地图",
                              @"url": urlString};
        [self.availableMaps addObject:dic];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        NSString *urlString = [NSString stringWithFormat:@"comgooglemaps://?saddr=&daddr=%f,%f¢er=%f,%f&directionsmode=transit", endCoor.latitude, endCoor.longitude, startCoor.latitude, startCoor.longitude];
        
        NSDictionary *dic = @{@"name": @"Google Maps",
                              @"url": urlString};
        [self.availableMaps addObject:dic];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
        CLLocationCoordinate2D startCoor = mLocationCoor;
        CLLocationCoordinate2D endCoor = toPoint;
        
        if (SYSTEM_VERSION_LESS_THAN(@"6.0")) { // ios6以下，调用google map
            
            NSString *urlString = [[NSString alloc] initWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f&dirfl=d",startCoor.latitude,startCoor.longitude,endCoor.latitude,endCoor.longitude];
        
            urlString =  [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *aURL = [NSURL URLWithString:urlString];
            [[UIApplication sharedApplication] openURL:aURL];
        } else{// 直接调用ios自己带的apple map
            
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:endCoor addressDictionary:nil];
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:placemark];
            toLocation.name = _addressName;
            
            [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                           launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
            
        }
    }else if (buttonIndex < self.availableMaps.count+1) {
        NSDictionary *mapDic = self.availableMaps[buttonIndex-1];
        NSString *urlString = mapDic[@"url"];
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlString];
        //DEBUG_LOG(@"\n%@\n%@\n%@", mapDic[@"name"], mapDic[@"url"], urlString);
        [[UIApplication sharedApplication] openURL:url];
    }
}

-(void)navigateAction:(CLLocationCoordinate2D)toLocation  name:(NSString *)addressName {
    toPoint = toLocation ;
    _addressName = addressName ;

    [self availableMapsApps:toLocation targetName:addressName];
    UIActionSheet *action = [[UIActionSheet alloc] init];
    
    [action addButtonWithTitle:@"使用系统自带地图导航"];
    for (NSDictionary *dic in self.availableMaps) {
        [action addButtonWithTitle:[NSString stringWithFormat:@"使用%@导航", dic[@"name"]]];
    }
    [action addButtonWithTitle:@"取消"];
    action.cancelButtonIndex = self.availableMaps.count + 1;
    action.delegate = self;
    [action showInView:self.view];
    
}

-(void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    if (mLocationCoor.latitude != userLocation.location.coordinate.latitude
        || mLocationCoor.longitude != userLocation.location.coordinate.longitude) {
        mLocationCoor = userLocation.location.coordinate;
    }
}


@end
