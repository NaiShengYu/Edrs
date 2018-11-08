//
//  UploadViewController2.m
//  edrs
//
//  Created by 林鹏, Leon on 2017/9/14.
//  Copyright © 2017年 julyyu. All rights reserved.
//

#import "UploadViewController2.h"
#import "AppDelegate.h"
#import "CustomUtil.h"
#import "Constants.h"
#import "CheckBoxViewController.h"
#import "ChemicalSearchViewController.h"
#import "WindsViewController.h"
#import "SelectDataModel.h"
#import "TaskDetailViewController.h"
#import "QRCodeReaderViewController.h"
#import "SelectionTableViewController.h"
#import "SelectDataModel.h"
#import "PollutionsViewController.h"
#import "VocUploadDataViewController.h"
#import "TaskTableViewCell.h"
#import "SourceFactorModel.h"
#import "PlantTaskModel.h"
@interface UploadViewController2 ()<ChemicalSearchDelegate,CheckBoxViewControllerDelegate,WindsDataDelegate,QRCodeReaderViewControllerDelegate,UITextFieldDelegate,SelectionDelegate>{
    NSMutableArray *mTestChemicalList;
    NSMutableArray *factorArray;
    NSString *selectedNature;

    UILabel *qrCodeLabel;
    NSInteger unitIndex;
    NSMutableArray *items;
    BOOL isFactor;
}

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) NSArray *mUnitList;
@property (nonatomic,strong)NSMutableArray *dataArray;
@end

@implementation UploadViewController2

#pragma mark Network
-(void)inputBatchAdd:(NSDictionary *)dict{
    NSMutableDictionary *details ;
    NSNumber *typeNum = [dict valueForKey:@"typeIndex"];
    InputBatchModel *model = [[InputBatchModel alloc]init];
    if([typeNum integerValue] == 1){
        model.chemid = dict[@"id"];
        details = [self createSpecialInputbatch:SpecialInputTypeDisasterChemicalIdentified refid1:@"" refid2:dict[@"id"] remarks:dict[@"name"]];
    }else{
        model.id = dict[@"id"];
        details = [self createSpecialInputbatch:SpecialInputTypeDisasterChemicalIdentified refid1:dict[@"id"] refid2:@"" remarks:dict[@"name"]];
    }
    
   
    model.name = dict[@"name"];
   
    NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]init];
    [tmpDict setValue:@[details] forKey:@"details"];
    [tmpDict setValue:@"4" forKey:@"type"];
    if(_planModel){
         [tmpDict setValue:_planModel.refid forKey:@"disasterid"];
    }else{
        [tmpDict setValue:self.did forKey:@"disasterid"];
    }
   
//    [tmpDict setValue:[[NSUserDefaults standardUserDefaults] stringForKey:USERID] forKey:@"staffid"];
    [tmpDict setValue:[NSString stringWithFormat:@"%0.8f",[AppDelegate sharedInstance].location2D.longitude ] forKey:@"lng"];
    [tmpDict setValue:[NSString stringWithFormat:@"%0.8f",[AppDelegate sharedInstance].location2D.latitude ] forKey:@"lat"];
    
    @weakify(self);
    [[AppDelegate sharedInstance].httpTaskManager postWithPortPath:DISASTER_INPUTBATCH_ADD parameters:tmpDict onSucceeded:^(NSDictionary *dictionary) {
        
        @strongify(self);
        NSString *commitId= [dictionary  valueForKey:@"id"];
        if(commitId!=nil){
            [self inputBatchCommit:commitId];
             model.id = commitId;

            [mTestChemicalList insertObject:model atIndex:0];
            [self.tableView reloadData];
        }else{
            
            [SVProgressHUD showErrorWithStatus:[dictionary valueForKey:@"reason"]];
        }
    } onError:^(NSError *engineError) {
        
    }];
}

-(void)inputBatchCommit:(NSString *)commitID{
    NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]init];
    [tmpDict setValue:commitID forKey:@"id"];
   
    [[AppDelegate sharedInstance].httpTaskManager postWithPortPath:DISASTER_INPUTBATCH_COMMIT parameters:tmpDict onSucceeded:^(NSDictionary *dictionary) {
        if([[dictionary  valueForKey:@"success"] boolValue]){
            [SVProgressHUD showSuccessWithStatus:@"上传成功"];
        }else{
             [SVProgressHUD showErrorWithStatus:@"上传失败"];
        }
    } onError:^(NSError *engineError) {
        
    }];
}

