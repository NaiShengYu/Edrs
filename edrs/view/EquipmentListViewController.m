//
//  EquipmentListViewController.m
//  edrs
//
//  Created by 余文君, July on 15/8/14.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "EquipmentListViewController.h"
#import "MMDrawerBarButtonItem.h"
@interface EquipmentListViewController ()

@end

@implementation EquipmentListViewController
-(void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [leftDrawerButton setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

-(void)leftDrawerButtonPress:(id)sender{
    [[AppDelegate sharedInstance].drawerVC toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(UITableView *)equipmentListTableView{
    if(_equipmentListTableView ==nil){
        _equipmentListTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
        _equipmentListTableView.delegate = self;
        _equipmentListTableView.dataSource = self;
    }
    
    return _equipmentListTableView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupLeftMenuButton];
    [self.view addSubview:self.equipmentListTableView];
    mPageIndex = 0;
    mPageSize = 20;
    
    mEquipmentList = [[NSMutableArray alloc]init];
    mEquipmentType1List = [[NSMutableArray alloc]init];
    mEquipmentType2List = [[NSMutableArray alloc]init];
//    [self getEquipmentListDataLength];
    [self getEquipmentListData];
    
    //样式重设等
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    NSLog(@"dealloc");
}

-(void)getEquipmentListDataLength{
    //页数
    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@",EDRSHTTP,EDRSHTTP_GETEQUIPMENT_LENGTH] params:@{} success:^(id responseObj) {
        NSLog(@"get equipment counts successfully, response = %@", responseObj);
        
        mCount = [responseObj[@"length"] intValue];
        
        
        
        //这个页面没有翻页啊亲
//        if (mPageIndex >= ceil((float)mCount/mPageSize) -1) {
//            [self.equipmentListTableView setShowsPullToRefresh:NO]; //没有下一页了
//        }
        
    } failure:^(NSError *err) {
        NSLog(@"fail to get equipment counts");
    }];
}

-(void)getEquipmentListData{
    [CustomHttp httpPost :[NSString stringWithFormat:@"%@%@",EDRSHTTP, EDRSHTTP_GETEQUIPMENT_PAGE] params:@{@"pageIndex":[NSString stringWithFormat:@"%d",mPageIndex]} success:^(id responseObj) {
        NSLog(@"get equipment list successfully , response = %@", responseObj);
        NSArray *Items =[ responseObj valueForKey:@"Items"];
        for (int i = 0; i< [Items count]; i++) {
            //[mEquipmentList addObject:responseObj[i]];
            if ([Items[i][@"type"] intValue] == 0) {
                [mEquipmentType1List addObject:Items[i]];
            }
            else{
                [mEquipmentType2List addObject:Items[i]];
            }
        }
        [self.equipmentListTableView reloadData];
        
    } failure:^(NSError *err) {
        
    }];
}

#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return mEquipmentType1List.count;
    }
    else{
        return mEquipmentType2List.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return  @"便携式设备";
    }
    else{
       return @"实验室设备";
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56.0f;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"EquipmentListTableViewCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }

    if (indexPath.section == 0) {
        [cell.textLabel setText:mEquipmentType1List[indexPath.row][@"code"]];
        [cell.detailTextLabel setText:mEquipmentType1List[indexPath.row][@"name"]];
    }
    else{
        [cell.textLabel setText:mEquipmentType2List[indexPath.row][@"code"]];
        [cell.detailTextLabel setText:mEquipmentType2List[indexPath.row][@"name"]];
    }
    
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [cell.detailTextLabel setTextColor:[UIColor grayColor]];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //获取必要数据后跳转
    NSString *tmpid;
    if (indexPath.section == 0) {
        tmpid = mEquipmentType1List[indexPath.row][@"id"];
    }
    else{
        tmpid =  mEquipmentType2List[indexPath.row][@"id"];
    }
    
    [self performSegueWithIdentifier:@"EquipmentDetailSegue" sender:tmpid];
}

#pragma mark - view segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"EquipmentDetailSegue"]){
        //跳转到设备详情页面，预处理传值
        EquipmentDetailViewController *targetVC = segue.destinationViewController;
        targetVC.eid = sender;
    }
}



@end
