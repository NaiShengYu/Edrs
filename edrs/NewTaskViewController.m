//
//  NewTaskViewController.m
//  edrs
//
//  Created by 林鹏, Leon on 2017/10/10.
//  Copyright © 2017年 julyyu. All rights reserved.
//

#import "NewTaskViewController.h"
#import "SelectDataModel.h"
#import "DataPickerView.h"
#import "CheckBoxViewController.h"
@interface NewTaskViewController ()<UITableViewDelegate,UITableViewDataSource,CheckBoxViewControllerDelegate>
{
    NSArray *titleArray;
    NSArray *typeArray;
    NSArray *analysisTypes;
    SelectDataModel *selectModel;
}
@property(nonatomic,strong) UITextField *nameTF ;
@property(nonatomic,strong) UITableView *tableview;
@end

@implementation NewTaskViewController


#pragma mark Network


-(void)getSourceTypePagelist{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:@"0" forKey:@"pageIndex"];
    [[AppDelegate sharedInstance].httpTaskManager  postWithPortPath:SOURCE_TYPE_PAGELIST parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        NSArray *Items  = [dictionary valueForKey:@"Items"];
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        for (NSDictionary *sub in Items) {
            SelectDataModel *model = [SelectDataModel modelWithDictionary:sub];
            [tempArray addObject:model];
        }
        typeArray = tempArray;
    } onError:^(NSError *engineError) {
        
    }];
}

-(void)getStaffPageList{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:@"" forKey:@"pageIndex"];
    [[AppDelegate sharedInstance].httpTaskManager  postWithPortPath:STAFF_PAGE_LIST parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        NSLog(@"%@",[dictionary modelToJSONString]);
    } onError:^(NSError *engineError) {
        
    }];
}

-(void)getAnalysisTypePageList{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:@"0" forKey:@"pageIndex"];
    [[AppDelegate sharedInstance].httpTaskManager  postWithPortPath:ANALYSIS_TYPE_PAGELIST parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        NSArray *Items  = [dictionary valueForKey:@"Items"];
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        for (NSDictionary *sub in Items) {
            SelectDataModel *model = [SelectDataModel modelWithDictionary:sub];
            [tempArray addObject:model];
        }
        analysisTypes = tempArray;
    } onError:^(NSError *engineError) {
        
    }];
}

-(void)submitTaskButtonAction{
    [self addNewSampleTask];
}

-(void)addNewSampleTask{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:[NSNumber numberWithInteger:_count] forKey:@"index"];
    [parameters setValue:@"false" forKey:@"ischeck"];
    [parameters setValue:_nameTF.text forKey:@"name"];
    [parameters setValue:self.planID forKey:@"plan"];
    [parameters setValue:selectModel.id forKey:@"typeid"];
    [[AppDelegate sharedInstance].httpTaskManager  postWithPortPath:SAMPLE_TASK_ADD parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        NSString *data = [dictionary valueForKey:@"data"];
        data = [data stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        data = [data stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        [self updateTaskAntype:data];
        NSLog(@"%@",data);
    } onError:^(NSError *engineError) {
 
    }];
}

-(void)updateTaskAntype:(NSString *)taskId{
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:[self getAnalusisIdArray]  forKey:@"Analysistypes"];
    [parameters setValue:taskId forKey:@"taskid"];
  
    [[AppDelegate sharedInstance].httpTaskManager  postWithPortPath:SAMPLE_TASK_UPDATAType parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        BOOL status = [[dictionary valueForKey:@"data"] boolValue];
        NSLog(@"%@",[dictionary modelToJSONString]);
        if(status){
         
             [self updataNewSampleTask:taskId];
        }
    } onError:^(NSError *engineError) {
    }];
}


-(void)updataNewSampleTask:(NSString *)typeId{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:[self getAnalusisJson]  forKey:@"anatype"];
    [parameters setValue:typeId forKey:@"id"];
    [parameters setValue:@"1" forKey:@"index"];
    [parameters setValue:@"false" forKey:@"ischeck"];
    [parameters setValue:_nameTF.text forKey:@"name"];
    [parameters setValue:self.planID forKey:@"plan"];
    [parameters setValue:selectModel.id forKey:@"typeid"];
    [[AppDelegate sharedInstance].httpTaskManager  postWithPortPath:SAMPLE_TASK_UPDATA parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        BOOL status = [[dictionary valueForKey:@"data"] boolValue];
        NSLog(@"%@",[dictionary modelToJSONString]);
        if(status){
            [SVProgressHUD showSuccessWithStatus:@"新增成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } onError:^(NSError *engineError) {
    }];
}

