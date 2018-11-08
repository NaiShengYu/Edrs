//
//  UploadDisasterViewController.m
//  edrs
//
//  Created by 林鹏, Leon on 2017/6/5.
//  Copyright © 2017年 julyyu. All rights reserved.
//

#import "UploadDisasterViewController.h"
#import "DataPickerView.h"
#import "CustomAccount.h"

#define kChemical @"Chemical"
#define kSampleInfo @"sample info"
#define kEqupment @"Equpment"
#define kTestMethod @"test method"
@interface UploadDisasterViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    NSInteger cellIndex;
    NSMutableDictionary *pickDataDic;
    NSInteger chemicalIndex ;
    NSInteger sampleIndex;
    NSInteger equpmentIndex;
    NSInteger methodIndex;
}
@property(nonatomic,strong) UISegmentedControl *segcl;
@property(nonatomic,strong) UITextField *valueTF;
@property(nonatomic,strong) UITableView *tableview ;
@end

@implementation UploadDisasterViewController


-(void)getDisasterPlanFactor{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:_planModel.id forKey:@"planid"];
    
    [[AppDelegate sharedInstance].httpTaskManager getWithPortPath: GET_DISASTER_PLANFACTOR parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        NSArray *list = [dictionary valueForKey:@"list"];
        [pickDataDic setValue:list forKey:kChemical];
    } onError:^(NSError *engineError) {
        
    }];
}

-(void)getALLPlanSample{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:_planModel.id forKey:@"planid"];
    
    [[AppDelegate sharedInstance].httpTaskManager getWithPortPath: GET_ALLPLAN_SAMPLE parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        NSArray *list = [dictionary valueForKey:@"list"];
        [pickDataDic setValue:list forKey:kSampleInfo];
    } onError:^(NSError *engineError) {
        
    }];
}

-(void)getEquipmentList{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:@"" forKey:@"searchKey"];
    [parameters setValue:@"-1" forKey:@"pageIndex"];
    [[AppDelegate sharedInstance].httpTaskManager postWithPortPath: GET_EQUIPMENT_LIST parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        NSArray *list = [dictionary valueForKey:@"Items"];
        [pickDataDic setValue:list forKey:kEqupment];
    } onError:^(NSError *engineError) {
        
    }];
}

-(void)testmethodsequence{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:_planModel.refid forKey:@"disasterid"];
    
    NSDictionary *chemicalDic = [[pickDataDic valueForKey:kChemical] objectAtIndex:chemicalIndex];
    [parameters setValue:[chemicalDic valueForKey:@"id"] forKey:@"chemid"];
    
    if(_segcl.selectedSegmentIndex ==0){
        NSDictionary *sampleDic = [[pickDataDic valueForKey:kSampleInfo] objectAtIndex:sampleIndex];
        [parameters setValue:[sampleDic valueForKey:@"nature"] forKey:@"sampletype"];
    }else{
         [parameters setValue:[NSNumber numberWithInteger:sampleIndex] forKey:@"sampletype"];
    }
    [[AppDelegate sharedInstance].httpTaskManager postWithPortPath: GET_TESTMETHOD_SEQUENCE parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        NSArray *list = [dictionary valueForKey:@"list"];
        [pickDataDic setValue:list forKey:kTestMethod];
    } onError:^(NSError *engineError) {
        
    }];
}

-(void)uploadData{
   
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:_planModel.refid forKey:@"disaster"];
    [parameters setValue: [CustomAccount sharedCustomAccount].user.userId forKey:@"staff"];
    
    NSDictionary *sampleDic = [[pickDataDic valueForKey:kSampleInfo] objectAtIndex:sampleIndex];
    [parameters setValue:[sampleDic valueForKey:@"lng"] forKey:@"lng"];
    [parameters setValue:[sampleDic valueForKey:@"lat"] forKey:@"lat"];
    [parameters setValue:[sampleDic valueForKey:@"sdate"] forKey:@"time"];
   
 
    NSMutableDictionary *datalist = [[NSMutableDictionary alloc]init];
    [datalist setValue:_valueTF.text forKey:@"value"];
    [datalist setValue:[sampleDic valueForKey:@"nature"] forKey:@"nature"];
    
    if(chemicalIndex >=0){
    NSDictionary *chemicalDic = [[pickDataDic valueForKey:kChemical] objectAtIndex:chemicalIndex];
        [datalist setValue:[chemicalDic valueForKey:@"factorid"] forKey:@"factor"];
        [datalist setValue:[chemicalDic valueForKey:@"unitid"] forKey:@"unitid"];
        [datalist setValue:[chemicalDic valueForKey:@"name"] forKey:@"factorname"];
    }
    
    if(equpmentIndex >=0){
        NSDictionary *equipmentDic = [[pickDataDic valueForKey:kEqupment] objectAtIndex:equpmentIndex];
        [datalist setValue:[equipmentDic valueForKey:@"id"] forKey:@"equipment"];
    }
    
    if(methodIndex >=0){
    NSDictionary *methodDic = [[pickDataDic valueForKey:kTestMethod] objectAtIndex:methodIndex];
    [datalist setValue:[methodDic valueForKey:@"id"] forKey:@"testmethod"];
    }
    [parameters setValue:@[datalist] forKey:@"datalist"];
    [SVProgressHUD show];
    [[AppDelegate sharedInstance].httpTaskManager postWithPortPath: ADD_DISASTER_DATA parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        if([[dictionary valueForKey:@"data"] boolValue]){
            [SVProgressHUD dismissWithSuccess:@"上传成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [SVProgressHUD dismissWithError:@"数据异常"];
        }
    } onError:^(NSError *engineError) {
      
    }];

}



