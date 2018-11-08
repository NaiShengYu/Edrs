//
//  ChemicalDetailViewController.m
//  edrs
//
//  Created by 余文君, July on 15/8/14.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "ChemicalDetailViewController.h"
#import "ChemicalDetailInfoViewController.h"
@interface ChemicalDetailViewController ()

@end

@implementation ChemicalDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Utility configuerNavigationBackItem:self];
    //模拟数据
//    mChemical = [[Chemical alloc]init];
//    mChemical = [mChemical setData:[[NSDictionary alloc]initWithDictionary:[CustomHttp getDataFromFile:@"chemical-1"]]];
//    
//    [self chemicalToArrays];
    
    [self getChemicalDetailData];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    NSLog(@"dealloc");
}
#pragma mark - 数据处理
-(void)getChemicalDetailData{
    //获取数据
    mChemical = [[Chemical alloc]init];
    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@",EDRSHTTP, EDRSHTTP_GETCHEMICAL_DETAIL]
                  params:@{@"id":self.cid}
                 success:^(id responseObj) {
                     NSLog(@"get chemical detail success, response = %@", responseObj);
                     mChemical = [mChemical setData:responseObj];
                     [self chemicalToArrays];
                     [self.chemicalDetailTableView reloadData];
                 }
                 failure:^(NSError *err) {
                     NSLog(@"fail to get chemical detail ,error = %@", err);
                 }];
    //获取测试方法
    mTestMethods = [[NSMutableArray alloc]init];
    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@",EDRSHTTP,EDRSHTTP_GETCHEMICAL_TEST] params:@{@"id":self.cid} success:^(id responseObj) {
        NSLog(@"get test success , response = %@", responseObj);
        mTestMethods = responseObj;
        [self.chemicalDetailTableView reloadData];
    } failure:^(NSError *err) {
        NSLog(@"fail to get test");
    }];
    
}

-(void)chemicalToArrays{
    mBaseinfo = [[NSMutableArray alloc]init];
    [mBaseinfo addObject:@{@"cellLabel":@"中文", @"cellContent":mChemical.name}];
    [mBaseinfo addObject:@{@"cellLabel":@"英文", @"cellContent":mChemical.ename}];
    [mBaseinfo addObject:@{@"cellLabel":@"CAS", @"cellContent":mChemical.cas}];
    [mBaseinfo addObject:@{@"cellLabel":@"国标", @"cellContent":mChemical.gb}];
    [mBaseinfo addObject:@{@"cellLabel":@"类别", @"cellContent":mChemical.category}];
    [mBaseinfo addObject:@{@"cellLabel":@"其他", @"cellContent":mChemical.alias}];
    
    mProperty = [[NSMutableArray alloc]init];
    [mProperty addObject:@{@"cellLabel":@"化学式", @"cellContent":mChemical.molecularstr}];
    [mProperty addObject:@{@"cellLabel":@"分子量", @"cellContent":mChemical.molecularmass}];
    [mProperty addObject:@{@"cellLabel":@"熔点", @"cellContent":mChemical.meltingpoint}];
    [mProperty addObject:@{@"cellLabel":@"密度", @"cellContent":mChemical.density}];
    [mProperty addObject:@{@"cellLabel":@"沸点", @"cellContent":mChemical.boilingpoint}];
    
    [mProperty addObject:@{@"cellLabel":@"闪点", @"cellContent":mChemical.flashpoint}];
    [mProperty addObject:@{@"cellLabel":@"蒸汽压", @"cellContent":mChemical.vapourpressure}];
    [mProperty addObject:@{@"cellLabel":@"溶解性", @"cellContent":mChemical.dissolvability}];
    [mProperty addObject:@{@"cellLabel":@"稳定性", @"cellContent":mChemical.stability}];
    [mProperty addObject:@{@"cellLabel":@"优先级", @"cellContent":mChemical.priority?@"true":@"false"}];

    [mProperty addObject:@{@"cellLabel":@"危险标记", @"cellContent":mChemical.dangermark}];
    [mProperty addObject:@{@"cellLabel":@"特性", @"cellContent":mChemical.characteristics}];
    [mProperty addObject:@{@"cellLabel":@"主要用途", @"cellContent":mChemical.application}];
    [mProperty addObject:@{@"cellLabel":@"环境影响", @"cellContent":mChemical.envimpact}];
    [mProperty addObject:@{@"cellLabel":@"应急处理", @"cellContent":mChemical.response}];
    [mProperty addObject:@{@"cellLabel":@"环境标准", @"cellContent":@""}];
}

