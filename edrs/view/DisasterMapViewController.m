//
//  DataLocMapViewController.m
//  edrs
//
//  Created by bchan on 15/12/19.
//  Copyright © 2015年 julyyu. All rights reserved.
//

#import "DisasterMapViewController.h"
#import "CustomUtil.h"
#import "SamplePlanModel.h"
#import "PlantTaskModel.h"
#import "TaskDetailViewController.h"
#import "PollutionMapViewController.h"
#import "Define.h"
#define SYSTEM_VERSION_LESS_THAN(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface DisasterMapViewController ()<PollutionMapDelegate>{
    NSString *specStr;
    NSMutableDictionary *taskDic;
    NSInteger dataCount;
    NSMutableArray *annArray ;
    BMKCircle *cir;
    CLLocationCoordinate2D pollutionLocation;
}

@end

static CLLocationCoordinate2D mapCenter=(CLLocationCoordinate2D){0.0,0.0};
static float mapLevel=14.0;

@implementation DisasterMapViewController



#pragma mark Network

-(NSInteger)getPointIndex:(id<BMKAnnotation>)annotation{
    for(NSInteger i = 0;i<_taskArray.count;i++){
        SamplePlanModel *model = _taskArray[i];
        if([model.name isEqualToString:annotation.title]){
            return i;
        }
    }
    
    return 0;
}


-(BOOL)checkSunItemInArray:(NSArray *)array subItem:(NSString
                                                     *)item{
    for (NSString *sub in array) {
        if([item isEqualToString:sub]){
            return YES;
        }
    }
    
    return NO;
}
-(NSArray *)getGroupArray:(NSArray *)array{
    NSMutableArray *groupArray = [[NSMutableArray alloc]init];
    NSMutableArray *typeArray = [[NSMutableArray alloc]init];
    for (PlantTaskModel *subItem in array) {
        if(![self checkSunItemInArray:typeArray subItem:subItem.typeid]){
            [typeArray addObject:subItem.typeid];
        }
    }
    
    for (NSInteger i =0 ; i<typeArray.count; i++) {
        NSMutableArray *items = [[NSMutableArray alloc]init];
        NSString *typeId = [typeArray objectAtIndex:i];
        for (PlantTaskModel *subItem in array) {
            if([typeId isEqualToString:subItem.typeid]){
                [items addObject:subItem];
            }
        }
        
        [groupArray addObject:items];
    }
    
    
    return groupArray;
}

-(void)getPlanTaskList:(SamplePlanModel *)sampleModel{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:sampleModel.id forKey:@"planid"];
    
    @weakify(self);
    [[AppDelegate sharedInstance].httpTaskManager  getWithPortPath:PLAN_TASKS parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        
        @strongify(self);
        NSMutableArray *array = [[NSMutableArray alloc]init];
        NSArray *tempArray = [dictionary valueForKey:@"Items"];
        for (NSDictionary *sub in tempArray) {
            PlantTaskModel *model = [PlantTaskModel modelWithDictionary:sub];
            [array addObject:model];
        }
        
        [taskDic setValue: [self getGroupArray:array] forKey:sampleModel.id];
        dataCount = dataCount+1;
        if(dataCount == _taskArray.count){
            [self addTaskPoint];
        }
    } onError:^(NSError *engineError) {
        
    }];
}

-(void)getSamplePlanList{
    for (SamplePlanModel *subModel in _taskArray) {
        [self getPlanTaskList:subModel];
    }
}

-(void)addTaskPoint{
    if(annArray.count>0){
        [mMapView removeAnnotations:annArray];
        [annArray removeAllObjects];
    }
    
    for (SamplePlanModel *model in _taskArray) {
        BMKPointAnnotation *an = [[BMKPointAnnotation alloc]init];
        CLLocationCoordinate2D point = CLLocationCoordinate2DMake(model.lat, model.lng);
        an.coordinate = point;
        an.title = model.name;
        
        [mMapView addAnnotation:an];
        [annArray addObject:an];
    }
}

-(void)addNewPoint:(NSNotification *)notification{
    
//    [mMapView removeAnnotations:annArray];
    
    NSDictionary *userInfo =[notification object];
    SamplePlanModel *model = [[SamplePlanModel alloc]init];
    model.name = [userInfo valueForKey:@"name"];
    model.refid = [userInfo valueForKey:@"refid"];
    model.id = [userInfo valueForKey:@"id"];
    model.lat = [[userInfo valueForKey:@"lat"] floatValue];
    model.lng = [[userInfo valueForKey:@"lng"] floatValue];
    
    NSMutableArray *temp = [[NSMutableArray alloc]init];
    [temp addObjectsFromArray:self.taskArray];
    [temp addObject:model];
    self.taskArray = temp;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"GengXinShuZu" object:temp];
    
    
    BMKPointAnnotation *an = [[BMKPointAnnotation alloc]init];
    CLLocationCoordinate2D point = CLLocationCoordinate2DMake(model.lat, model.lng);
    an.coordinate = point;
    an.title = model.name;
    