-(void)setMethodData{
    if(chemicalIndex>=0 && sampleIndex>=0){
        UITableViewCell *cell = [self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
        cell.detailTextLabel.text =@"";
        [self testmethodsequence];
    }
}
-(void)showDataPicekr{
    
    NSArray *array = [self getPickerData];
    
    if(array.count ==0){
        [SVProgressHUD showErrorWithStatus:@"数据尚未录入"];
    }else{
        @weakify(self);
        [DataPickerView showWithTitleArray:array selectIndex:0 dissMiss:^(NSInteger index){
            
            @strongify(self);
            UITableViewCell *cell = [self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:cellIndex inSection:0]];
            cell.detailTextLabel.text = [[self getPickerData] objectAtIndex:index];
            switch (cellIndex) {
                case 0:{
                    if(chemicalIndex !=index){
                        chemicalIndex = index;
                        methodIndex = -1;
                        [self setMethodData];
                    }
                    
                    break;
                }
                case 1:
                    if( sampleIndex != index){
                        sampleIndex = index;
                        methodIndex = -1;
                        [self setMethodData];
                    }
                    break;
                case 2:
                    equpmentIndex = index;
                    break;
                case 3:
                    methodIndex = index;
                    break;
                default:
                    break;
            }
            
       
        }];
    }
   
}

-(void)segmentedControlChange{
    [_tableview reloadData];
}

#pragma mark Data
-(NSArray *)typeArray{
    return @[@"气",@"水",@"土"];
}

-(NSArray *)getPickerData{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    NSString *keyName  ;
    NSString *titleName ;
    
    if(cellIndex ==1 && _segcl.selectedSegmentIndex ==1){
        return [self typeArray];
    }
    switch (cellIndex) {
        case 0:
            keyName = kChemical;
            titleName =  @"name";
            break;
        case 1:
            keyName = kSampleInfo;
            titleName =  @"sno";
            break;
        case 2:
            keyName = kEqupment;
            titleName =  @"name";
            break;
        case 3:
            keyName = kTestMethod;
            titleName =  @"name";
            break;
        default:
            break;
    }
    
    NSArray *dataArray = [pickDataDic valueForKey:keyName];
    for (NSDictionary *sub in dataArray) {
        [array addObject:[sub valueForKey:titleName]];
    }
    return array;
}

-(NSArray *)titleArray{
      if(_segcl.selectedSegmentIndex ==0){
       return   @[@"化学品",@"样本",@"设备",@"检测方法",@"结果值"];
    }else{
       return   @[@"化学品",@"事故类型",@"设备",@"检测方法",@"结果值"];
    }
    
}
#pragma mark UIView
-(UITableView *)tableview{
    if(_tableview ==nil){
        _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 250)];
        _tableview.dataSource = self ;
        _tableview.delegate = self ;
        _tableview.tableFooterView = [UIView new];
        _tableview.scrollEnabled = NO;
    }
    
    return _tableview;
}

-(UIView *)navigationView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(60, 0, SCREEN_WIDTH-120, 44)];
    NSArray *titles = @[@"样本数据",@"现场数据"];
    _segcl = [[UISegmentedControl alloc]initWithItems:titles];
    [_segcl addTarget:self action:@selector(segmentedControlChange) forControlEvents:UIControlEventValueChanged];
    [_segcl setTintColor:[UIColor whiteColor]];
    [_segcl setSelectedSegmentIndex:0];
    _segcl.center =CGPointMake(view.width/2, view.height/2) ;
    [view addSubview:_segcl];
    
    return view;
}

-(UIView *)footView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, _tableview.bottom+30, SCREEN_WIDTH, 80)];
    UIButton *submitBT = [[UIButton alloc]initWithFrame:CGRectMake(20, 20, SCREEN_WIDTH-40, 40)];
    submitBT.layer.cornerRadius = 4;
    [submitBT addTarget:self action:@selector(uploadData) forControlEvents:UIControlEventTouchUpInside];
    [submitBT setTitle:@"提交数据" forState:UIControlStateNormal];
    [submitBT setBackgroundColor:LIGHT_BLUE];
    [submitBT setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [view addSubview:submitBT];
    return view;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [Utility configuerNavigationBackItem:self];
    self.view.backgroundColor = [UIColor whiteColor];
    
    pickDataDic= [[NSMutableDictionary alloc]init];
    self.navigationItem.titleView = [self navigationView];
    [self.view addSubview:self.tableview];
    [self.view addSubview:[self footView]];
    
 
    chemicalIndex = -1 ;
    sampleIndex =  -1 ;
    equpmentIndex = -1 ;
    methodIndex = -1 ;
    [self getDisasterPlanFactor];
    [self getALLPlanSample];
    [self getEquipmentList];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITaleView Datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self titleArray].count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[UITableViewCell className]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.text = [[self titleArray] objectAtIndex:indexPath.row];
    if(indexPath.row==4 ){
        [cell.contentView removeAllSubviews];
        _valueTF = nil;
        if(_valueTF ==nil){
            _valueTF = [[UITextField alloc]initWithFrame:CGRectMake(120, 0, SCREEN_WIDTH-150, 46)];
            _valueTF.returnKeyType = UIReturnKeyDone;
            _valueTF.delegate = self;
            _valueTF.placeholder = @"样本检测数值";
            _valueTF.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:_valueTF];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.row<4){
        cellIndex = indexPath.row ;
        [self showDataPicekr];
    }
}


#pragma mark UITextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}
@end