-(void)deleteSampleTask:(NSString *)typeId{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:typeId forKey:@"id"];

    [[AppDelegate sharedInstance].httpTaskManager  postWithPortPath:SAMPLE_TASK_DELETE parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        NSLog(@"%@",[dictionary modelToJSONString]);
    } onError:^(NSError *engineError) {
    }];
}
#pragma mark Method
-(NSArray *)getTitleArray{
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    for (SelectDataModel *model in typeArray) {
        [tempArray addObject:model.name];
    }
    return tempArray;
}

-(NSString *)getAnalysisString{
    NSMutableString *tempStr = [[NSMutableString alloc]init];
    for (SelectDataModel *model in analysisTypes) {
        if(model.state){
            [tempStr appendString:@"-"];
            [tempStr appendString:model.name];
            [tempStr appendString:@" "];
        }
    }
    return tempStr;
}

-(NSArray *)getAnalusisJson{
    NSMutableArray *temp = [[NSMutableArray alloc]init];
    for (SelectDataModel *model in analysisTypes) {
        if(model.state){
            [temp addObject:@{@"id":model.id,@"name":model.name ,@"ischeak":@"true"}];
        }
    }
    
    return temp;
}

-(NSArray *)getAnalusisIdArray{
    NSMutableArray *temp = [[NSMutableArray alloc]init];
    for (SelectDataModel *model in analysisTypes) {
        if(model.state){
            [temp addObject:model.id];
        }
    }
    
    return temp;
}
#pragma mark UIView
-(UITextField *)nameTF{
    if(_nameTF ==nil){
        _nameTF = [[UITextField alloc]initWithFrame:CGRectMake(120, 0, SCREEN_WIDTH-130, 44)];
        _nameTF.placeholder = @"请输入任务名称";
        _nameTF.textAlignment = NSTextAlignmentRight;
    }
    
    return _nameTF;
}
-(UIView *)tableBottomView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(20, 10, SCREEN_WIDTH-40, 40)];
    [button setTitle:@"确 认" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(submitTaskButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [button setTintColor:[UIColor whiteColor]];
    [button setBackgroundColor:LIGHT_BLUE];
    button.layer.cornerRadius = 4;
    [view addSubview:button];
    return view;
}

-(UITableView *)tableview{
    if(_tableview == nil){
        _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.tableFooterView = [self tableBottomView];
    }
    
    return _tableview;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Utility configuerNavigationBackItem:self];
    self.title = @"新增采样任务";
    titleArray = @[@"名称",@"样本类型",@"检测项目"];
    [self.view addSubview:self.tableview];
    
    [self getAnalysisTypePageList];
    [self getSourceTypePagelist];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableView Datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titleArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@""];
    
    cell.textLabel.text = titleArray[indexPath.row];
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if(indexPath.row ==0){
        [cell.contentView addSubview: self.nameTF];
    }
    if(indexPath.row ==1){
        if(selectModel==nil){
            cell.detailTextLabel.text = @"选择样本类型";
        }else{
            cell.detailTextLabel.text = selectModel.name;
        }
       cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if (indexPath.row==2){
        NSString *str = [self getAnalysisString];
        if([str length]==0){
            cell.detailTextLabel.text = @"选择检测项目";
        }else{
            cell.detailTextLabel.numberOfLines =99;
            cell.detailTextLabel.text =str ;
            
        }
        
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row !=2){
        return 44;
    }else{
         NSString *str = [self getAnalysisString];
        if([str length]==0){
            return 44;
        }else{
            CGSize size = [str sizeForFont:[UIFont systemFontOfSize:15] size:CGSizeMake(SCREEN_WIDTH-100, 999) mode:NSLineBreakByWordWrapping];
            return size.height+30;
        }
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.view endEditing:YES];
    if(indexPath.row==1){
        @weakify(self);
        [DataPickerView showWithTitleArray:[self getTitleArray] selectIndex:0 dissMiss:^(NSInteger index){
            @strongify(self);
            selectModel = [typeArray objectAtIndex:index];
            UITableViewCell *cell = [self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            cell.detailTextLabel.text = selectModel.name;
        }];
    }else if (indexPath.row==2){
        CheckBoxViewController *checkBoxVC = [[CheckBoxViewController alloc]init];
        checkBoxVC.dataArray = analysisTypes;
        checkBoxVC.delegate  =self ;
        checkBoxVC.fullScreen = YES;
        checkBoxVC.titleName = @"采样分类";
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:checkBoxVC];
        [self.navigationController presentViewController:nav animated:YES completion:nil];

    }
}

-(void)checkBoxSelect:(NSArray *)dataArray{
    analysisTypes = dataArray;
    [self.tableview reloadData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
