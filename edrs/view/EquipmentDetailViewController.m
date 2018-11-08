//
//  EquipmentDetailViewController.m
//  edrs
//
//  Created by 余文君, July on 15/8/14.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "EquipmentDetailViewController.h"

@interface EquipmentDetailViewController ()

@end

@implementation EquipmentDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Utility configuerNavigationBackItem:self];
    //获取数据
    mWarranty = [[NSMutableArray alloc]init];
    mBaseinfo = [[NSMutableArray alloc]init];
    [self getEquipmentDetailData];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getEquipmentDetailData{
    //通过eid获取数据
    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@",EDRSHTTP,EDRSHTTP_GETEQUIPMENT_DETAIL] params:@{@"id":self.eid} success:^(id responseObj) {
        NSLog(@"get equipment detail successfully , response = %@",responseObj);
        [self equipmentToArrays:responseObj];
        [self.equipmentDetailTableView reloadData];
    } failure:^(NSError *err) {
        NSLog(@"fail to get equipment detail");
    }];
}

-(void)equipmentToArrays:(NSMutableDictionary *)dict{
    [mBaseinfo addObject:@{@"cellLabel":@"名称", @"cellContent":[dict objectForKey:@"name"]}];
    [mBaseinfo addObject:@{@"cellLabel":@"编号", @"cellContent":[dict objectForKey:@"code"]}];
    [mBaseinfo addObject:@{@"cellLabel":@"设备类型", @"cellContent":[dict objectForKey:@"type"]==0?@"便携式":@"实验室"}];
    [mBaseinfo addObject:@{@"cellLabel":@"品牌", @"cellContent":[dict objectForKey:@"brand"]}];
    [mBaseinfo addObject:@{@"cellLabel":@"型号", @"cellContent":[dict objectForKey:@"model"]}];
    [mBaseinfo addObject:@{@"cellLabel":@"位置", @"cellContent":[dict objectForKey:@"location"]}];

    [mWarranty addObject:@{@"cellLabel":@"购买日期", @"cellContent":[dict objectForKey:@"purchase_date"]}];
    [mWarranty addObject:@{@"cellLabel":@"保修期限", @"cellContent":[dict objectForKey:@"warranty_expire_date"]}];
}

#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return [mBaseinfo count];
    }
    else{
        return [mWarranty count];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 56.0f;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 56.0f)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 12, 200, 44.0f)];
    if (section == 0) {
        [label setText:@"基本信息"];
    }
    else if(section == 1){
        [label setText:@"保修信息"];
    }
    else{
        
    }
    [view addSubview:label];
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"EquipmentDetailTableViewCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    else{
        if ([[cell.contentView subviews] count] >= 2) {
            [[[[cell contentView]subviews] lastObject] removeFromSuperview];
        }
    }
    
    NSString *tmpstr;
    if (indexPath.section == 0) {
        [cell.textLabel setText:mBaseinfo[indexPath.row][@"cellLabel"]];
        tmpstr = mBaseinfo[indexPath.row][@"cellContent"];
    }
    else if(indexPath.section == 1){
        [cell.textLabel setText:mWarranty[indexPath.row][@"cellLabel"]];
        tmpstr = mWarranty[indexPath.row][@"cellContent"];
    }
    
    UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 0, self.view.frame.size.width-100-44, 44)];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:tmpstr attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f], NSForegroundColorAttributeName:[UIColor grayColor]}];
    CGSize size = [attrStr boundingRectWithSize:contentLabel.bounds.size options:NSStringDrawingUsesFontLeading context:nil].size;
    if (size.width > contentLabel.frame.size.width) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    [contentLabel setAttributedText:attrStr];
    [cell.contentView addSubview:contentLabel];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        //
        NSDictionary *tmpSelectedItem = [[NSDictionary alloc]init];
        if (indexPath.section == 0) {
            tmpSelectedItem = mBaseinfo[indexPath.row];
        }
        else if(indexPath.section == 1){
            tmpSelectedItem = mBaseinfo[indexPath.row];
        }
        
        NSDictionary *item = @{@"name":mBaseinfo[0][@"cellContent"], @"label":tmpSelectedItem[@"cellLabel"], @"content":tmpSelectedItem[@"cellContent"]};
        
        [self performSegueWithIdentifier:@"DetailSegue" sender:item];
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
}


@end
