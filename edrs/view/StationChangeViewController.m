//
//  StationChangeViewController.m
//  edrs
//
//  Created by 余文君, July on 15/8/13.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "StationChangeViewController.h"

@interface StationChangeViewController ()

@end

@implementation StationChangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Utility configuerNavigationBackItem:self];
    //获取本地站点信息
    mStationsArray = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:STATIONARRAY]];
    
    //样式调整
    [self.navigationController setNavigationBarHidden:NO];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    NSLog(@"dealloc");
}
#pragma mark - tableview delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [mStationsArray count]+1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 56.0f;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 48)];
    [headerview setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(15, 8, 180, 48)];
    [title setText:@"监测站"];
    [headerview addSubview:title];
    return headerview;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerview = [[UIView alloc]initWithFrame:CGRectZero];
    return footerview;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"stationsTableViewCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    if (indexPath.row == [mStationsArray count]) {
        [cell.textLabel setText:@"新增监测站"];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    else{
        [cell.textLabel setText:mStationsArray[indexPath.row][@"stationName"]];
        [cell.detailTextLabel setText:mStationsArray[indexPath.row][@"stationUrl"]];
        
        //如果当前是选择项，则加上accessorycheckmark
        if ([mStationsArray[indexPath.row][@"stationSelected"] isEqualToString:@"1"]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        else{
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == [mStationsArray count]) {
        //添加检测站
        [self performSegueWithIdentifier:@"StationNewSegue" sender:self];
    }
    else{
        //选择检测站
        
        //数据更新
        for (int i = 0; i < [mStationsArray count]; i++) {
            if ([mStationsArray[i][@"stationSelected"] isEqualToString:@"1"]) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:mStationsArray[i]];
                [dict setObject:@"0" forKey:@"stationSelected"];
                [mStationsArray replaceObjectAtIndex:i withObject:dict];
                break;
            }
        }
        
        NSMutableDictionary *item = [[NSMutableDictionary alloc]initWithDictionary:mStationsArray[indexPath.row]];
        [item setObject:@"1" forKey:@"stationSelected"];
        [mStationsArray replaceObjectAtIndex:indexPath.row withObject:item];
        
        NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
        [userdefaults setObject:mStationsArray[indexPath.row][@"stationName"] forKey:STATION];
        [userdefaults setObject:mStationsArray[indexPath.row][@"stationId"] forKey:STATIONID];
        [userdefaults setObject:mStationsArray[indexPath.row][@"stationUrl"] forKey:STATIONURL];
        [userdefaults setObject:mStationsArray forKey:STATIONARRAY];
        [userdefaults synchronize];
        
        [tableView reloadData];
        
        //数据回传
        [self.delegate setStationChange:mStationsArray[indexPath.row]];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}

#pragma mark - 页面跳转
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"StationNewSegue"]) {
        StationNewViewController *targetVC = segue.destinationViewController;
        targetVC.delegate = self;
    }
}
-(void)setStationNew:(NSMutableDictionary *)station{
    //获取到新的station 添加到本地
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *tmpArr = [[NSMutableArray alloc]initWithArray:[userdefaults objectForKey:STATIONARRAY]];
    for (int i = 0; i < tmpArr.count; i++) {
        if ([tmpArr[i][@"stationId"] isEqualToString:station[@"stationId"]]) {
            if ([tmpArr[i][@"stationUrl"] isEqualToString:station[@"stationUrl"]]){
                [CustomUtil showMBProgressHUD:@"此监测站已存在" view:self.view animated:YES];
                return;
            }
            else{
                [tmpArr removeObjectAtIndex:i];
            }
        }
    }
    
    [tmpArr addObject:station];
    [userdefaults setObject:tmpArr forKey:STATIONARRAY];
    [userdefaults synchronize];
    
    [mStationsArray addObject:station];
    [self.stationsTableView reloadData];
}

@end
