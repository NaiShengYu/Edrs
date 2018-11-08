//
//  DisasterChemicalViewController.m
//  edrs
//
//  Created by 余文君, July on 15/8/20.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "DisasterChemicalViewController.h"

@interface DisasterChemicalViewController ()

@end

@implementation DisasterChemicalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //获取数据
   [Utility configuerNavigationBackItem:self];
    mNearbyChemicalList = [[NSMutableArray alloc]init];
  
    
    //注册定位
    mLocationService = [[BMKLocationService alloc]init];
    mLocationService.delegate = self;
    [mLocationService startUserLocationService];
    
    //模拟
//    mDisasterChemicalList = [[NSMutableArray alloc]init];
//    [mDisasterChemicalList addObject:@{@"id":@"0",@"name":@"苯"}];
//    [mDisasterChemicalList addObject:@{@"id":@"1",@"name":@"氯"}];
//    mNearbyChemicalList = [[NSMutableArray alloc]init];
//    [mNearbyChemicalList addObject:@{@"id":@"1",@"name":@"氯化钾"}];
//    [mNearbyChemicalList addObject:@{@"id":@"2",@"name":@"苯"}];
//    [mNearbyChemicalList addObject:@{@"id":@"3",@"name":@"xx"}];
//    [mNearbyChemicalList addObject:@{@"id":@"4",@"name":@"xx"}];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
}