-(void)uploadAllData:(BOOL)isUpload{
    
    for (NSInteger i = 0; i<mTestChemicalList.count; i++) {
        InputBatchModel *model = [mTestChemicalList objectAtIndex:i];
       
        if([model.inptValue length]>0 && [model.unitName length]>0 ){
            model.nature = selectedNature;
            if(_codeModel ==nil){
                if(_planModel !=nil){
                    model.disasterid = _planModel.refid;
                    model.staffid =[[NSUserDefaults standardUserDefaults] stringForKey:USERID] ;
                    model.lng =  [NSString stringWithFormat:@"%0.8f",_planModel.lng ];
                    model.lat =  [NSString stringWithFormat:@"%0.8f",_planModel.lat ];
                }else{
                    model.disasterid = self.did;
                    model.staffid = [[NSUserDefaults standardUserDefaults] stringForKey:USERID] ;
//                    model.lng = [NSString stringWithFormat:@"%0.8f",[AppDelegate sharedInstance].location2D.longitude ];
//                    model.lat = [NSString stringWithFormat:@"%0.8f",[AppDelegate sharedInstance].location2D.latitude ];
                    model.lng =  [NSString stringWithFormat:@"%0.8f",_sampleModel.lng ];
                    model.lat =  [NSString stringWithFormat:@"%0.8f",_sampleModel.lat ];
                }
                
            }else{
                model.disasterid = _codeModel.disasterid;
                model.staffid = _codeModel.staffid;
                model.lng = _codeModel.lng;
                model.lat = _codeModel.lat;
            }
        
        }else if ([model.inptValue length]==0 && [model.unitName length]>0){
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"请填写%@的数值",model.name]];
            return ;
        }else if ([model.inptValue length]>0 && [model.unitName length]==0){
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"请填写%@单位",model.name]];
            return;
        }
    }
    
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    for (InputBatchModel *sub in mTestChemicalList) {
        if([sub.inptValue length]>0 && [sub.unitName length]>0 ){
            if(isUpload){
                [self submitData:sub];
            }else{
                [tempArray addObject:sub];
            }
        }
    }
    
    if(!isUpload){
        NSMutableArray *newArray = [[NSMutableArray alloc]init];
        NSString *localData = [[NSUserDefaults standardUserDefaults] valueForKey:@"locationData"];
        if(localData != nil){
            NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:[localData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            for (NSDictionary *sub in dataArray) {
                InputBatchModel *model = [InputBatchModel modelWithDictionary:sub];
                [newArray addObject:model];
            }
        }
        [newArray addObjectsFromArray:tempArray];
        [[NSUserDefaults standardUserDefaults] setValue:[newArray modelToJSONString] forKey:@"locationData"];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)submitData:(InputBatchModel *)model{
    [self.view endEditing:YES];
    
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    NSString *apiName ;
    if(_planModel !=nil){
         apiName = ADD_DISASTER_DATA ;
         [parameters setValue:model.disasterid forKey:@"disaster"];
        [parameters setValue:_planModel.id forKey:@"planid"];
         [parameters setValue: model.staffid forKey:@"staff"];
         [parameters setValue:[Utility NSDateToNSString4:[NSDate date]] forKey:@"time"];
        
        NSMutableDictionary *datalist = [[NSMutableDictionary alloc]init];
        [datalist setValue:model.inptValue forKey:@"value"];
        [datalist setValue:model.nature forKey:@"nature"];
    
        [datalist setValue:model.factorid forKey:@"factor"];
        [datalist setValue:model.unitId  forKey:@"unitid"];
        [datalist setValue:model.name forKey:@"factorname"];
        [datalist setValue:@"990a6e26-dfd1-417d-86b8-34fa3dd4c0ce" forKey:@"equipment"];
        [datalist setValue:@"c5b1c53a-9950-4155-80b2-60f469490121" forKey:@"testmethod"];
        [parameters setValue:@[datalist] forKey:@"datalist"];
    }else{
        apiName = EDRSHTTP_GETDISASTER_DETAIL_SET_CHEMICALS ;
        [parameters setValue:model.disasterid forKey:@"disasterid"];
        [parameters setValue:model.staffid forKey:@"staffid"];
        
        [parameters setObject:model.id forKey:@"chemical"];
        [parameters setObject:model.name forKey:@"chemicalname"];
        [parameters setObject:model.unitId forKey:@"unitid"];
        [parameters setObject:model.inptValue forKey:@"value"];
        [parameters setObject:model.nature forKey:@"nature"];
    }
    
    [parameters setValue:model.lng forKey:@"lng"];
    [parameters setValue:model.lat forKey:@"lat"];
  
    [[AppDelegate sharedInstance].httpTaskManager postWithPortPath:apiName parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        NSString *keyName ;
         if(_planModel !=nil){
             keyName = @"data";
         }else{
             keyName = @"success";
         }
        if([[dictionary valueForKey:keyName] boolValue]){
            [SVProgressHUD showSuccessWithStatus:@"上传成功" ];
        }else{
            [SVProgressHUD showErrorWithStatus:@"请填写完整数据"];
        }
    } onError:^(NSError *engineError) {
        [SVProgressHUD showErrorWithStatus:@"网络异常"];
       
    }];

}

