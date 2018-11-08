//
//  PollutionDetailViewController.m
//  edrs
//
//  Created by 余文君, July on 15/8/14.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "PollutionDetailViewController.h"

@interface PollutionDetailViewController ()

@end

@implementation PollutionDetailViewController
-(UITableView *)pollutionDetailTableView{
    if(_pollutionDetailTableView ==nil){
        _pollutionDetailTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
        _pollutionDetailTableView.delegate = self;
        _pollutionDetailTableView.dataSource = self;
    }
    
    return _pollutionDetailTableView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.pollutionDetailTableView];
    [Utility configuerNavigationBackItem:self];
    //获取数据
    [self getPollutionDetailData];
    
//    [self setAutomaticallyAdjustsScrollViewInsets:NO];
}
- (void)dealloc{
    NSLog(@"dealloc");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getPollutionDetailData{
    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@", EDRSHTTP, EDRSHTTP_GETPOLLUTION_DETAIL]
                 params:@{@"id":self.pid}
                success:^(id responseObj) {
                    NSLog(@"get pollution detail successfully, response = %@", responseObj);
                    
                    mPollutionDetail = responseObj;
                    [self pollutionToArrays];
                    [self.pollutionDetailTableView reloadData];
                    
                }
                failure:^(NSError *err) {
                    NSLog(@"fail to get pollution detail , error = %@", err);
                }];
}

-(void)pollutionToArrays{
    //模拟
    mBaseinfo = [[NSMutableArray alloc]init];
    NSString *coord = [NSString stringWithFormat:@"%@ , %@",mPollutionDetail[@"lat"],mPollutionDetail[@"lng"]];
    [mBaseinfo addObject:@{@"cellLabel":@"名称", @"cellContent":mPollutionDetail[@"name"]}];
    [mBaseinfo addObject:@{@"cellLabel":@"地区", @"cellContent":mPollutionDetail[@"district"]}];
    [mBaseinfo addObject:@{@"cellLabel":@"坐标", @"cellContent":coord}];
    [mBaseinfo addObject:@{@"cellLabel":@"地址", @"cellContent":mPollutionDetail[@"address"]}];
    [mBaseinfo addObject:@{@"cellLabel":@"工业", @"cellContent":mPollutionDetail[@"industry"]}];
    [mBaseinfo addObject:@{@"cellLabel":@"工业代号", @"cellContent":mPollutionDetail[@"industry_code"]}];
    [mBaseinfo addObject:@{@"cellLabel":@"网址", @"cellContent":mPollutionDetail[@"url"]}];
    [mBaseinfo addObject:@{@"cellLabel":@"联系人", @"cellContent":mPollutionDetail[@"contact"]}];
    [mBaseinfo addObject:@{@"cellLabel":@"电话", @"cellContent":mPollutionDetail[@"phone"]}];
    [mBaseinfo addObject:@{@"cellLabel":@"法人", @"cellContent":mPollutionDetail[@"corp_name"]}];
    [mBaseinfo addObject:@{@"cellLabel":@"法人代号", @"cellContent":mPollutionDetail[@"corp_code"]}];
    [mBaseinfo addObject:@{@"cellLabel":@"人数", @"cellContent":mPollutionDetail[@"boundary"]}];
    
    mRelative = [[NSMutableArray alloc]init];
    for (int i = 0 ; i < [mPollutionDetail[@"chemicals"] count]; i++) {
        [mRelative addObject:mPollutionDetail[@"chemicals"][i]];
    }
}

#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if([mRelative count] == 0){
        return 1;
    }else{
        return 2;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0 &&  [mRelative count] !=0) {
        return [mRelative count];
    }else{
         return [mBaseinfo count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if( [mRelative count] != 0 && section==0){
        return @"有关的化学品";
    }else{
        return @"企业信息";
    }
}
//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 1)];
//    return view;
//}
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 200, 44.0f)];
//    [label setTextColor:BLUE_COLOR];
//    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
//    [view addSubview:label];
//    if (section == 0) {
//        [label setText:@"有关的化学品"];
//        return view;
//    }
//    else{
//        return view;
//    }
//}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"PollutionDetailCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    else{
        if ([[cell.contentView subviews] count]==2) {
            [[[cell.contentView subviews] lastObject] removeFromSuperview];
        }
    }
    
    if (indexPath.section == 0 && mRelative.count!=0) {
        [cell.textLabel setText:mRelative[indexPath.row][@"name"]];
        if ([mRelative[indexPath.row][@"chemid"] isEqualToString:EMPTY_GUID]) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        else{
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
    }
    else {
        [cell.textLabel setText:mBaseinfo[indexPath.row][@"cellLabel"]];
        
        UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 0, self.view.frame.size.width - 100 - 44, 44)];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:mBaseinfo[indexPath.row][@"cellContent"] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f],NSForegroundColorAttributeName:[UIColor grayColor]}];
        
        CGSize size = [attrStr boundingRectWithSize:contentLabel.bounds.size options:NSStringDrawingUsesFontLeading context:nil].size;
        
        if (size.width >= contentLabel.frame.size.width) {
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        else{
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
        [contentLabel setAttributedText:attrStr];
        [cell.contentView addSubview:contentLabel];
        
    }
  

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        if (indexPath.section == 0 &&mRelative.count !=0 ) {
            //化学品
            if (![mRelative[indexPath.row][@"chemid"] isEqualToString:EMPTY_GUID]) {
                [self performSegueWithIdentifier:@"ChemicalDetailSegue" sender:mRelative[indexPath.row][@"chemid"]];
            }
        }
        else{
            //详情
            NSDictionary *item = @{@"name":mBaseinfo[0][@"cellContent"], @"label":mBaseinfo[indexPath.row][@"cellLabel"], @"content":mBaseinfo[indexPath.row][@"cellContent"]};
            [self performSegueWithIdentifier:@"DetailSegue" sender:item];
        }
    }
}

#pragma mark - segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"DetailSegue"]) {
        DetailViewController *targetVC = segue.destinationViewController;
        targetVC.dName = sender[@"name"];
        targetVC.dLabel = sender[@"label"];
        targetVC.dContent = sender[@"content"];
    }
    else if([segue.identifier isEqualToString:@"ChemicalDetailSegue"]){
        ChemicalDetailViewController *targetVC = segue.destinationViewController;
        targetVC.cid = sender;
    }
    else{
        
    }
}

@end
