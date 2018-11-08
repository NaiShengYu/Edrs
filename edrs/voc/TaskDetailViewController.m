//
//  TaskDetailViewController.m
//  VOC
//
//  Created by 林鹏, Leon on 2017/3/16.
//  Copyright © 2017年 林鹏, Leon. All rights reserved.
//

#import "TaskDetailViewController.h"
#import "PlantTaskModel.h"
#import "TaskTableViewCell.h"
#import "VocUploadDataViewController.h"
#import "UploadViewController2.h"
#import "NewTaskViewController.h"
@interface TaskDetailViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView ;
    NSArray *dataArray ;
    NSInteger count;
}

@end

@implementation TaskDetailViewController


-(UITextView *)setHeadInfo{
    UITextView *text = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
    text.editable = NO;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithObjects:@[[UIFont systemFontOfSize:14],[UIColor darkGrayColor]] forKeys:@[NSFontAttributeName,NSForegroundColorAttributeName]];
    
    NSString *content = [NSString stringWithFormat:@"样品预处理\n%@\n\n质控说明\n%@\n\n安全防护\n%@\n\n备注\n%@",_sampleModel.pretreatment,_sampleModel.qctip ,_sampleModel.security,_sampleModel.remarks];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:content attributes:dic];
    [dic setValue:[UIFont boldSystemFontOfSize:15] forKey:NSFontAttributeName];
    [dic setValue:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    [attStr setAttributes:dic range:[content rangeOfString:@"样品预处理" ]];
    [attStr setAttributes:dic range:[content rangeOfString:@"质控说明" ]];
    [attStr setAttributes:dic range:[content rangeOfString:@"安全防护" ]];
    [attStr setAttributes:dic range:[content rangeOfString:@"备注" ]];
    text.attributedText = attStr ;
    return text ;
}

-(void)newTaskButtonAction{
    NewTaskViewController *vc = [[NewTaskViewController alloc]init];
    vc.planID = self.sampleModel.id;
    vc.count = count+1;
    [self.navigationController pushViewController:vc animated:YES];
}
-(UIView *)tableBottomView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(20, 10, SCREEN_WIDTH-40, 40)];
    [button setTitle:@"新增任务" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(newTaskButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [button setTintColor:[UIColor whiteColor]];
    [button setBackgroundColor:LIGHT_BLUE];
    button.layer.cornerRadius = 4;
    [view addSubview:button];
    return view;
}
-(void)showButtonAction:(id)sender{
    UIButton *button = (UIButton *)sender;
    if(button.tag ==0){
        [self showUploadDisasterViewController];
    }
}
-(void)addTableView{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    _tableView.dataSource = self ;
    _tableView.delegate = self ;
    _tableView.tableHeaderView = [self setHeadInfo];
    _tableView.tableFooterView = [self tableBottomView];
    [self.view addSubview:_tableView];
}

-(BOOL)checkSunItemInArray:(NSArray *)array subItem:(NSString
                                                     *)item{
    for (NSString *sub in array) {
        if([item isEqualToString:sub]){
            return YES;
        }
    }
    
    return NO;
}
-(NSArray *)getGroupArray:(NSArray *)array{
    NSMutableArray *groupArray = [[NSMutableArray alloc]init];
    NSMutableArray *typeArray = [[NSMutableArray alloc]init];
    for (PlantTaskModel *subItem in array) {
        if(![self checkSunItemInArray:typeArray subItem:subItem.typeid]){
            [typeArray addObject:subItem.typeid];
        }
    }
    
    for (NSInteger i =0 ; i<typeArray.count; i++) {
        NSMutableArray *items = [[NSMutableArray alloc]init];
        NSString *typeId = [typeArray objectAtIndex:i];
        for (PlantTaskModel *subItem in array) {
            if([typeId isEqualToString:subItem.typeid]){
                [items addObject:subItem];
            }
        }
        
        [groupArray addObject:items];
    }
    
    return groupArray;
}

-(void)getPlanTaskList{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:_sampleModel.id forKey:@"planid"];
    [[AppDelegate sharedInstance].httpTaskManager  getWithPortPath:PLAN_TASKS parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        NSMutableArray *array = [[NSMutableArray alloc]init];
        
        NSArray *tempArray = [dictionary valueForKey:@"Items"];
        for (NSDictionary *sub in tempArray) {
            PlantTaskModel *model = [PlantTaskModel modelWithDictionary:sub];
            [array addObject:model];
        }
        count = array.count;
        dataArray=[self getGroupArray:array];
        [_tableView reloadData];
    } onError:^(NSError *engineError) {
        
    }];
}

-(void)showUploadDisasterViewController{
    UploadViewController2  *uploadVC = [[UploadViewController2 alloc]init];
    uploadVC.planModel =  _sampleModel;
    uploadVC.did = self.did;
    [self.navigationController pushViewController:uploadVC animated:YES];
}

-(void)chonfigeNavigationRightItem{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, 30)];
    [button.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [button setTitle:@"数据上传" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showUploadDisasterViewController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem ;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"任务详情";
    self.view.backgroundColor = [UIColor whiteColor];
    [Utility configuerNavigationBackItem:self];
    [self chonfigeNavigationRightItem];
    [self addTableView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self getPlanTaskList];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableView Datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return dataArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *items = [dataArray objectAtIndex:section];
    return items.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[TaskTableViewCell className]];
    if(cell == nil){
        cell = [[TaskTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[TaskTableViewCell className]];
    }
    NSArray *items = [dataArray objectAtIndex:indexPath.section];
    [cell setCellInfoWith:[items objectAtIndex:indexPath.row]];
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSArray *items = [dataArray objectAtIndex:section];
    PlantTaskModel *model = [items firstObject];
    return model.typename;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *items = [dataArray objectAtIndex:indexPath.section];
    PlantTaskModel *model = [items objectAtIndex:indexPath.row];
    if(model.anatype.count ==0){
        return 40;
    }else{
       return 20+model.anatype.count *25;
    }
   
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath  animated:NO];
    
    VocUploadDataViewController *uploadVC = [[VocUploadDataViewController alloc]init];
    NSArray *items = [dataArray objectAtIndex:indexPath.section];
    PlantTaskModel *model = [items objectAtIndex:indexPath.row];

    uploadVC.plantTaskModel =model;
    uploadVC.isFirst = YES;
    if(model.datastatus==0){
        uploadVC.isFirst = YES;
    }else{
        uploadVC.isFirst = NO;
    }
    [self.navigationController pushViewController:uploadVC animated:YES];
}
@end
