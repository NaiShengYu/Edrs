//
//  PollutionListViewController.m
//  edrs
//
//  Created by 余文君, July on 15/8/14.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "PollutionListViewController.h"

@interface PollutionListViewController ()

@end

@implementation PollutionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //模拟
    //mPollutionList = [[NSMutableArray alloc]initWithArray:[CustomHttp getDataFromFile:@"chemicals"]];
    //获取数据
    mPollutionList = [[NSMutableArray alloc]init];
    [self getPollutionListData];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getPollutionListData{
    [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@",EDRSHTTP, EDRSHTTP_GETPOLLUTION_ALL]
                  params:@{@"latfrom":@"0",@"latto":@"0", @"longfrom":@"0", @"longto":@"0", @"page":@"0", @"stationid":[CustomAccount sharedCustomAccount].user.stationId}
                 success:^(id responseObj) {
                     NSLog(@"get pollution list successfully , response = %@", responseObj);
                     mPollutionList = responseObj;
                     [self.pollutionListTableView reloadData];
                  }
                 failure:^(NSError *err) {
                      NSLog(@"fail to get pollution list, error = %@", err);
                  }];
}

#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [mPollutionList count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.001f;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.001f)];
    return view;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"PollutionListTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell==nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell.textLabel setText:mPollutionList[indexPath.row][@"name"]];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *pid = mPollutionList[indexPath.row][@"id"];
    [self performSegueWithIdentifier:@"PollutionDetailSegue" sender:pid];
}

#pragma mark - search bar
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString *keyword = [self.pollutionListSearchBar text];
    NSLog(@"搜索%@",keyword);
}

#pragma mark - view segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"PollutionDetailSegue"]) {
        PollutionDetailViewController *targetVC = segue.destinationViewController;
        targetVC.pid = sender;
    }
}


@end