-(void)uploadWind:(NSString *)windInfo{
    NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]init];
    [tmpDict setValue:self.did forKey:@"disasterid"];
    [tmpDict setValue:[[NSUserDefaults standardUserDefaults] stringForKey:USERID] forKey:@"staffid"];

    [tmpDict setObject:windInfo forKey:@"remarks"];
   
    [[AppDelegate sharedInstance].httpTaskManager postWithPortPath:DISASTER_SET_WIND parameters:tmpDict onSucceeded:^(NSDictionary *dictionary) {
        if([[dictionary  valueForKey:@"success"] boolValue]){
            [SVProgressHUD showSuccessWithStatus:@"上传成功"];
        }else{
            [SVProgressHUD showErrorWithStatus:@"上传失败"];
        }
    } onError:^(NSError *engineError) {
        
    }];
}

-(void)uploadDisaterNature:(NSString *)natureStr{
    
    NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]init];
    [tmpDict setValue:self.did forKey:@"disasterid"];
    [tmpDict setValue:[[NSUserDefaults standardUserDefaults] stringForKey:USERID] forKey:@"staffid"];
    
    [tmpDict setObject:natureStr forKey:@"nature"];
    
    [[AppDelegate sharedInstance].httpTaskManager postWithPortPath:DISASTER_SETDISTATER_NATURE parameters:tmpDict onSucceeded:^(NSDictionary *dictionary) {
        if([[dictionary  valueForKey:@"success"] boolValue]){
            [SVProgressHUD showSuccessWithStatus:@"上传成功"];
        }else{
            [SVProgressHUD showErrorWithStatus:@"上传失败"];
        }
    } onError:^(NSError *engineError) {
        
    }];
}

-(void)getUnit{
    @weakify(self);
    [[AppDelegate sharedInstance].httpTaskManager getWithPortPath:EDRSHTTP_NUITMEASURE_GETUNIT parameters:nil onSucceeded:^(NSDictionary *dictionary) {
        @strongify(self);
        self.mUnitList = [dictionary valueForKey:@"list"];
        
    } onError:^(NSError *engineError) {
        
    }];
}

-(BOOL)cheackInpuBatchModel:(InputBatchModel *)model{
    
    BOOL isAdded = NO;
    for (InputBatchModel *subModle in factorArray) {
        if([subModle.name isEqualToString:model.name]){
            isAdded =YES ;
        }
    }
    
    return isAdded;
}
-(void)getDisasterFactors{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:self.did forKey:@"id"];
    NSString *apiName  = EDRSHTTP_GETDISASTER_DETAIL_FACTORS;
    @weakify(self);
    [[AppDelegate sharedInstance].httpTaskManager getWithPortPath:apiName parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        @strongify(self);
        NSArray *list = [dictionary valueForKey:@"list"];
        for (int i = 0; i < [list count] ; i++) {
            InputBatchModel *modle =[ InputBatchModel modelWithDictionary:list[i]];
           [factorArray addObject:modle];
        }

        if(_planModel ==nil){
            [mTestChemicalList removeAllObjects];
            [mTestChemicalList addObjectsFromArray:factorArray];
            [self.tableView reloadData];
        }else{
           [self getSampleTaskFacors];
        }
        
        
    } onError:^(NSError *engineError) {
        
    }];
}