-(void)viewWillAppear:(BOOL)animated{
    if(mLocationTimer == nil){
          mLocationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getDisasterChemicalData) userInfo:nil repeats:YES];
    }
}
-(void)viewDidDisappear:(BOOL)animated{
    mLocationService.delegate = nil;
    [mLocationTimer invalidate];
    mLocationTimer = nil;
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getDisasterChemicalData{
    //获取当前事故的化学品列表（实际从上个页面传入即可）
//    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@", EDRSHTTP, EDRSHTTP_GETDISASTER_DETAIL_CHEMICALS] params:@{@"disasterid":self.disasterId} success:^(id responseObj) {
//        NSLog(@"get disaster chemicals successfully, response = %@", responseObj);
//        
//        NSIndexSet *nd = [[NSIndexSet alloc]initWithIndex:0];
//        [self.disasterChemicalTableView reloadSections:nd withRowAnimation:UITableViewRowAnimationAutomatic];
//        
//    } failure:^(NSError *err) {
//        NSLog(@"fail to get disaster chemicals, error = %@", err);
//    }];
//    mDisasterChemicalList = self.chemicalList;
    //[self.chemicalList removeAllObjects];   //测试
    
    NSIndexSet *nd = [[NSIndexSet alloc]initWithIndex:0];
    [self.disasterChemicalTableView reloadSections:nd withRowAnimation:UITableViewRowAnimationAutomatic];
    
    //location is defined & chemical is not defined
    if(self.chemicalList.count <= 0){
        NSLog(@"mlocation lat = %@, lng = %@",[NSString stringWithFormat:@"%f",mLocationCoor.latitude], [NSString stringWithFormat:@"%f",mLocationCoor.longitude]);
        mShowRadiusInfo = mLocationCoor.latitude != 0.0f && mLocationCoor.longitude != 0.0f;
        
        NSArray *items = [self.disasterLocation componentsSeparatedByString:@","];
        if(items.count ==2){
            NSString *tmplng = items[0];//[NSString stringWithFormat:@"%f",mLocationCoor.longitude]
            NSString *tmplat = items[1];//[NSString stringWithFormat:@"%f",mLocationCoor.latitude]
            
            if (mShowRadiusInfo) {
                //附近污染源的化学品
                [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@", EDRSHTTP, EDRSHTTP_GETDISASTER_CHEMICALS_RADIUS]
                              params:@{@"stationid":[CustomAccount sharedCustomAccount].user.stationId, @"centerlng":tmplng, @"centerlat":tmplat, @"radius":@"5"}
                             success:^(id responseObj) {
                                 NSLog(@"get chemicals radius , response = %@", responseObj);
                                 
                                 //获取数据，加载section内容
                                 mNearbyChemicalList = responseObj;
                                 [self.disasterChemicalTableView reloadData];
                                 [mLocationTimer invalidate];
                             }
                             failure:^(NSError *err) {
                                 NSLog(@"fail to chemicals in radius , error = %@", err);
                             }];
            }
        }
     
    }
    else{
        [mLocationTimer invalidate];
    }
    
}

#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(_chemicalList.count == 0 ){
        return 2 ;
    }else{
        return 3;
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        if(_chemicalList.count > 0){
            return _chemicalList.count;
        }else if (_chemicalList.count == 0 && mNearbyChemicalList.count > 0){
            return mNearbyChemicalList.count;
        }else{
            return 1;
        }
    }
    else if (section == 1){
        if(_chemicalList.count > 0){
            if(mNearbyChemicalList.count>0){
                return mNearbyChemicalList.count;
            }else{
                return 1;
            }
        }else{
            return 1;
        }
    }else{
        return 1;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.0f;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSInteger index ;
   
    if(_chemicalList.count > 0){
        index = 1 ;
    }else if (_chemicalList.count == 0 ){
        index = 0;
    }
    
    if (section == index) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 56.0f)];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 200, 44.0f)];
        [label setText:@"附近污染源的化学品"];
        [view addSubview:label];
        return view;
    }else{
        return nil;
    }
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"DisasterChemicalTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (_chemicalList.count> 0 && [indexPath section]==0) {
        [cell.textLabel setText:_chemicalList[indexPath.row][@"chemical_chinesename"]];
        if ([_chemicalList[indexPath.row][@"chemical_id"] isEqualToString:EMPTY_GUID]) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        else{
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
    }
    else if((_chemicalList.count== 0 && [indexPath section]==0)||(_chemicalList.count> 0 && [indexPath section]==1)){
        if(mNearbyChemicalList.count > 0){
            [cell.textLabel setText:mNearbyChemicalList[indexPath.row][@"name"]];
            if ([mNearbyChemicalList[indexPath.row][@"chemid"] isEqualToString:EMPTY_GUID]) {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
            else{
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
        }
        else{
            [cell.textLabel setText:@"无"];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    else{
        [cell.textLabel setText:@"查看附近的污染源"];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (_chemicalList.count> 0 && [indexPath section]==0) {
        if (![_chemicalList[indexPath.row][@"chemical_id"] isEqualToString:EMPTY_GUID]) {
            [self performSegueWithIdentifier:@"ChemicalDetailSegue" sender:_chemicalList[indexPath.row][@"chemical_id"]];
        }
    }
    else if((_chemicalList.count== 0 && [indexPath section]==0)||(_chemicalList.count> 0 && [indexPath section]==1)){
        if (mNearbyChemicalList.count > 0) {
            if (![mNearbyChemicalList[indexPath.row][@"chemid"] isEqualToString:EMPTY_GUID]) {
                [self performSegueWithIdentifier:@"ChemicalDetailSegue" sender:mNearbyChemicalList[indexPath.row][@"chemid"]];
            }
        }
        else{
            return;
        }
    }
    else{
        NSArray *Items = [self.disasterLocation componentsSeparatedByString:@","];
         NSString *tmplng = @"";
        NSString *tmplat = @"";
        if(Items.count ==2){
            tmplng = Items[0];
            tmplat = Items[1];
        }
        
        [self performSegueWithIdentifier:@"PollutionNearbySegue" sender:@{@"lat":tmplat, @"lng":tmplng}];
//        [cell.textLabel setText:@"查看附近的污染源"];
//        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
}

#pragma mark - view segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ChemicalDetailSegue"]) {
        ChemicalDetailViewController *targetVC = segue.destinationViewController;
        targetVC.cid = sender;
    }
    else if([segue.identifier isEqualToString:@"PollutionNearbySegue"]){
        PollutionNearbyTableViewController *targetVC = segue.destinationViewController;
        targetVC.lat = sender[@"lat"];
        targetVC.lng = sender[@"lng"];
    }
}

#pragma mark - location service
-(void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    mLocationCoor.latitude = userLocation.location.coordinate.latitude;
    mLocationCoor.longitude = userLocation.location.coordinate.longitude;
}

@end
