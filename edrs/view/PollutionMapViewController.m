//
//  PollutionMapViewController.m
//  edrs
//
//  Created by 余文君, July on 15/8/20.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "PollutionMapViewController.h"
#import "CustomHttp.h"
#import "NearNameSearchViewController.h"
@interface PollutionMapViewController ()<UITextFieldDelegate>{
    NSString *locationStr;
    NSString *addreddStr;
    NSInteger rowCount;
    UITextField *pointNameTF ;
    NSString *latStr;
    NSString *logStr;
    
    BMKCircle *cir;
 
}

@end

@implementation PollutionMapViewController

-(void)submitAction{
  
     [self actionSubmitPollutionLocation];
}
-(void)configuerNavigationRightItem{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 40)];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(submitAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    rowCount = _isPoint?3 : 2;
    if(_isPoint){
       
        [self configuerNavigationRightItem];
        self.title = @"新增采样点";
        _tableHeight.constant = 44*4;
        pointNameTF = [[UITextField alloc]initWithFrame:CGRectMake(110, 0, SCREEN_WIDTH-110, 44)];
        pointNameTF.placeholder = @"请输入采样点名称";
        pointNameTF.textAlignment = NSTextAlignmentRight;
        pointNameTF.returnKeyType = UIReturnKeyDone;
        pointNameTF.delegate = self;
    }else{
        _tableHeight.constant = 44*3;
    }
    [Utility configuerNavigationBackItem:self];
    //添加地图
    mMapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 44*(rowCount+1), self.view.frame.size.width, SCREEN_HEIGHT - 64 - 44*(rowCount+1))];
    mMapView.delegate = self;

    //获取定位
    mLocService = [[BMKLocationService alloc]init];
    mLocService.delegate = self;
    //[BMKLocationService setLocationDistanceFilter:5.0f];    //变化精度5m
    mLocService.distanceFilter = 5.0f;
    [mLocService startUserLocationService];
    
    //初始化
    mMarkLocationLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, 44)];
    [mMarkLocationLabel setTextAlignment:NSTextAlignmentCenter];
    [mMarkLocationLabel setTextColor:BLUE_COLOR];
    [self.locationTableView setScrollEnabled:NO];
    mSelectedIndex = -1;
    
    
    UIButton *but =[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-70, 44*(rowCount+1)+20, 50, 50)];
    [but setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    but.backgroundColor =LIGHT_BLUE;
    but.layer.cornerRadius =25;
    but.layer.masksToBounds = YES;
    [but setImageEdgeInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    [but addTarget:self action:@selector(searchBut) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:but];
    
    
    [self updateMiscMarkers];
    if (CLLocationCoordinate2DIsValid(mLocationCoor)) {
        [self tableView:self.locationTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    }
    
}

#pragma mark --搜索功能
- (void)searchBut{
    
    NearNameSearchViewController *searchVC =[[NearNameSearchViewController alloc]init];
    searchVC.location =mLocationCoor;
    UINavigationController *nav =[[UINavigationController alloc]initWithRootViewController:searchVC];
    
    searchVC.selectSucceseBlock = ^(CLLocationCoordinate2D location) {
        mMapView.delegate = self;
        [mMapView setCenterCoordinate:location];
        [self mapView:mMapView onClickedMapBlank:location];
        [self tableView:self.locationTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    };
    [self presentViewController:nav animated:YES completion:nil];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [mMapView viewWillAppear];
   
    mMapView.delegate = self;
    mLocService.delegate = self;

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [mMapView viewWillDisappear];
//    [mMapView removeAnnotation:mPointAnnotation];
//    [mMapView removeAnnotations:mMapView.annotations];
    mMapView.delegate = nil;
    mLocService.delegate = nil;
    
}
-(void)dealloc{
    NSLog(@"dealloc");
}

-(UIButton *)locationButton{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-60, SCREEN_HEIGHT-64-60, 40, 40)];
    [button setImage:[UIImage imageNamed:@"dingwei"] forState:UIControlStateNormal];
    return button;
}

-(void)mapViewSettings{
    if(mLocationCoor.longitude != 0 && mLocationCoor.latitude != 0){
        [self.view addSubview:mMapView];
        [self.view sendSubviewToBack:mMapView];
        //设定当前地图的通用参数
        [mMapView setMapType:BMKMapTypeSatellite];
        [mMapView setShowsUserLocation:YES];
        
        //根据坐标显示地图

//        NSLog(@"%f,%f",mLocationCoor.latitude, mLocationCoor.longitude);
//        [mMapView setCenterCoordinate:mLocationCoor];
//        [mMapView setZoomEnabled:YES];
//        [mMapView setZoomLevel:14.0f];
    }
    else{
        //定位失败，是否需要默认位置
    }
    //[mGetLocationTimer invalidate];
}

#pragma mark -经纬度反编译
-(void)getGeoCode:(NSString *)remark{
    NSArray *items = [remark componentsSeparatedByString:@","];
    CLLocationCoordinate2D locationPoint = {[items[1] floatValue],[items[0] floatValue]};
    BMKReverseGeoCodeOption *reverseGCO = [[BMKReverseGeoCodeOption alloc]init];
    reverseGCO.reverseGeoPoint = locationPoint;
    BMKGeoCodeSearch *geoCodeSearch = [[BMKGeoCodeSearch alloc]init];
    geoCodeSearch.delegate = self ;
    BOOL flag = [geoCodeSearch reverseGeoCode:reverseGCO];
    if(flag){
        NSLog(@"地理反检索成功");
    }else{
        NSLog(@"地理反检索失败");
    }
}

-(void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    if(error ==0){
        NSLog(@"%@",result.addressDetail.province);
        //        address = result.address;
        if(!_isPoint){
            [self setLocation: [NSString stringWithFormat:@"%@_$%@",locationStr,result.address]];
        }else{
            //
           
            [self addSamplePlanPoint:result.address];
        }
    }
}

-(void)addSamplePlanPoint:(NSString *)address {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:self.disasterid forKey:@"refid"];
    [parameters setValue:logStr forKey:@"lng"];
    [parameters setValue:latStr forKey:@"lat"];
    [parameters setValue:pointNameTF.text forKey:@"name"];
    [parameters setValue:@"" forKey:@"pretreatment"];
    [parameters setValue:@""  forKey:@"qctip"];
    [parameters setValue:@""  forKey:@"remarks"];
    [parameters setValue:@""  forKey:@"security"];
    @weakify(self);
    [[AppDelegate sharedInstance].httpTaskManager postWithPortPath:@"/api/Sampleplan/Add" parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        @strongify(self);
        NSString *data = [dictionary valueForKey:@"data"];
        data = [data stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        data = [data stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        if([data length]>0){
            [SVProgressHUD showSuccessWithStatus:@"提交成功"];
            [parameters setValue:data forKey:@"id"];
            MAIN(^{
             
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:kAddNewSamplePoint object:parameters];
                [self.navigationController popViewControllerAnimated:YES];
            });
           
        }
    } onError:^(NSError *engineError) {
        
    }];
}