-(void)getSampleTaskFacors{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
   [parameters setValue:_planModel.id forKey:@"planid"];
    NSString *apiName = @"/api/Sampleplan/GetDisasterPlanFactor";
    @weakify(self);
    [[AppDelegate sharedInstance].httpTaskManager getWithPortPath:apiName parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        @strongify(self);
        NSArray *list = [dictionary valueForKey:@"list"];
        for (int i = 0; i < [list count] ; i++) {
            InputBatchModel *modle =[ InputBatchModel modelWithDictionary:list[i]];
            if(![self cheackInpuBatchModel:modle]){
                [factorArray addObject:modle];
            }
        }
        [mTestChemicalList removeAllObjects];
        if(_qrcodeInfo.count==0){
            [mTestChemicalList addObjectsFromArray:factorArray];
        }else{
          [mTestChemicalList addObjectsFromArray:[self getTheFactorArray]];
        }
         [self.tableView reloadData];
    } onError:^(NSError *engineError) {
        
    }];
    
}

#pragma mark Method

-(BOOL)checkTheFactorInTaskInfo:(NSString *)factorName{
    BOOL isAdded = NO;
    for (NSDictionary *dic in _qrcodeInfo) {
        NSString *tempName = [dic valueForKey:@"name"] ;
        NSString *tempValue = [dic valueForKey:@"value"] ;
        if([tempName isEqualToString:@"检测项目"] &&[tempValue containsString:factorName]){
            isAdded = YES;
        }
    }
    return  isAdded;
}
-(NSArray *)getTheFactorArray{
    NSMutableArray *temp = [[NSMutableArray alloc]init];
    for (InputBatchModel *sub in factorArray) {
        if([self checkTheFactorInTaskInfo:sub.name]){
            [temp addObject:sub];
        }
    }
    
    return temp;
}
-(SamplePlanModel *)getNearPlanModle{
    SamplePlanModel *minModel ;
    CGFloat  distanceMeters = 0;
    for (SamplePlanModel *model in _taskArray) {
        
        CLLocationCoordinate2D location = [AppDelegate sharedInstance].location2D;
        CLLocation *orig=[[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
        CLLocation* dist=[[CLLocation alloc] initWithLatitude:model.lat  longitude:model.lng];
        CLLocationDistance kilometers=[orig distanceFromLocation:dist]/1000;
        
        if(minModel==nil){
            minModel = model;
            distanceMeters = kilometers;
        }else{
            if(kilometers < distanceMeters){
                minModel = model;
                distanceMeters = kilometers;
            }
        }
    }
    return minModel;
}
-(NSArray *)getGudingji{
    NSArray *array = @[@"气",@"水",@"土"];
    NSMutableArray *dataArray =[[NSMutableArray alloc]init];
    for (NSInteger i = 0; i<array.count; i++) {
        SelectDataModel *newModel = [[SelectDataModel alloc]init];
        newModel.id = [NSString stringWithFormat:@"i"];
        newModel.name = [array objectAtIndex:i];
        [dataArray addObject:newModel];
    }
    return dataArray ;
}

-(NSString *)getSelectedNature:(NSArray *)dataArray{
    NSString *idStr ;
    for (NSInteger i = 0; i<dataArray.count; i++) {
        SelectDataModel *sub = [dataArray objectAtIndex:i];
        if(sub.state){
            if(idStr ==nil){
                idStr=@"1";
            }else{
                idStr=[NSString stringWithFormat:@"%@1",idStr];
            }
        }else{
            if(idStr ==nil){
                idStr=@"0";
            }else{
                idStr=[NSString stringWithFormat:@"%@0",idStr];
            }
        }
    }
    
    
//    selectedNature = idStr;
    return idStr;
}


#pragma mark Action
-(void)selectAtIndex:(id)sender{
    UIButton *button = (UIButton *)sender;
    selectedNature= [NSString stringWithFormat:@"%li",(long)button.tag];
    for (NSInteger i = 0; i<items.count; i++) {
         UIButton *subItem = items[i];
        if(i==button.tag){
            [subItem setImage:[UIImage imageNamed:@"on"] forState:UIControlStateNormal];
        }else{
            [subItem setImage:[UIImage imageNamed:@"off"] forState:UIControlStateNormal];
        }
    }
}
-(void)showButtonAction:(id)sender{
    UIButton *button = (UIButton *)sender;
    if(button.tag ==0){
//       PollutionsViewController *pollutionsVC = [[PollutionsViewController alloc]init];
//       pollutionsVC.dataArray = self.taskArray;
//       pollutionsVC.did = self.did;
//       [self.navigationController pushViewController:pollutionsVC animated:YES];
        
        TaskDetailViewController *detailVC = [[TaskDetailViewController alloc]init];
        detailVC.sampleModel = self.sampleModel;
        detailVC.did =self.did;
        [self.navigationController pushViewController:detailVC animated:YES];
        
        
        
        //       pollutionsVC.showLocationInfo = _showLocationInfo;

//        SamplePlanModel *model = [self getNearPlanModle];
//        if(model){
//            TaskDetailViewController *taskVC = [[TaskDetailViewController alloc]init];
//            taskVC.sampleModel = model;
//            [self.navigationController pushViewController:taskVC animated:YES];
//        }else{
//            [SVProgressHUD showErrorWithStatus:@"请先添加采样计划"];
//        }
    }else if(button.tag ==1){
        isFactor = NO;
        CheckBoxViewController *checkBoxVC = [[CheckBoxViewController alloc]init];
        checkBoxVC.dataArray = [self getGudingji];
        checkBoxVC.delegate  =self ;
        checkBoxVC.titleName = @"事故性质";
        [self addChildViewController:checkBoxVC];
        [self.view addSubview:checkBoxVC.view];
    }else if(button.tag ==2){
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        WindsViewController *windsVC = [story instantiateViewControllerWithIdentifier:@"WindsViewController"];
        windsVC.delegate = self;
        [self.navigationController pushViewController:windsVC animated:YES];
    }
    
}



-(void)showAlertView{
     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确认数据类型" message:@"\n\n\n\n" preferredStyle:UIAlertControllerStyleAlert];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 60,240, 60)];
    selectedNature = @"0";
    [items removeAllObjects];
    NSArray *titles = @[@"气",@"水",@"土",@"其他"];
    for (NSInteger i =0; i<titles.count; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(10+60*i, 10, 60, 30)];
        if(i==0){
            [button setImage:[UIImage imageNamed:@"on"] forState:UIControlStateNormal];
        }else{
             [button setImage:[UIImage imageNamed:@"off"] forState:UIControlStateNormal];
        }
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        button.tag = i;
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(selectAtIndex:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [view addSubview:button];
        [items addObject:button];
    }
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"保存本地" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
         [self uploadAllData:NO];
    }];
    [alertController addAction:save];
    
    UIAlertAction *upload = [UIAlertAction actionWithTitle:@"上传" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
       
        [self uploadAllData:YES];
    }];
    [alertController addAction:upload];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
       
    }];
    [alertController addAction:cancel];
    
    [alertController.view addSubview:view];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)keyboardDidShow{
    if(_planModel !=nil){
        _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 230)];
    }
}