#pragma mark - table view detail
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //人为分组
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        //测试方法
        return [mTestMethods count];
    }
    else if(section == 1){
        //名称
        return [mBaseinfo count];
    }
    else{
        //理化性质等
        return [mProperty count];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0 && mTestMethods.count == 0){
        return 1;
    }
    return 44.0f;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 56.0f)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 200, 44.0f)];
    [view addSubview:label];
    
    if (section == 0) {
        [label setText:@"测试方法"];
        [label setTextColor:BLUE_COLOR];
        if (mTestMethods.count == 0) {
            return nil;
        }
        
    }
    else if(section == 1){
        [label setText:@"名称"];
    }
    else{
        [label setText:@"理化性质"];
    }
    
    return view;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"chemicalDetailTableViewCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    else{
        while ([[cell.contentView subviews] count]==2) {
            [[[cell.contentView subviews] lastObject] removeFromSuperview];
        }
    }
    
    UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 0, self.view.frame.size.width-100-44, 44)];
    NSMutableAttributedString *attrStr;
    
    if (indexPath.section == 0) {
        //测试方法
        [cell.textLabel setText:mTestMethods[indexPath.row][@"name"]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    else if(indexPath.section == 1){
        //名称等
        [cell.textLabel setText:mBaseinfo[indexPath.row][@"cellLabel"]];
        attrStr = [[NSMutableAttributedString alloc]initWithString:mBaseinfo[indexPath.row][@"cellContent"]];
    }
    else if(indexPath.section == 2){
        //性质等
        [cell.textLabel setText:mProperty[indexPath.row][@"cellLabel"]];
        
        if (indexPath.row == 0 || indexPath.row == 13 || indexPath.row == 14) {
            attrStr = [[NSMutableAttributedString alloc]initWithData:[mProperty[indexPath.row][@"cellContent"] dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        }
        else{
            attrStr = [[NSMutableAttributedString alloc]initWithString:mProperty[indexPath.row][@"cellContent"]];
        }
    }
    else{
    }
    
    //文本处理
    NSRange range = NSMakeRange(0, attrStr.length);
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:range];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:range];
    CGSize size = [attrStr boundingRectWithSize:contentLabel.bounds.size options:NSStringDrawingUsesFontLeading context:nil].size;
    
    if(indexPath.section != 0){
        if (size.width >= contentLabel.frame.size.width || (indexPath.section ==2 && indexPath.row == 13) || (indexPath.section == 2 && indexPath.row == 14)||(indexPath.section == 2 && indexPath.row == 15))
        {
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        else{
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    
    
    [contentLabel setAttributedText:attrStr];
    [cell.contentView addSubview:contentLabel];
    
    //选择样式
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(indexPath.section != 0){
        if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
            //可以进入详情页
            NSDictionary *  item = [[NSDictionary alloc]init];
            if (indexPath.section == 1) {
                item = @{@"name":mChemical.name,@"label":mBaseinfo[indexPath.row][@"cellLabel"],@"content":mBaseinfo[indexPath.row][@"cellContent"]};
                [self performSegueWithIdentifier:@"DetailSegue" sender:item];
            }
            else if(indexPath.section == 2){
                if([indexPath row]==15){
                    ChemicalDetailInfoViewController *vc = [[ChemicalDetailInfoViewController alloc]init];
                    vc.cid = self.cid;
                    [self.navigationController pushViewController:vc animated:YES];
                }else{
                    item = @{@"name":mChemical.name,@"label":mProperty[indexPath.row][@"cellLabel"],@"content":mProperty[indexPath.row][@"cellContent"]};
                    [self performSegueWithIdentifier:@"DetailSegue" sender:item];
                }
               
            }
            
        }
    }
    else{
        
        [self performSegueWithIdentifier:@"ChemicalTestMethodSegue" sender:mTestMethods[indexPath.row]];
    }
}

#pragma mark - detail
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"DetailSegue"]) {
        DetailViewController *targetVC = segue.destinationViewController;
        targetVC.dName = [sender objectForKey:@"name"];
        targetVC.dLabel = [sender objectForKey:@"label"];
        targetVC.dContent = [sender objectForKey:@"content"];
    }
    else if([segue.identifier isEqualToString:@"ChemicalTestMethodSegue"]){
        ChemicalTestMethodViewController *targetVC = segue.destinationViewController;
        targetVC.mid = sender[@"id"];
        targetVC.equipcls = sender[@"equipcls"];
    }
}

@end