-(void)setLocation:(NSString *)locationStr{
    [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@", EDRSHTTP, EDRSHTTP_DISASTER_SETLOCATION] params:@{@"disasterid":self.disasterid, @"staffid":[CustomAccount sharedCustomAccount].user.userId,@"location":locationStr}
                success:^(id responseObj) {
                    NSLog(@"get pollution in radius , response = %@", responseObj);
                    [SVProgressHUD showSuccessWithStatus:@"经纬度上传成功"];
//                     NSDictionary *dic = [[NSDictionary alloc]initWithObjects:@[latStr,logStr] forKeys:@[@"lat", @"lng"]];
                       SD.location =  (CLLocationCoordinate2D){[latStr floatValue],[logStr floatValue]};
//                    MAIN(^{
//                     
//                        [[NSNotificationCenter defaultCenter]
//                         postNotificationName:kAddPollution object:nil];
//                    });
                    [self.navigationController popViewControllerAnimated:YES];
                }
                failure:^(NSError *err) {
                    NSLog(@"fail to get pollution in radius, error = %@", err);
                }];
}

-(void)getGpsInfo:(CLLocationCoordinate2D)coordintate{
    @weakify(self);
    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@", EDRSHTTP, EDRSHTTP_DISASTER_GETGPS] params:@{@"lng":[NSString stringWithFormat:@"%f",coordintate.longitude], @"lat":[NSString stringWithFormat:@"%f", coordintate.latitude]}
                 success:^(id responseObj) {
                     @strongify(self);
                     NSLog(@"get pollution in radius , response = %@", responseObj);
                     latStr = [responseObj valueForKey:@"lat"];
                     logStr = [responseObj valueForKey:@"lng"];
                     locationStr = [NSString stringWithFormat:@"%@,%@",logStr,latStr];
                     [self getGeoCode:locationStr];
                    
                 }
                 failure:^(NSError *err) {
                     NSLog(@"fail to get pollution in radius, error = %@", err);
                 }];
}