-(void)keyboardDidHide{
    if(_planModel !=nil){
        _tableView.tableFooterView = nil;
    }
}

-(BOOL) cheackTheSelectDataStatus:(SamplePlanModel*)model{
    BOOL isSelect = NO;
    for (SamplePlanModel *subModel in mTestChemicalList) {
        if([subModel.name isEqualToString:model.name]){
            isSelect = YES ;
        }
    }
    
    return isSelect;
}
-(NSArray *)getShowSelectDataArray{
    NSMutableArray *temp = [[NSMutableArray alloc]init];
    for (NSInteger i = 0 ; i<factorArray.count; i++) {
        SamplePlanModel *model = [factorArray objectAtIndex:i];
        SelectDataModel *newModel = [[SelectDataModel alloc]init];
        newModel.name = model.name;
        newModel.state = [self cheackTheSelectDataStatus:model];
        [temp addObject:newModel];
    }
    return temp;
}

-(void)factorAarraySelectItemWith:(NSArray *)selectArray{
    [mTestChemicalList removeAllObjects];
    for (NSInteger i = 0; i<selectArray.count; i++) {
        SelectDataModel *model = [selectArray objectAtIndex:i];
        SamplePlanModel *planModel = factorArray[i];
        if(model.state){
            [mTestChemicalList addObject:planModel];
        }
    }
    [self.tableView reloadData];
}
-(void)showSetViewAction{
    isFactor= YES;
    [self.view endEditing:YES];
    CheckBoxViewController *checkBoxVC = [[CheckBoxViewController alloc]init];
    checkBoxVC.title = @"因子名称";
    checkBoxVC.dataArray = [self getShowSelectDataArray];
    checkBoxVC.delegate  =self ;
    [self addChildViewController:checkBoxVC];
    [self.view addSubview:checkBoxVC.view];
}

