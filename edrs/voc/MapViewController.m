//
//  MapViewController.m
//  VOC
//
//  Created by 林鹏, Leon on 2017/3/15.
//  Copyright © 2017年 林鹏, Leon. All rights reserved.
//

#import "MapViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import "SamplePlanModel.h"
@interface MapViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,UIActionSheetDelegate>{
    BMKMapView * _mapView ;
    BMKLocationService *_locService;
    BMKPointAnnotation *mCenterPoint;
    NSMutableArray *availableMaps;
    NSString *toName;
}

@end

@implementation MapViewController


- (void)addPointAnnotation
{
    for (SamplePlanModel *subModel in _planList) {
        BMKPointAnnotation *pointAnnotation = [[BMKPointAnnotation alloc]init];
        CLLocationCoordinate2D coor;
        coor.latitude = subModel.lat;
        coor.longitude =subModel.lng;
        pointAnnotation.coordinate = coor;
        pointAnnotation.title = subModel.name;
        [_mapView addAnnotation:pointAnnotation];
    }
 
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:_mapView];
    
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    //启动LocationService
    [_locService startUserLocationService];
    
    availableMaps= [[NSMutableArray alloc]init];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    _mapView.showsUserLocation = YES ;
 
    [self performSelector:@selector(addPointAnnotation) withObject:nil afterDelay:1];
    [[AppDelegate sharedInstance].drawerVC setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
 
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [BMKMapView enableCustomMapStyle:NO];//关闭个性化地图
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willStartLocatingUser
{
    NSLog(@"start locate");
}

/**
 *在停止定位后，会调用此函数
 */
- (void)didStopLocatingUser{
    
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation{
    
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
      [_mapView updateLocationData:userLocation];
}

-(NSInteger)getIndexFromeArray:(id <BMKAnnotation>)annotation{
    BMKPointAnnotation *point = (BMKPointAnnotation *)annotation;
    for (NSInteger i = 0; i<_planList.count; i++) {
        SamplePlanModel *model = [_planList objectAtIndex:i];
        if(point.coordinate.latitude == model.lat && point.coordinate.longitude == model.lng){
            return i;
        }
    }
    
    return 0;
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
   
    NSString *AnnotationViewID = @"renameMark";
    BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        annotationView.pinColor = BMKPinAnnotationColorPurple;
        annotationView.animatesDrop = YES;
    }
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.tag = [self getIndexFromeArray:annotation];
    btn.frame = CGRectMake(0, 0, 120, 35);
    [btn setTitle:@"导航" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(navigateAction:) forControlEvents:UIControlEventTouchUpInside];
    annotationView.rightCalloutAccessoryView= btn ;
    
    return annotationView;

    
}

// 当点击annotation view弹出的泡泡时，调用此接口
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view;
{
    NSLog(@"paopaoclick");
}

#pragma mark Navigation Using External Map Apps

- (void)availableMapsApps:(CLLocationCoordinate2D)targetCoordinate targetName:(NSString*)toName{
    [availableMaps removeAllObjects];

    CLLocationCoordinate2D startCoor = mCenterPoint.coordinate;
    CLLocationCoordinate2D endCoor = targetCoordinate;
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://map/"]]){
        NSString *urlString = [NSString stringWithFormat:@"baidumap://map/direction?origin=latlng:%f,%f|name:我的位置&destination=latlng:%f,%f|name:%@&mode=transit",
                               startCoor.latitude, startCoor.longitude, endCoor.latitude, endCoor.longitude, toName];
        
        NSDictionary *dic = @{@"name": @"百度地图",
                              @"url": urlString};
        [availableMaps addObject:dic];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        NSString *urlString = [NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=applicationScheme&poiname=fangheng&poiid=BGVIS&lat=%f&lon=%f&dev=0&style=3",
                               @"云华时代", endCoor.latitude, endCoor.longitude];
        
        NSDictionary *dic = @{@"name": @"高德地图",
                              @"url": urlString};
        [availableMaps addObject:dic];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        NSString *urlString = [NSString stringWithFormat:@"comgooglemaps://?saddr=&daddr=%f,%f¢er=%f,%f&directionsmode=transit", endCoor.latitude, endCoor.longitude, startCoor.latitude, startCoor.longitude];
        
        NSDictionary *dic = @{@"name": @"Google Maps",
                              @"url": urlString};
        [availableMaps addObject:dic];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        CLLocationCoordinate2D startCoor = mCenterPoint.coordinate;
        CLLocationCoordinate2D endCoor = CLLocationCoordinate2DMake(startCoor.latitude+0.01, startCoor.longitude+0.01);
    
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:endCoor addressDictionary:nil];
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:placemark];
            toLocation.name = toName;
            
            [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                           launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
        
    }else if (buttonIndex < availableMaps.count+1) {
        NSDictionary *mapDic = availableMaps[buttonIndex-1];
        NSString *urlString = mapDic[@"url"];
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlString];
        //DEBUG_LOG(@"\n%@\n%@\n%@", mapDic[@"name"], mapDic[@"url"], urlString);
        [[UIApplication sharedApplication] openURL:url];
    }
}


-(NSArray *)getMapTitles{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (NSDictionary *sub in availableMaps) {
        [array addObject:[sub valueForKey:@"name"]];
    }
    
    return array;
}
-(void)navigateAction:(id)sender {
    NSInteger idx=((UIButton*)sender).tag;
    
    CLLocationCoordinate2D coord;

    SamplePlanModel *model = [_planList objectAtIndex:idx];
    coord.longitude = model.lng ;
    coord.latitude = model.lat ;
    
    toName = model.name ;
    [self availableMapsApps:coord targetName:toName];
    
    
    UIActionSheet *action = [[UIActionSheet alloc] init];
    
    [action addButtonWithTitle:@"使用系统自带地图导航"];
    for (NSDictionary *dic in availableMaps) {
        [action addButtonWithTitle:[NSString stringWithFormat:@"使用%@导航", dic[@"name"]]];
    }
    [action addButtonWithTitle:@"取消"];
    action.cancelButtonIndex = availableMaps.count + 1;
    action.delegate = self;
    [action showInView:self.view];
    
}

@end
