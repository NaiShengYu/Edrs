//
//  MainSearchResultViewController.m
//  edrs
//
//  Created by 余文君, July on 15/8/14.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "MainSearchResultViewController.h"

@interface MainSearchResultViewController ()

@end

@implementation MainSearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Utility configuerNavigationBackItem:self];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    //获取数据
    [self getSearchResultData];
}
-(void)dealloc{
    NSLog(@"dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getSearchResultData{
    
   // NSLog(@"%@", self.keyword);
    NSString *tmpurl = [NSString stringWithFormat:@"%@%@",EDRSHTTP, EDRSHTTP_SEARCH];
    
    [CustomHttp httpGet:tmpurl params:@{@"key":self.keyword} success:^(id responseObj) {
        NSLog(@"get search result successfully , response = %@", responseObj);
        
        //获取数据后处理
        mResultArray = [[NSMutableArray alloc]init];
        mResultSectionTitleArray = [[NSMutableArray alloc]init];
        mResultSegueIdentifierArray = [[NSMutableArray alloc]init];
        
        if ([responseObj[@"Chemical"][@"Count"] intValue] > 0) {
            [mResultArray addObject:responseObj[@"Chemical"]];
            [mResultSectionTitleArray addObject:@"化学品"];
            [mResultSegueIdentifierArray addObject:@"ChemicalDetailSegue"];
        }
        if ([responseObj[@"Pollution"][@"Count"] intValue] > 0) {
            [mResultArray addObject:responseObj[@"Pollution"]];
            [mResultSectionTitleArray addObject:@"污染源"];
            [mResultSegueIdentifierArray addObject:@"PollutionDetailSegue"];
        }
        if ([responseObj[@"Equipment"][@"Count"] intValue] > 0) {
            [mResultArray addObject:responseObj[@"Equipment"]];
            [mResultSectionTitleArray addObject:@"设备"];
            [mResultSegueIdentifierArray addObject:@"EquipmentDetailSegue"];
        }
        if ([responseObj[@"Disaster"][@"Count"] intValue] > 0) {
            [mResultArray addObject:responseObj[@"Disaster"]];
            [mResultSectionTitleArray addObject:@"突发事故"];
            [mResultSegueIdentifierArray addObject:@"DisasterDetailSegue"];
        }
        
        [self.searchResultTableView reloadData];
        
    } failure:^(NSError *err) {
        NSLog(@"fail to get search result, error = %@", err);
    }];
}



#pragma mark - search result table delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [mResultArray count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [mResultArray[section][@"Count"] intValue];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([mResultArray[section][@"Count"] intValue] > 0) {
        return 66.0f;
    }
    else{
        return 0.f;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 66.0f)];
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(15.f, 22.f, 200.f, 44.0f)];
    UILabel *badge = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 72.0f, 30.0f, 64.0f, 28.0f)];
    [badge setBackgroundColor:BLUE_COLOR];
    [badge setTextColor:[UIColor whiteColor]];
    [badge setTextAlignment:NSTextAlignmentCenter];
    [badge.layer setMasksToBounds:YES];
    [badge.layer setCornerRadius:14.0f];
    [view addSubview:title];
    [view addSubview:badge];
    
    [title setText:mResultSectionTitleArray[section]];
    [badge setText:[NSString stringWithFormat:@"%d",[mResultArray[section][@"Count"] intValue]]];
    
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"searchResultTableViewCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell.textLabel setText:mResultArray[indexPath.section][@"Items"][indexPath.row][@"name"]];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(indexPath.section == 0){
//        //化学品
//        [self performSegueWithIdentifier:@"ChemicalDetailSegue" sender:self];
//    }
//    else if(indexPath.section == 1){
//        //污染源
//        [self performSegueWithIdentifier:@"PollutionDetailSegue" sender:self];
//    }
//    else if(indexPath.section == 2){
//        //设备
//        [self performSegueWithIdentifier:@"EquipmentDetailSegue" sender:self];
//    }
//    else if(indexPath.section == 3){
//        //突发事件
//        [self performSegueWithIdentifier:@"DisasterDetailSegue" sender:self];
//    }
//    else{
//        
//    }
    
    NSMutableDictionary *dict = mResultArray[indexPath.section][@"Items"][indexPath.row];
    [self performSegueWithIdentifier:mResultSegueIdentifierArray[indexPath.section] sender:dict];
}

#pragma mark - 跳转到各个详情页
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ChemicalDetailSegue"]) {
        //化学详情页
        ChemicalDetailViewController *targetVC = segue.destinationViewController;
        targetVC.cid = sender[@"id"];
    }
    else if([segue.identifier isEqualToString:@"PollutionDetailSegue"]){
        //污染源详情页
        PollutionDetailViewController *targetVC = segue.destinationViewController;
        targetVC.pid = sender[@"id"];
    }
    else if([segue.identifier isEqualToString:@"EquipmentDetailSegue"]){
        //设备详情
        EquipmentDetailViewController *targetVC = segue.destinationViewController;
        targetVC.eid = sender[@"id"];
    }
    else if([segue.identifier isEqualToString:@"DisasterDetailSegue"]){
        //突发事件
        DisasterDetailViewController *targetVC = segue.destinationViewController;
        targetVC.did = sender[@"id"];
        targetVC.starttime = @"";
    }
}

@end