#pragma uiview
-(void)configuerNavigationRightItem{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 40)];
    [button setTitle:@"确定" forState:UIControlStateNormal];

    [button addTarget:self action:@selector(showAlertView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
}
-(void)addNewFactor{
    UIStoryboard *story=[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ChemicalSearchViewController *chemicalVC =[story instantiateViewControllerWithIdentifier:@"ChemicalSearchViewController"];            chemicalVC.delegate = self;
    [self.navigationController pushViewController:chemicalVC animated:YES];
}

-(UIView *)tableViewHeadView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    UIImageView *iconView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 40, 40)];
    [view addSubview:iconView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 5, 150, 40)];
    titleLabel.font =[UIFont boldSystemFontOfSize:15];
    [view addSubview:titleLabel];
    
    if(_planModel== nil || [_planModel.refid length]>0){
        UIButton *righticon = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-60, 10, 30, 30)];
        [righticon addTarget:self action:@selector(addNewFactor) forControlEvents:UIControlEventTouchUpInside ];
        [righticon setImage:[UIImage imageNamed:@"add_white"] forState:UIControlStateNormal];
        [view addSubview:righticon];
        
        if(_qrcodeInfo !=nil){
            UIButton *lefticon = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-120, 10, 30, 30)];
            [lefticon addTarget:self action:@selector(showSetViewAction) forControlEvents:UIControlEventTouchUpInside ];
            [lefticon setImage:[UIImage imageNamed:@"set"] forState:UIControlStateNormal];
            [view addSubview:lefticon];
        }
        
    }
        titleLabel.text = @"因子";
        iconView.image = [UIImage imageNamed:@"huaxuepin"];
    return view;

}

-(UIView *)tableViewFootView{
    
    
    UIView *view = [[UIView alloc]initWithFrame:_planModel ? CGRectMake(0, 10, SCREEN_WIDTH, 45) :CGRectMake(0, 10, SCREEN_WIDTH, 90)];
    view.backgroundColor = [UIColor whiteColor];
  
    NSArray *titleArray =  @[@"事故性质",@"风速风向"];
    NSArray *images =  @[@"shandian",@"fengxiang"];
    for (NSInteger i = 0 ; i<titleArray.count;i++){
        UIImageView *iconView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 7+45*i, 30, 30)];
        iconView.image = [UIImage imageNamed:images[i]];
        [view addSubview:iconView];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 7+45*i, 120, 30)];
        titleLabel.font =[UIFont boldSystemFontOfSize:15];
        titleLabel.text = titleArray[i];
        [view addSubview:titleLabel];
        
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 45*i, SCREEN_WIDTH, 45)];
        [button addTarget:self action:@selector(showButtonAction:) forControlEvents:UIControlEventTouchUpInside ];
        button.tag = i+1;
        [view addSubview:button];
        
        UIImageView *righticonView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-35, 9+45*i, 26, 26)];
        righticonView.image = [UIImage imageNamed:@"rightarrow"];
        [view addSubview:righticonView];
        
        if(i!=1){
            UIView *lineView= [[UIView alloc]initWithFrame:CGRectMake(0, 45*(i+1), SCREEN_WIDTH, 1)];
            lineView.backgroundColor = RGBA_COLOR(239, 239, 244, 0.9);
            [view addSubview:lineView];
        }
    }
   
    return view;
}