//    [mMapView addAnnotation:an];
}

-(void)addPollution:(NSNotification *)notification{
//    NSDictionary *dic = [notification object];
//    CGFloat lat  = [[dic valueForKey:@"lat"] floatValue];
//    CGFloat lng = [[dic valueForKey:@"lng" ] floatValue];
//    pollutionLocation = (CLLocationCoordinate2D){lat,lng};
    [self updateMiscMarkers];
    
}
#pragma mark UI Framework Delegates

-(void)showTaskDetailView:(id)sender{
    UIButton *button = (UIButton *)sender;
    TaskDetailViewController *taskVC = [[TaskDetailViewController alloc]init];
    taskVC.sampleModel = _taskArray[button.tag];
    [self.navigationController pushViewController:taskVC animated:YES];
}

-(NSString *)getGroupTitleStr:(NSArray *)groupArray{
    NSString *temp = @"";
    
    for (NSArray *array in groupArray ) {
        PlantTaskModel *model = [array firstObject];
        if([temp length]!=0){
            temp = [NSString stringWithFormat:@"%@ \n%@",temp,model.name];
        }else{
            temp = model.name;
        }
    }
    return temp;
}

-(BMKActionPaopaoView *)getPaopoView:(NSInteger)index{
    SamplePlanModel *model = _taskArray[index];
    NSArray *titles = [taskDic valueForKey:model.id];
   
    
    CGFloat width = [model.name boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-100, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} context:nil].size.width;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width+70, titles.count*20+50)];
    view.layer.cornerRadius = 4;
    view.backgroundColor = RGBA_COLOR(233, 233, 233, 0.8);
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, width, 30)];
    label.font = [UIFont boldSystemFontOfSize:15];
    label.text = model.name;
    [view addSubview:label];
    
    
    UILabel *subLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, view.width-20, titles.count*20)];
    subLabel.text =  [self getGroupTitleStr:titles];
    subLabel.numberOfLines = 10;
    subLabel.font = [UIFont systemFontOfSize:14];
    [view addSubview:subLabel];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(view.width-60, 8, 50, 35)];
    [btn setTitle:@"导航" forState:UIControlStateNormal];
    [btn setTitleColor:LIGHT_BLUE forState:UIControlStateNormal];
    btn.tag = index;
    [btn addTarget:self action:@selector(navigateAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, view.width-60, view.height)];
    
    [button addTarget:self action:@selector(showTaskDetailView:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = index;
    [view addSubview:button];
    return [[BMKActionPaopaoView alloc]initWithCustomView:view];
}

//-(void)configuerNavigatinRightItem{
//    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
//    [btn setTitle:@"新增" forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(addSamplePlanPoint) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
//    self.navigationItem.rightBarButtonItem = rightItem;
//}
-(void)showPollutionMapViewController:(BOOL)isPoint{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
      PollutionMapViewController *vc = [story instantiateViewControllerWithIdentifier:@"PollutionMapViewController"];
      vc.isPoint = isPoint;
      vc.disasterid = self.disasterId;
    [self.navigationController pushViewController:vc animated:YES];
}



-(void)leftButtonAction{
    [self showPollutionMapViewController:NO];
}

-(void)rightButtonAction{
    [self showPollutionMapViewController:YES];
}
-(UIView *)bottomView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-64-60, SCREEN_WIDTH, 60)];
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, (SCREEN_WIDTH-40)/2, 40)];
    if(!_hadLocation){
        [leftButton setTitle:@"新增事故坐标" forState:UIControlStateNormal];
    }else{
        [leftButton setTitle:@"修改事故坐标" forState:UIControlStateNormal];
    }
    [leftButton addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [view addSubview:leftButton];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(view.width/2, 0, 1, view.height)];
    line.backgroundColor = LIGHT_GRAN;
    line.layer.shadowOffset = CGSizeMake(2, 2);
    line.layer.shadowColor = LIGHT_GRANT.CGColor;
    [view addSubview:line];
    
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(leftButton.right+20, 10, leftButton.width, 40)];
    [rightButton setTitle:@"新增采样点" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [view addSubview:rightButton];
    
    return view;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    mMyLocAnnotation=nil;
    taskDic = [[NSMutableDictionary alloc]init];
    annArray= [[NSMutableArray alloc]init];
    [Utility configuerNavigationBackItem:self];
    //添加地图
    mMapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64-60)];
    
    if (mapCenter.latitude!=0.0 || mapCenter.longitude!=0.0){
        mMapView.centerCoordinate=mapCenter;
        mMapView.zoomLevel=mapLevel;
    } else first=true;
    
    mDataLocAnnotationList=nil;
    mDataAnnotationList=nil;
    
    //获取定位
    mLocService = [[BMKLocationService alloc]init];
    mLocService.delegate = self;
   // [BMKLocationService setLocationDistanceFilter:5.0f];    //变化精度5m
    mLocService.distanceFilter = 5.0f;
    [mLocService startUserLocationService];
    
    [self.view addSubview:[self bottomView]];
    self.availableMaps = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewPoint:) name:kAddNewSamplePoint object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPollution:) name:kAddPollution object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [mMapView viewWillAppear];
    mMapView.delegate = self;
    mLocService.delegate=self;
    pollutionLocation = SD.location;
    mDataLocList=[[NSMutableArray<DataLoc*> alloc] init];
    [mDataLocList addObjectsFromArray:SD.dataLocs];
    
    mDataLocAnnotationList=nil;
    mDataAnnotationList=nil;
    mIdDataLocDict=nil;
    taskDic= nil;
    dataCount= 0;
   
    [self updateMiscMarkers];
    [self getSamplePlanList];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [mMapView viewWillDisappear];
    mMapView.delegate = nil;
    mLocService.delegate = nil;
    [mGetRelatedDataTime invalidate];
    mGetRelatedDataTime = nil;

}
-(void)dealloc{
    NSLog(@"dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Navigation Using External Map Apps

- (void)availableMapsApps:(CLLocationCoordinate2D)targetCoordinate targetName:(NSString*)toName{
    [self.availableMaps removeAllObjects];
    
    CLLocationCoordinate2D startCoor = mLocationCoor;
    CLLocationCoordinate2D endCoor = targetCoordinate;
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://map/"]]){
        NSString *urlString = [NSString stringWithFormat:@"baidumap://map/direction?origin=latlng:%f,%f|name:我的位置&destination=latlng:%f,%f|name:%@&mode=transit",
                               startCoor.latitude, startCoor.longitude, endCoor.latitude, endCoor.longitude, toName];
        
        NSDictionary *dic = @{@"name": @"百度地图",
                              @"url": urlString};
        [self.availableMaps addObject:dic];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        NSString *urlString = [NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=applicationScheme&poiname=fangheng&poiid=BGVIS&lat=%f&lon=%f&dev=0&style=3",
                               @"云华时代", endCoor.latitude, endCoor.longitude];
        
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
        CLLocationCoordinate2D endCoor = CLLocationCoordinate2DMake(startCoor.latitude+0.01, startCoor.longitude+0.01);
        
        if (SYSTEM_VERSION_LESS_THAN(@"6.0")) { // ios6以下，调用google map
            
            NSString *urlString = [[NSString alloc] initWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f&dirfl=d",startCoor.latitude,startCoor.longitude,endCoor.latitude,endCoor.longitude];
            //        @"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f",startCoor.latitude,startCoor.longitude,endCoor.latitude,endCoor.longitude
            urlString =  [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *aURL = [NSURL URLWithString:urlString];
            [[UIApplication sharedApplication] openURL:aURL];
        } else{// 直接调用ios自己带的apple map
            
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:endCoor addressDictionary:nil];
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:placemark];
            toLocation.name = @"to name";
            
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

-(void)navigateAction:(id)sender {
    NSInteger idx=((UIButton*)sender).tag;
    
    CLLocationCoordinate2D coord;
    NSString *name;
    
   if (idx==-1){
        coord=mPollutionCenter.coordinate;
        name=mPollutionCenter.title;
    } else {
        if(idx<_taskArray.count){
            SamplePlanModel *model = _taskArray[idx];
            
            coord.latitude = model.lat;
            coord.longitude = model.lng;
            name=model.name;
        }else{
            return;
        }
    }
    
    [self availableMapsApps:coord targetName:name];
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

#pragma mark Baidu MapView Delegates

-(void)mapViewSettings{
    if(mLocationCoor.longitude != 0 && mLocationCoor.latitude != 0){
        [self.view addSubview:mMapView];
        
        
        if([specStr length]>0  ||_locationStr.length>0 ){
            UIView *topView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
            topView.backgroundColor = RGBA_COLOR(223, 223, 223, 0.4);
            
            UILabel *topLB =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, topView.frame.size.width, 25)];
            topLB.textAlignment = NSTextAlignmentRight;
            topLB.font = [UIFont systemFontOfSize:14];
            topLB.textColor = [UIColor blackColor];
            topLB.text = specStr;
            [topView addSubview:topLB ];
            
            UILabel *subLabel =[[UILabel alloc]initWithFrame:CGRectMake(0,25 , topView.frame.size.width, 25)];
            subLabel.textAlignment = NSTextAlignmentRight;
            subLabel.font = [UIFont systemFontOfSize:14];
            subLabel.textColor = [UIColor blackColor];
            subLabel.text = _locationStr;
            [topView addSubview:subLabel ];
            [self.view addSubview:topView];
        }
        //设定当前地图的通用参数
        [mMapView setMapType:BMKMapTypeSatellite];
        [mMapView setShowsUserLocation:YES];
       
        [mMapView setZoomEnabled:YES];
    }
    else{
        //定位失败，是否需要默认位置
    }
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
        
        if (annotation==mMyLocAnnotation){
            annotationView.image=[UIImage imageNamed:@"myloc"];
        } else {
            
            NSInteger index = [self getPointIndex:annotation];
            UIButton *btn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
            btn.frame = CGRectMake(0, 0, 120, 35);
            if (annotation==mPollutionCenter){
                annotationView.image=[UIImage imageNamed:@"psmarker"];
                annotationView.centerOffset=CGPointMake(0, -16);
                btn.tag=-1;
                [btn setTitle:@"导航" forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(navigateAction:) forControlEvents:UIControlEventTouchUpInside];
                annotationView.rightCalloutAccessoryView = btn;
            } else{
                annotationView.image=[UIImage imageNamed:@"orange-circle"];
                annotationView.centerOffset=CGPointMake(0, 0);
                btn.tag=index;
                annotationView.paopaoView = [self getPaopoView:index];
            }                                                                                                                                                                                                                                                                                                                                                                                                                             
        }
    }
    
    return annotationView;
}

-(void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    if (mLocationCoor.latitude != userLocation.location.coordinate.latitude
        || mLocationCoor.longitude != userLocation.location.coordinate.longitude) {
        mLocationCoor = userLocation.location.coordinate;
            [self mapViewSettings];
        
        if (mMyLocAnnotation!=nil){
            [mMapView removeAnnotation:mMyLocAnnotation];
        }

        BMKPointAnnotation *an = [[BMKPointAnnotation alloc]init];
        an.coordinate = mLocationCoor;
        an.title = @"我的位置";
        mMyLocAnnotation=an;
        [mMapView addAnnotation:an];
        
        if (first ==YES){
            first=false;
            [mMapView setCenterCoordinate:mLocationCoor];
            [mMapView setZoomLevel:14.0f];
        }
    }
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    mapCenter = mapView.centerCoordinate;
    mapLevel=mapView.zoomLevel;
}




-(void)updateMiscMarkers
{
    BMKPointAnnotation *an = [[BMKPointAnnotation alloc]init];
    an.coordinate = pollutionLocation;
    an.title = @"污染位置";
    
    if(mPollutionCenter !=nil){
        [mMapView removeAnnotation:mPollutionCenter];
    }
    mPollutionCenter=an;
    
    [mMapView addAnnotation:an];
    if(cir !=nil){
        [mMapView removeOverlay:cir];
    }
    cir=[BMKCircle circleWithCenterCoordinate:pollutionLocation radius:(CLLocationDistance)5000.0];
    mPollCtrCircleOverlay=cir;
    [mMapView addOverlay:cir];
}

#pragma mark - Retrieve data related to disaster. i.e. inputbatches and datalocs
-(void)startToGetRelatedData{
    if (!mGetRelatedDataTime) {
        mGetRelatedDataTime = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(intervalGetRelatedData) userInfo:self repeats:YES];
    }
}

-(void)intervalGetRelatedData{
    [SD retrieveInputBatchesFromServerWithNewItems:^(NSMutableArray<InputBatch*>* newItems) {
        [self addDataMarkers:newItems];
    }];

    [SD retrieveDataLocsFromServerWithNewItems:^(NSMutableArray<DataLoc*>* newItems) {
        if (mDataLocList==nil) mDataLocList=[[NSMutableArray<DataLoc*> alloc] init];
        if (mIdDataLocDict==nil) mIdDataLocDict=[[NSMutableDictionary alloc] init];
        [mDataLocList addObjectsFromArray:newItems];
        for (int i=0; i<[newItems count]; i++) {
            mIdDataLocDict[newItems[i].uniqueID]=newItems;
        }
        [self addDataLocMarkers:newItems];
    } andOldItems:^(NSMutableArray<DataLoc*>* oldItems) {
        if (mDataLocList==nil) mDataLocList=[[NSMutableArray<DataLoc*> alloc] init];
        for (int i=0; i<[oldItems count]; i++) {
            if (mIdDataLocDict[oldItems[i].uniqueID]!=nil){
                NSUInteger index=[mDataLocList indexOfObject:mIdDataLocDict[oldItems[i].uniqueID]];
                [mMapView removeAnnotation:mDataLocAnnotationList[index]];
            }
        }
    }];
}

@end
