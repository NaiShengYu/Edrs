//
//  DisasterListViewController.m
//  edrs
//
//  Created by 余文君, July on 15/8/14.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "DisasterListViewController.h"
#import "AppDelegate.h"
@interface DisasterListViewController ()

@end

@implementation DisasterListViewController

-(UITableView *)disasterListTableView{
    if(_disasterListTableView == nil){
        _disasterListTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
        _disasterListTableView.delegate = self ;
        _disasterListTableView.dataSource = self;
    }
    
    return _disasterListTableView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [Utility configuerNavigationBackItem:self];
    mDisasterCurrentList = [[NSMutableArray alloc]init];
    mDisasterAllList = [[NSMutableArray alloc]init];
    [self.view addSubview:self.disasterListTableView];
    [self getDisasterListData];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
   
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(getDisasterListData)];
    [header.lastUpdatedTimeLabel setHidden:YES];
    self.disasterListTableView.header = header;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    NSLog(@"dealloc");
}



-(void)getDisasterListData{
    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@", EDRSHTTP, EDRSHTTP_GETDISASTER_ALL] params:@{@"stationid":[CustomAccount sharedCustomAccount].user.stationId} success:^(id responseObj) {
        NSLog(@"get disaster all list successfully, response = %@", responseObj);
        //获取历史事故
        mDisasterAllList = responseObj;
        NSMutableArray *tmparr = [[NSMutableArray alloc]init];
        for (int i = 0; i < mDisasterAllList.count; i++) {
            [tmparr addObject:mDisasterAllList[i][@"id"]];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:tmparr forKey:[NSString stringWithFormat:@"%@%@",EDRS_UD_DISASTERS,[CustomAccount sharedCustomAccount].user.userId]];
        
        [self.disasterListTableView reloadData];
        [self.disasterListTableView.header endRefreshing];
    } failure:^(NSError *err) {
        NSLog(@"fail to get disaster all list , error = %@", err);
    }];
    //获取当前正在发生的事故
    
    
    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@", EDRSHTTP, EDRSHTTP_GETDISASTER_CURRENT] params:@{@"stationid":[CustomAccount sharedCustomAccount].user.stationId} success:^(id responseObj) {
        mDisasterCurrentList = responseObj;
        
        NSMutableArray *tmparr = [[NSMutableArray alloc]init];
        for (int i = 0; i < mDisasterCurrentList.count; i++) {
            [tmparr addObject:mDisasterCurrentList[i][@"id"]];
        }
        [[NSUserDefaults standardUserDefaults] setObject:tmparr forKey:[NSString stringWithFormat:@"%@%@",EDRS_UD_CURRENTDISASTERS,[CustomAccount sharedCustomAccount].user.userId]];
        
        [self.disasterListTableView reloadData];
        [self.disasterListTableView.header endRefreshing];
    } failure:^(NSError *err) {
        NSLog(@"fail to get disaster current list , error = %@", err);
    }];
}

#pragma mark - table view
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [mDisasterAllList count]+[mDisasterCurrentList count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row >= [mDisasterCurrentList count]) {
        return 56.0f;
    }
    else{
        return 56.0f;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier_1 = @"DisasterListTableViewCellIdentifier1";
    NSString *cellIdentifier_2 = @"DisasterListTableViewCellIdentifier2";
    
//    if (indexPath.row < [mDisasterCurrentList count]) {
//        UITableViewCell *cell_1 = [tableView dequeueReusableCellWithIdentifier:cellIdentifier_1];
//        if (cell_1 == nil) {
//            cell_1 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier_1];
//        }
//        
//        [cell_1.textLabel setText:[CustomUtil getFormatedDateString:mDisasterCurrentList[indexPath.row][@"starttime"]]];
//        [cell_1.textLabel setTextColor:BLUE_COLOR];
//        
//        [cell_1 setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
//        [cell_1 setSelectionStyle:UITableViewCellSelectionStyleNone];
//        return cell_1;
//    }
//    else{
//        UITableViewCell *cell_2 = [tableView dequeueReusableCellWithIdentifier:cellIdentifier_2];
//        if (cell_2 == nil) {
//            cell_2  = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier_2];
//        }
//        
//        [cell_2.textLabel setText:mDisasterAllList[indexPath.row-mDisasterCurrentList.count][@"name"]];
//        [cell_2.detailTextLabel setText:[CustomUtil getFormatedDateString:mDisasterAllList[indexPath.row-mDisasterCurrentList.count][@"starttime"]]];
//        
//        [cell_2 setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
//        [cell_2 setSelectionStyle:UITableViewCellSelectionStyleNone];
//        return cell_2;
//    }
    
    
    UITableViewCell *cell_2 = [tableView dequeueReusableCellWithIdentifier:cellIdentifier_2];
    if (cell_2 == nil) {
        cell_2  = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier_2];
    }
    if (indexPath.row < [mDisasterCurrentList count]) {
        [cell_2.detailTextLabel setText:[CustomUtil getFormatedDateString:mDisasterCurrentList[indexPath.row][@"starttime"]]];
        [cell_2.textLabel setText:mDisasterCurrentList[indexPath.row][@"name"]];
        [cell_2.textLabel setTextColor:BLUE_COLOR];
        [cell_2.detailTextLabel setTextColor:BLUE_COLOR];

    }
    else{

        [cell_2.textLabel setText:mDisasterAllList[indexPath.row-mDisasterCurrentList.count][@"name"]];
        [cell_2.detailTextLabel setText:[CustomUtil getFormatedDateString:mDisasterAllList[indexPath.row-mDisasterCurrentList.count][@"starttime"]]];
        [cell_2.textLabel setTextColor:[UIColor blackColor]];
        [cell_2.detailTextLabel setTextColor:[UIColor blackColor]];
    }
    [cell_2 setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell_2 setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell_2;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *did;
    NSString *time;
    NSString *name;
    if (indexPath.row < [mDisasterCurrentList count]) {
        did = mDisasterCurrentList[indexPath.row][@"id"];
        time = mDisasterCurrentList[indexPath.row][@"starttime"];
        name = mDisasterCurrentList[indexPath.row][@"name"];
    }
    else{
        did = mDisasterAllList[indexPath.row - mDisasterCurrentList.count][@"id"];
        time = mDisasterAllList[indexPath.row - mDisasterCurrentList.count][@"starttime"];
        name = mDisasterAllList[indexPath.row - mDisasterCurrentList.count][@"name"];

    }
    
    [self performSegueWithIdentifier:@"DisasterDetailSegue" sender:@{@"id":did,@"time":time,@"name":name}];
}


#pragma mark - segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"DisasterDetailSegue"]) {
        DisasterDetailViewController *targetVC = segue.destinationViewController;
        
//        更改详情页的backbtn title
//        UIBarButtonItem *backBarButtonItem= [[UIBarButtonItem alloc]init];
//        [backBarButtonItem setTitle:@"返回"];
//        self.navigationItem.backBarButtonItem = backBarButtonItem;
        
        targetVC.did = sender[@"id"];
        targetVC.starttime = sender[@"time"];
    }
    else if([segue.identifier isEqualToString:@"DisasterAddSegue"]){
        DisasterAddViewController *targetVC = segue.destinationViewController;
        targetVC.delegate = self;
    }
}

#pragma mark - 事故新增delegate
-(void)addNewDisasterSuccess{
    //更新列表
    NSLog(@"??");
    [self getDisasterListData];
}

@end
