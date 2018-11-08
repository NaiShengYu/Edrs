//
//  SelectionTableViewController.m
//  edrs
//
//  Created by 余文君, July on 15/8/21.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "SelectionTableViewController.h"

@interface SelectionTableViewController ()

@end

@implementation SelectionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Utility configuerNavigationBackItem:self];
    //根据信息获取数据
    mSelectionArray = [[NSMutableArray alloc]initWithArray:self.selectionArray];
    mSelectionIndex = -1;  //根据实际情况初始化
    NSLog(@"%@",self.selectionArray);
    NSLog(@"%@",mSelectionArray);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    NSLog(@"dealloc");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [mSelectionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"SelectionTableViewCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell.textLabel setText:mSelectionArray[indexPath.row][@"name"]];
    
    if (indexPath.row == mSelectionIndex) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType != UITableViewCellAccessoryCheckmark) {
        mSelectionIndex = indexPath.row;
        [self.tableView reloadData];
    }
}

- (IBAction)actionSubmitSelection:(id)sender {
    NSLog(@"回传数据，根据请求的specialType进行判断");
    if (mSelectionIndex != -1) {
        //普通选择
        [self.delegate setSelectedValue:mSelectionArray[mSelectionIndex][@"id"] content:mSelectionArray[mSelectionIndex][@"name"]];
        if ([self.isSpecial isEqualToString:@"1"]) {
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2] animated:YES];
        }
        else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else{
        NSLog(@"请选择相关项目");
    }
}
@end