- (void)actionSubmitPollutionLocation{
    //确认当前选择项目，并回传污染源位置
    if (mSelectedIndex != -1) {
        
        if(_isPoint && [pointNameTF.text length]==0){
            [SVProgressHUD showErrorWithStatus:@"请输入采样点名称"];
            return ;
        }
        
        if (mSelectedIndex == rowCount-2) {
            //选择当前坐标
            if (mLocationCoor.latitude != 0 && mLocationCoor.longitude != 0) {
                [self getGpsInfo:mLocationCoor];
                
            }
            else{
                [CustomUtil showMBProgressHUD:@"请检查当前定位设置，找不到定位" view:self.view animated:YES];
            }
        }
        else if(mSelectedIndex == rowCount-1){
            if (mPointAnnotation.coordinate.longitude != 0 && mPointAnnotation.coordinate.latitude != 0) {
                [self getGpsInfo:mPointAnnotation.coordinate];
                
            }
            else{
                [CustomUtil showMBProgressHUD:@"请在地图上标注位置" view:self.view animated:YES];
            }
        }
    }
    else{
        [CustomUtil showMBProgressHUD:@"请选择污染源位置" view:self.view animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - location delegate
-(void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    if (mLocationCoor.latitude != userLocation.location.coordinate.latitude
        || mLocationCoor.longitude != userLocation.location.coordinate.longitude) {
        mLocationCoor = userLocation.location.coordinate;
        [self.locationTableView reloadData];
        //        [self.locationCoordicateLabel setText:[NSString  stringWithFormat:@"%0.05fE , %0.05fN",
        //                                               mLocationCoor.longitude,
        //                                               mLocationCoor.latitude]];
        [self mapViewSettings];
        [self mapView:mMapView onClickedMapBlank:mLocationCoor];

    }
}

#pragma mark - tableview delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return rowCount;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == rowCount-1){
        return 88;
    }else{
        return 44;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    else{
        while([[cell.contentView subviews] lastObject]){
            [[[cell.contentView subviews] lastObject] removeFromSuperview];
        }
    }
 
    if(_isPoint && indexPath.row ==0){
        [cell.textLabel setText:@"采样点名称"];
        [cell.contentView addSubview:pointNameTF];
    }
    if ( indexPath.row == rowCount-2) {
        [cell.textLabel setText:[NSString stringWithFormat: @"使用当前位置 %0.05fE , %0.05fN",mLocationCoor.longitude,mLocationCoor.latitude]];
    }
    else  if ( indexPath.row == rowCount-1) {
        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, self.view.frame.size.width, 44)];
        [title setText:@"地图上标出位置"];
        [cell.contentView addSubview:title];
        [cell.contentView addSubview:mMarkLocationLabel];
    }
    
    if (mSelectedIndex == indexPath.row) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if((_isPoint && indexPath.row>0 )||!_isPoint ){
        mSelectedIndex = indexPath.row;
        [self.locationTableView reloadData];
    }
    if(!_isPoint){
          [self actionSubmitPollutionLocation];
    }
}

#pragma mark --添加污染位置
-(void)updateMiscMarkers
{
    BMKPointAnnotation *an = [[BMKPointAnnotation alloc]init];
    an.coordinate = SD.location;
    an.title = @"污染位置";
    
    if(mPollutionCenter !=nil){
        [mMapView removeAnnotation:mPollutionCenter];
    }
    mPollutionCenter=an;
    
    [mMapView addAnnotation:an];
    if(cir !=nil){
        [mMapView removeOverlay:cir];
    }
    cir=[BMKCircle circleWithCenterCoordinate:SD.location radius:(CLLocationDistance)5000.0];
    mPollCtrCircleOverlay=cir;
    [mMapView addOverlay:cir];
    
    [mMapView setCenterCoordinate:SD.location];
    [mMapView setZoomEnabled:YES];
    [mMapView setZoomLevel:14.0f];
}
//画虚线的圆圈
-(BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay{
    if (overlay == mPollCtrCircleOverlay) {
        BMKCircleView* circleView = [[BMKCircleView alloc] initWithOverlay:overlay];
        //circleView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0];
        circleView.strokeColor = LIGHTGRAY_COLOR;
        circleView.lineDash = YES;
        circleView.lineWidth=3.0;
        circleView.alpha=0.7f;
        return circleView;
    } else {
        BMKCircleView* circleView = [[BMKCircleView alloc] initWithOverlay:overlay];
        circleView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0];
        circleView.strokeColor = LIGHTGRAY_COLOR;
        circleView.lineDash = NO;
        circleView.lineWidth=2.0;
        return circleView;
    }
    return nil;
}
-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{
    // for speed up, commented for now, let's do it later
    
    
    BMKAnnotationView *annotationView=(BMKAnnotationView*)[mapView viewForAnnotation:annotation];
    
    if (annotationView == nil) {
        annotationView = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@""];
            if (annotation==mPollutionCenter){
                annotationView.image=[UIImage imageNamed:@"psmarker"];
                annotationView.centerOffset=CGPointMake(0, -16);
            }else{
                annotationView.image=[UIImage imageNamed:@"orange-circle"];
                annotationView.centerOffset=CGPointMake(0.5, 0.5);
            }
    }
    return annotationView;
}

#pragma mark - 地图手势
-(void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate{
    NSLog(@"点击地图，获取经纬度：%f, %f", coordinate.longitude, coordinate.latitude);
    if (mPointAnnotation !=nil) {
        [mMapView removeAnnotation:mPointAnnotation];
    }
     mPointAnnotation= [[BMKPointAnnotation alloc]init];
    mPointAnnotation.coordinate = coordinate;
    mPointAnnotation.title = @"当前选择坐标点";
    [mMapView addAnnotation:mPointAnnotation];
    [mMarkLocationLabel setText:[NSString stringWithFormat:@"%0.05fE , %0.05fN",
                                 coordinate.longitude,
                                 coordinate.latitude]];
}


#pragma mark UITextFiled Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}
@end
