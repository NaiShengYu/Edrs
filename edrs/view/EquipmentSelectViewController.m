//
//  EquipmentSelectViewController.m
//  edrs
//
//  Created by 余文君, July on 15/8/21.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "EquipmentSelectViewController.h"

@interface EquipmentSelectViewController ()

@end

@implementation EquipmentSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Utility configuerNavigationBackItem:self];
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(submitButton)];
    [submitButton setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = submitButton;
    
    //获取当前EquipmentList，暂无扫描设备
    mEquipmentList = [[NSMutableArray alloc]init];
//    [self getEquipmentListLength];
    [self getEquipmentListData];
    
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)submitButton{
    if (mSelectedIndex != -1){
        [self.delegate setSelectedEquipment:mEquipmentList[mSelectedIndex]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getEquipmentListLength{
    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@",EDRSHTTP, EDRSHTTP_GETEQUIPMENT_LENGTH] params:@{} success:^(id responseObj) {
        NSLog(@"get equipment list length, response = %@", responseObj);
        mLength = [responseObj[@"length"] intValue];
    } failure:^(NSError *err) {
        NSLog(@"fail to get equipment list length");
    }];
    
}
-(void)getEquipmentListData{
    [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@", EDRSHTTP, EDRSHTTP_GETEQUIPMENT_PAGE] params:@{@"pageIndex":[NSString stringWithFormat:@"%d",0]} success:^(id responseObj) {
        NSLog(@"get equipment list success, response = %@", responseObj);
        
        mEquipmentList = [responseObj valueForKey:@"Items"];
        mSelectedIndex = -1;
        for (int i = 0; i< [mEquipmentList count]; i++) {
            if ([mEquipmentList[i][@"id"] isEqualToString:self.selcetedEquipment[@"id"]]) {
                mSelectedIndex = i;
                break;
            }
        }
        [self.equipmentSelectTableView reloadData];
        
    } failure:^(NSError *err) {
        NSLog(@"fail to get equipment list , error = %@", err);
    }];
}

#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        //暂时无扫描设备
        return 0;
    }
    else{
        return mEquipmentList.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        //暂时无扫描设备
        return 1.0f;
    }
    else{
        return 56.0f;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 56.0f)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 12, 200, 44.0f)];
    if (section == 0) {
        //暂时无扫描设备
        [label setFrame:CGRectMake(0, 0, 0, 0)];
        //[label setText:@"扫描设备"];
    }
    else{
        [label setText:@"使用设备"];
    }
    [view addSubview:label];
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        //暂时无扫描设备
        //return 200.0f;
        return 1.0f;
    }
    else{
        return 56.0f;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"EquipmentSelectionCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        [cell.textLabel setText:@"此处为条码扫描框。。。"];
    }
    else{
        //此处为设备可选列表
        [cell.textLabel setText:mEquipmentList[indexPath.row][@"name"]];
        [cell.detailTextLabel setText:mEquipmentList[indexPath.row][@"code"]];
        
        if (mSelectedIndex == indexPath.row) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        else{
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        mSelectedIndex = (int)indexPath.row;
        [self.equipmentSelectTableView reloadData];
    }
}

@end