-(UIView *)tableViewWithQRcodeInfo{
    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 150)];
    NSMutableString *str = [[NSMutableString alloc]init];
    for (NSDictionary *sub in _qrcodeInfo) {
        [str appendString:[sub valueForKey:@"name"]];
        [str appendString:@" : "];
        [str appendString:[sub valueForKey:@"value"]];
        [str appendString:@",     "];
    }
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc]initWithString:str];
    NSInteger startIndex = 0 ;
    for (NSDictionary *sub in _qrcodeInfo) {
        NSString *name = [sub valueForKey:@"name"];
        NSString *value = [sub valueForKey:@"value"];
        NSRange range_name = NSMakeRange(startIndex, name.length);
        startIndex= startIndex+name.length+3;
        NSRange range_value = NSMakeRange(startIndex, value.length);
        startIndex = startIndex+value.length+6;
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:range_name];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:LIGHT_BLUE range:range_value];
         [attributeStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:range_value];
        
    }
    textView.attributedText = attributeStr;
    return textView;
}
-(UITableView *)tableView{
    if(_tableView == nil){
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
        _tableView.tableHeaderView = [self tableViewHeadView];
        if(_planModel == nil){
            _tableView.tableFooterView = [self tableViewFootView];
        }
        
        if(_qrcodeInfo){
            _tableView.tableFooterView = [self tableViewWithQRcodeInfo];
        }
        _tableView.delegate = self ;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataArray =[[NSMutableArray alloc]init];
    self.title = @"上传数据";
    [self configuerNavigationRightItem];
    [Utility configuerNavigationBackItem:self];
    [self.view addSubview:self.tableView];
    items = [[NSMutableArray alloc]init];
    factorArray = [[NSMutableArray alloc]init];
    mTestChemicalList = [[NSMutableArray alloc]init];
    
    if(_planModel !=nil && [_planModel.refid length]>0){
        self.did=_planModel.refid;
    }
    [self getUnit];
    [self getDisasterFactors];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardDidHideNotification object:nil];
    [self getPlanTaskList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UITableView DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return mTestChemicalList.count+self.dataArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    if (section <mTestChemicalList.count) {
         return 2;
    }
    NSArray *items = [self.dataArray objectAtIndex:section-mTestChemicalList.count];
    return items.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section ==mTestChemicalList.count) {
        UITableViewHeaderFooterView *header =[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
        if (!header) {
            header = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:@"header"];
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 45)];
            view.backgroundColor =[UIColor whiteColor];
            [header.contentView addSubview:view];
            
            
            UIImageView *iconView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 7, 30, 30)];
            iconView.image = [UIImage imageNamed:@"qrcode"];
            [header.contentView addSubview:iconView];
            
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 7, 120, 30)];
            titleLabel.font =[UIFont boldSystemFontOfSize:15];
            titleLabel.text = @"现场采样";
            [header.contentView addSubview:titleLabel];
            
                qrCodeLabel = [[UILabel alloc]initWithFrame:CGRectMake(140, 0, SCREEN_WIDTH-130, 45)];
                qrCodeLabel.numberOfLines = 2;
                [header.contentView addSubview:qrCodeLabel];
           
            
            UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 45)];
            [button addTarget:self action:@selector(showButtonAction:) forControlEvents:UIControlEventTouchUpInside ];
            button.tag = 0;
            [header.contentView addSubview:button];
            
            UIImageView *righticonView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-35, 9, 26, 26)];
            righticonView.image = [UIImage imageNamed:@"rightarrow"];
            [header.contentView addSubview:righticonView];
        }
        return header;
        
        
    }
    
    
    return nil;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section <mTestChemicalList.count) {
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@""];
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        InputBatchModel *model = mTestChemicalList[indexPath.section];
        if(indexPath.row==0){
            cell.textLabel.text = @"数值";
            
            UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(100, 0, SCREEN_WIDTH-120, 40)];
            textField.textAlignment = NSTextAlignmentRight;
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            textField.tag = indexPath.section;
            textField.delegate = self;
            [cell.contentView addSubview:textField];
            if(model.inptValue !=nil){
                textField.text = model.inptValue;
            }
            cell.accessoryType = UITableViewCellAccessoryNone;
        }else{
            cell.textLabel.text = @"单位";
            cell.detailTextLabel.text =model.unitName;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    TaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[TaskTableViewCell className]];
    if(cell == nil){
        cell = [[TaskTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[TaskTableViewCell className]];
    }
    NSArray *items = [self.dataArray objectAtIndex:indexPath.section-mTestChemicalList.count];
    [cell setCellInfoWith:[items objectAtIndex:indexPath.row]];
    return cell;
   
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section <mTestChemicalList.count) {
        InputBatchModel *model = [mTestChemicalList objectAtIndex:section];
        return model.name;
    }
    NSArray *items = [self.dataArray objectAtIndex:section-mTestChemicalList.count];
    PlantTaskModel *model = [items firstObject];
    return model.typename;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section ==mTestChemicalList.count) {
        return 75;
    }
    
    return 20;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
        return 10;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section <mTestChemicalList.count) {
        return 40;
    }
    NSArray *items = [self.dataArray objectAtIndex:indexPath.section-mTestChemicalList.count];
    PlantTaskModel *model = [items objectAtIndex:indexPath.row];
    if(model.anatype.count ==0){
        return 40;
    }else{
        return 20+model.anatype.count *25;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.view endEditing:YES];
    
    
    if (indexPath.section <mTestChemicalList.count) {
        unitIndex = indexPath.section;
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        SelectionTableViewController *targetVC = [story instantiateViewControllerWithIdentifier:@"SelectionTableViewController"];
        targetVC.selectionArray = _mUnitList;
        targetVC.isSpecial = @"0";
        targetVC.delegate = self;
        [self.navigationController pushViewController:targetVC animated:YES];
    }else{
        
        VocUploadDataViewController *uploadVC = [[VocUploadDataViewController alloc]init];
        NSArray *items = [self.dataArray objectAtIndex:indexPath.section-mTestChemicalList.count];
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
   
}
#pragma mark Delegate
-(NSMutableDictionary *)createSpecialInputbatch:(NSInteger)s refid1:(NSString *)r1 refid2:(NSString *)r2 remarks:(NSString *)rm{
    NSMutableDictionary *specDict = [[NSMutableDictionary alloc]init];
    [specDict setObject:[NSString stringWithFormat:@"%ld",(long)InputbatchTypeSpecial] forKey:@"type"];
    [specDict setObject:@"0" forKey:@"index"];
    
    NSMutableDictionary *contentDict = [[NSMutableDictionary alloc]init];
    [contentDict setObject:[NSString stringWithFormat:@"%ld", (long)s] forKey:@"specialtype"];
    if([r1 length]>0){
         [contentDict setObject:r1 forKey:@"refid1"];
    }
    
    if([r2 length]>0){
         [contentDict setObject:r2 forKey:@"refid2"];
    }
   
    [contentDict setObject:rm forKey:@"remarks"];
    
    [specDict setObject:contentDict forKey:@"contents"];
    
    return specDict;
}

