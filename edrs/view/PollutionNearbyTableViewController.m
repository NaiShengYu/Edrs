//
//  PollutionNearbyTableViewController.m
//  edrs
//
//  Created by 余文君, July on 15/9/2.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "PollutionNearbyTableViewController.h"

@interface PollutionNearbyTableViewController ()

@end

@implementation PollutionNearbyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Utility configuerNavigationBackItem:self];
    mPollutionNearbyList = [[NSMutableArray alloc]init];
    [self getPollutionNearbyData];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [mMapView viewWillAppear];
    mMapView.delegate = self;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [mMapView viewWillDisappear];
    mMapView.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)getPollutionNearbyData{
    //附近的污染源
    [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@", EDRSHTTP, EDRSHTTP_GETDISASTER_POLLUTIONS_RADIUSE] params:@{@"stationid":[CustomAccount sharedCustomAccount].user.stationId, @"centerlng":self.lng, @"centerlat":self.lat, @"radius":@"5"}
                 success:^(id responseObj) {
                     NSLog(@"get pollution in radius , response = %@", responseObj);
                     mPollutionNearbyList = responseObj;
                     NSIndexSet *nd = [[NSIndexSet alloc]initWithIndex:1];
                     [self.tableView reloadSections:nd withRowAnimation:UITableViewRowAnimationNone];
                     //添加标记到地图上
                     [self addPointsToMap:mPollutionNearbyList];
                 }
                 failure:^(NSError *err) {
                     NSLog(@"fail to get pollution in radius, error = %@", err);
                 }];
}

#pragma mark - map
-(void)createMap{
    if (!mMapView) {
        mMapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.width)];
        mMapView.delegate = self;
        
        [mMapView setMapType:BMKMapTypeSatellite];
        [mMapView setZoomEnabled:NO];
        [mMapView setZoomEnabledWithTap:NO];
        [mMapView setScrollEnabled:NO];
        [mMapView setZoomLevel:14.0f];
        
        CLLocationCoordinate2D tmpCoor;
        tmpCoor.longitude = [self.lng floatValue];
        tmpCoor.latitude = [self.lat floatValue];
        [mMapView setCenterCoordinate:tmpCoor];
        
        [self addOverlaysToMap];
        [self addCenterPointToMap];
    }
}
-(void)addOverlaysToMap{
    if (!mCircle) {
        CLLocationCoordinate2D tmpCoor;
        tmpCoor.latitude = [self.lat doubleValue];
        tmpCoor.longitude = [self.lng doubleValue];
        mCircle = [BMKCircle circleWithCenterCoordinate:tmpCoor radius:5000];
    }
    [mMapView addOverlay:mCircle];
}
-(void)addCenterPointToMap{
    if (!mCenterPoint) {
        mCenterPoint = [[BMKPointAnnotation alloc]init];
        CLLocationCoordinate2D tmpCoor;
        tmpCoor.latitude = [self.lat doubleValue];
        tmpCoor.longitude = [self.lng doubleValue];
        mCenterPoint.coordinate = tmpCoor;
    }
    [mMapView addAnnotation:mCenterPoint];
}

-(void)addPointsToMap:(NSMutableArray *)arr{
    for (int i = 0; i < arr.count; i++) {
        BMKPointAnnotation *tmpA = [[BMKPointAnnotation alloc]init];
        CLLocationCoordinate2D tmpC;
        tmpC.latitude = [arr[i][@"lat"] doubleValue];
        tmpC.longitude = [arr[i][@"lng"] doubleValue];
        tmpA.coordinate = tmpC;
        [mMapView addAnnotation:tmpA];
    }
}
-(BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay{
    if (overlay == mCircle) {
        BMKCircleView* circleView = [[BMKCircleView alloc] initWithOverlay:overlay];
        circleView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0];
        circleView.strokeColor = LIGHTGRAY_COLOR;
        circleView.lineDash = YES;
        circleView.lineWidth = 2.0;
        return circleView;
    }
    return nil;
}
-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{
    if (annotation == mCenterPoint) {
        NSString *centerPointIdentifier = @"centerPoint";
        BMKPinAnnotationView *centerPinView = (BMKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:centerPointIdentifier];
        if (centerPinView == nil) {
            centerPinView = [[BMKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:centerPointIdentifier];
            centerPinView.pinColor = BMKPinAnnotationColorPurple;
            //想改图片请在此进行
        }
        return centerPinView;
    }
    else{
        NSString *otherPointIdentifier = @"otherPoint";
        BMKPinAnnotationView *otherPinView = (BMKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:otherPointIdentifier];
        if (otherPinView == nil) {
            otherPinView = [[BMKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:nil];
            otherPinView.pinColor = BMKPinAnnotationColorRed;
            //想改图片请在此
        }
        return otherPinView;
    }
    return nil;
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 1;
    }
    else{
        return mPollutionNearbyList.count;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 0.001f;
    }
    else{
        return 44.0f;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return self.view.frame.size.width;
    }
    else{
        return 44;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 0.001)];
        return view;
    }
    else{
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44.0f)];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 180, 44)];
        [label setText:@"附近的污染源"];
        UILabel *badge = [[UILabel alloc]initWithFrame:CGRectMake(view.frame.size.width - 64 - 15, 8, 64, 28)];
        [badge setTextAlignment:NSTextAlignmentCenter];
        [badge setBackgroundColor:BLUE_COLOR];
        [badge setTextColor:[UIColor whiteColor]];
        [badge.layer setMasksToBounds:YES];
        [badge.layer setCornerRadius:14];
        [badge setText:[NSString stringWithFormat:@"%lu",(unsigned long)mPollutionNearbyList.count]];
        [view addSubview:label];
        [view addSubview:badge];
        return view;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"PollutionNearbyCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    else{
        while (cell.contentView.subviews.lastObject) {
            [cell.contentView.subviews.lastObject removeFromSuperview];
        }
    }
    
    if (indexPath.section == 0) {
        [self createMap];
        [cell.contentView addSubview:mMapView];
    }
    else{
        [cell.textLabel setText:mPollutionNearbyList[indexPath.row][@"name"]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        [self performSegueWithIdentifier:@"PollutionDetailSegue" sender:mPollutionNearbyList[indexPath.row]];
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"PollutionDetailSegue"]) {
        PollutionDetailViewController *targetVC = [segue destinationViewController];
        targetVC.pid = sender[@"id"];
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if([NSStringFromClass([touch.view class]) isEqualToString:@"TapDetectingView"]){
        [self.tableView removeGestureRecognizer:rec];
    }
    else{
        [self.tableView addGestureRecognizer:rec];
    }
    return YES;
}

@end
