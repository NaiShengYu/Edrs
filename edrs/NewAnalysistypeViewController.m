//
//  NewAnalysistypeViewController.m
//  edrs
//
//  Created by 林鹏, Leon on 2017/10/24.
//  Copyright © 2017年 julyyu. All rights reserved.
//

#import "NewAnalysistypeViewController.h"
#import "ChemicalSearchViewController.h"
@interface NewAnalysistypeViewController ()<UITableViewDataSource,UITableViewDelegate,ChemicalSearchDelegate>{
    NSMutableArray *dataArry;
}


@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) UITextField *textField;
@end

@implementation NewAnalysistypeViewController


#pragma mark NetWork
-(void)addNewAnalysistype{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:_textField.text forKey:@"name"];
    @weakify(self);
    [[AppDelegate sharedInstance].httpTaskManager postWithPortPath:ADD_ANALYSIS_FCTOR parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        @strongify(self);
        NSString *data = [dictionary valueForKey:@"data"];
        data = [data stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        [self updateAnalysisFactor:data];
    } onError:^(NSError *engineError) {
        
    }];
}

-(NSArray *)getFactors{
    NSMutableArray *temp = [[NSMutableArray alloc]init];
    
    for (NSDictionary *sub in dataArry) {
        [temp addObject:[sub valueForKey:@"id"]];
    }
    return temp;
}
-(void)updateAnalysisFactor:(NSString *)typeid{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:typeid forKey:@"typeid"];
    [parameters setValue:[self getFactors] forKey:@"factors"];
    @weakify(self);
    [[AppDelegate sharedInstance].httpTaskManager postWithPortPath:UPDATE_ANALYSIS_FCTOR parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        @strongify(self);
    } onError:^(NSError *engineError) {
        
    }];
}
#pragma mark Method

-(void)addNewAction:(id)sender{
    UIStoryboard *story=[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ChemicalSearchViewController *chemicalVC =[story instantiateViewControllerWithIdentifier:@"ChemicalSearchViewController"];
    chemicalVC.delegate = self;
    [self.navigationController pushViewController:chemicalVC animated:YES];
}

-(BOOL)checkTheObjectAdd:(NSDictionary *)objectDic{
    BOOL isAdd = NO;
    for (NSDictionary *sub in dataArry) {
        if([[sub valueForKey:@"name"] isEqualToString:[objectDic valueForKey:@"name"]]){
            isAdd = YES;
        }
    }
    return isAdd ;
}

-(void)setDisasterChemical:(NSDictionary *)dict{
    if(![self checkTheObjectAdd:dict]){
        [dataArry addObject:dict];
        [_tableView reloadData];
    }
}

#pragma mark UIView

-(UIView *)footerView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(20, 20, SCREEN_WIDTH-40, 40)];
    [button setBackgroundColor:LIGHT_BLUE];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addNewAction:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"新增检测因子" forState:UIControlStateNormal];
    [view addSubview:button];
    return view;
}

-(UITextField *)textField{
    if(_textField ==nil){
        _textField = [[UITextField alloc]initWithFrame:CGRectMake(120, 0, SCREEN_WIDTH-130, 46)];
        _textField.placeholder = @"请输入名称";
        _textField.textAlignment = NSTextAlignmentRight;
    }
    return _textField;
}

-(UITableView *)tableView{
    if(_tableView == nil){
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
        _tableView.delegate =self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [self footerView];
    }
    return _tableView;
}

-(void)confiugerNavigationRightItem{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60,40)];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addNewAnalysistype) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"新增采样分类";
    [Utility configuerNavigationBackItem:self];
    [self confiugerNavigationRightItem];
    dataArry = [[NSMutableArray alloc]init];
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma marak UITableView Datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0){
        return 1;
    }else{
        return dataArry.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section==0){
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [cell.contentView addSubview:self.textField];
        cell.textLabel.text = @"分类名称";
        return cell;
    }else{
        NSString *cellName = @"FactorCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if(cell == nil){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        
        NSDictionary *dicInfo= [dataArry objectAtIndex:indexPath.row];
        cell.textLabel.text = [dicInfo valueForKey:@"name"];
        return cell;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section ==0){
        return @"编辑名称";
    }else{
        return @"编辑包含的检测因子";
    }
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle==UITableViewCellEditingStyleDelete){
        [dataArry removeObjectAtIndex:indexPath.row];
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