-(void)checkBoxSelect:(NSArray *)dataArray{
    if(isFactor){
        [self factorAarraySelectItemWith:dataArray];
    }else{
        [self uploadDisaterNature: [self getSelectedNature:dataArray]];
    }
}

-(void)setSelectedValue:(NSString *)sid content:(NSString *)cont{
    NSLog(@"选择单位，结果%@",cont);
    InputBatchModel *model = mTestChemicalList[unitIndex];
    model.unitName = cont;
    model.unitId = sid;
    [self.tableView reloadData];
}

-(void)setWindsData:(NSString *)dict{
    NSLog(@"获取，风向风速为%@",dict);
    [self uploadWind:dict];
}

//选择因子完成后的代理
-(void)setDisasterChemical:(NSMutableDictionary *)dict{
   
    [self inputBatchAdd:dict];
    
}


-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSInteger index = textField.tag ;
    if(index<mTestChemicalList.count){
        InputBatchModel *modle = [mTestChemicalList objectAtIndex:index];
        modle.inptValue = textField.text;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}
#pragma mark QRCodeReader Delegate
/*
-(void)getQRCodeWithSting:(NSString *)code{
 
    NSString *oldCode = qrCodeLabel.text ;
    if([oldCode length]>0){
        oldCode = [NSString stringWithFormat:@"%@,%@",oldCode,code];
    }else{
        oldCode = code;
    }
    qrCodeLabel.text = oldCode;
    [self saveQRcode:oldCode];
}

-(void)saveQRcode:(NSString *)codeStr{
    InputBatchModel *model= [[InputBatchModel alloc]init];
    model.disasterid = self.did;
    model.staffid = [[NSUserDefaults standardUserDefaults] stringForKey:USERID] ;
    model.lng = [NSString stringWithFormat:@"%0.8f",[AppDelegate sharedInstance].location2D.longitude ];
    model.lat = [NSString stringWithFormat:@"%0.8f",[AppDelegate sharedInstance].location2D.latitude ];
    model.codeStr = codeStr;
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    NSString *localData = [[NSUserDefaults standardUserDefaults] valueForKey:@"codeData"];
    if(localData != nil){
        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:[localData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        for (NSDictionary *sub in dataArray) {
            InputBatchModel *model = [InputBatchModel modelWithDictionary:sub];
            [newArray addObject:model];
        }
    }
    [newArray addObject:model];
    [[NSUserDefaults standardUserDefaults] setValue:[newArray modelToJSONString] forKey:@"codeData"];
    
}*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma --mark 现场采样部分

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
//        count = array.count;
        self.dataArray=[[NSMutableArray alloc]initWithArray:[self getGroupArray:array]];
       
        [self.tableView reloadData];
       
    } onError:^(NSError *engineError) {
        
    }];
}

-(NSArray *)getGroupArray:(NSArray *)array{
    NSMutableArray *groupArray = [[NSMutableArray alloc]init];
    NSMutableArray *typeArray = [[NSMutableArray alloc]init];
    for (PlantTaskModel *subItem in array) {
        //循环去重复
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
-(BOOL)checkSunItemInArray:(NSArray *)array subItem:(NSString *)item{
    for (NSString *sub in array) {
        if([item isEqualToString:sub]){
            return YES;
        }
    }
    
    return NO;
}



@end
