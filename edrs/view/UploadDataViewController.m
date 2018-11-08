//
//  UploadDataViewController.m
//  edrs
//
//  Created by 余文君, July on 15/8/20.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "UploadDataViewController.h"
#import "ChemicalSearchViewController.h"
#import "UploadViewController.h"
@interface UploadDataViewController ()<BMKLocationServiceDelegate,ChemicalSearchDelegate>

@end

@implementation UploadDataViewController

-(void)getUnit{
    @weakify(self);
    [[AppDelegate sharedInstance].httpTaskManager getWithPortPath:EDRSHTTP_NUITMEASURE_GETUNIT parameters:nil onSucceeded:^(NSDictionary *dictionary) {
        @strongify(self);
        self.mUnitList = [dictionary valueForKey:@"list"];
        
    } onError:^(NSError *engineError) {
        
    }];
}
-(void)getFacors{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:self.did forKey:@"id"];
    @weakify(self);
    [[AppDelegate sharedInstance].httpTaskManager getWithPortPath:EDRSHTTP_GETDISASTER_DETAIL_FACTORS parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        @strongify(self);
        NSArray *list = [dictionary valueForKey:@"list"];
        for (int i = 0; i < [list count] ; i++) {
            [mTestChemicalList addObject:@{@"metricid":@"",
                                           @"metricname":@"",
                                           @"chemicalid":list[i][@"chemid"],
                                           @"factorId":list[i][@"id"],
                                           @"chemicalname":list[i][@"name"],
                                           @"unit":_mUnitList}];
        }
         [self.uploadDataTableView reloadData];
    
     } onError:^(NSError *engineError) {
         
     }];

}


/*
-(void)getChemicals{
    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@",EDRSHTTP, EDRSHTTP_GETDISASTER_DETAIL_CHEMICALS] params:@{@"disasterid":self.did} success:^(id responseObj) {
        if ([responseObj count]>0) {
            for (int i = 0; i < [responseObj count] ; i++) {
                @autoreleasepool {
                    [mTestChemicalList addObject:@{@"metricid":@"",
                                                   @"metricname":@"",
                                                   @"chemicalid":responseObj[i][@"chemical_id"],
                                                   @"chemicalname":responseObj[i][@"chemical_chinesename"],
                                                   @"unit":_mUnitList}];
                }
            }
            [self.uploadDataTableView reloadData];
        }
    } failure:^(NSError *err) {
        //
        NSLog(@"%@",[err description]);
    }];
}*/

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Utility configuerNavigationBackItem:self];
    
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc]initWithTitle:@"确定"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(submitData)];
    [submitButton setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = submitButton;
    
    //添加事故性质
    mNatureList = [[NSMutableArray alloc]init];
    [mNatureList addObject:@"大气事故"];
    [mNatureList addObject:@"水事故"];
    [mNatureList addObject:@"土事故"];
    
    
    if(_mLocation.latitude == 0 && _mLocation.longitude == 0){
        mLocationService = [[BMKLocationService alloc]init];
        mLocationService.delegate = self ;
        [mLocationService startUserLocationService];
    }
    
    //获取单位列表
//    mUnitList = [[NSMutableArray alloc]init];
//    mUnitList = [[NSMutableArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UnitList" ofType:@"plist"]];
    
    mSelectedNatureIndex = -1;
    mSelectedChemicalIndex = -1;
    mSelectedTestMethodIndex = -1;
    mSelectedTestEquipmentItemIndex = -1;
    mCurrentUnitValue = @"";
    mTestEquipmentItemList = [[NSMutableArray alloc]init];
    
    mShowNatureSelect = NO;
    mShowEquipmentSelect = NO;
    mShowEquipmentTestItems = NO;
    mShowTestResult = NO;
    
    //测试项目
    
   
    [self getUnit];
    
    
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    tapRec.delegate = self;
    [self.view addGestureRecognizer:tapRec];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self registerKeyboardNotification];
    if(mLocationService !=nil){
        mLocationService.delegate = nil;
        mLocationService.delegate = self;
    }
    if(mTestChemicalList !=nil){
        mTestChemicalList = nil;
    }
    mTestChemicalList = [[NSMutableArray alloc]init];
    [mTestChemicalList addObject: @{
                                    @"chemicalname":@"新增检测因子",
                                    }];
    [self performSelector:@selector(getFacors) withObject:nil afterDelay:0.2];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(mLocationService !=nil){
        [mLocationService stopUserLocationService];
        mLocationService.delegate = nil;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)dealloc{
    NSLog(@"dealloc");
}


#pragma mark - location delegate
-(void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    _mLocation.longitude = userLocation.location.coordinate.longitude;
    _mLocation.latitude = userLocation.location.coordinate.latitude;
    NSLog(@"bd lat = %f, lng = %f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    
}

-(void)didFailToLocateUserWithError:(NSError *)error{
    if ([error code] == kCLErrorDenied || [error code] == kCLErrorLocationUnknown) {
        [CustomUtil showMBProgressHUD:@"无法定位，请开启定位后重试" view:self.view animated:YES];
    }
}

#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 6;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return mTestChemicalList.count;
            break;
        case 1:
            if(mShowNatureSelect){
                return 3;
            }
            else{
                return 0;
            }
            break;
        case 2:
            return mTestMethodList.count;
            break;
        case 3:
            if (mShowEquipmentSelect) {
                return 1;
            }
            else{
                return 0;
            }
            break;
        case 4:
            if (mShowEquipmentTestItems) {
                if (mTestEquipmentItemList.count>0) {
                    return mTestEquipmentItemList.count;
                }
                else{
                    return 1;
                }
            }
            else{
                return 0;
            }
            break;
        case 5:
            if(mShowTestResult) {
                return 2;
            }
            else{
                return 0;
            }
            break;
        default:
            return 0;
            break;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 1:
            if(mShowNatureSelect){
                return 44.0f;
            }
            else{
                return 0.1f;
            }
            break;
        case 2:
            if (mTestMethodList.count > 0) {
                return 44.0f;
            }
            else{
                return 0.1f;
            }
            break;
        case 3:
            if (mShowEquipmentSelect) {
                return 44.0f;
            }
            else{
                return 0.1f;
            }
            break;
        case 4:
            if (mShowEquipmentTestItems) {
                return 44.0f;
            }
            else{
                return 0.1f;
            }
            break;
        case 5:
            if (mShowTestResult) {
                return 44.0f;
            }
            else{
                return 0.1f;
            }
            break;
        default:
            return 44.0f;
            break;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 30, 44)];
    [label setText:@""];
    
    switch (section) {
        case 0:
            [label setText:@"测试项目"];
            break;
        case 1:
            if (mShowNatureSelect) {
                [label setText:@"事故性质"];
            }
            break;
        case 2:
            if (mTestMethodList.count > 0) {
                [label setText:@"测试方法"];
            }
            break;
        case 3:
            if (mShowEquipmentSelect) {
                [label setText:@"使用设备"];
            }
            break;
        case 4:
            if(mShowEquipmentTestItems){
                [label setText:@"设备可测试项目"];
            }
            break;
        case 5:
            if (mShowTestResult) {
                [label setText:@"测试结果"];
            }
            break;
        default:
            break;
    }
    [view addSubview:label];
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifierCommon = @"UploadDataTableViewCell";
    NSString *cellIdentifierTest = @"UploadDataTableViewTestMethodCell";
    NSString *cellIdentifierResult = @"UploadDataTableViewResultCell";
    
    UITableViewCell *cellCommon = [tableView dequeueReusableCellWithIdentifier:cellIdentifierCommon];
    UITableViewCell *cellTestMethod = [tableView dequeueReusableCellWithIdentifier:cellIdentifierTest];
    UITableViewCell *cellResult = [tableView dequeueReusableCellWithIdentifier:cellIdentifierResult];
    
    if (cellCommon == nil) {
        cellCommon = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierCommon];
    }
    if(cellTestMethod == nil){
        cellTestMethod = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierTest];
    }
    else{
        while ([[cellTestMethod.contentView subviews] lastObject]) {
            [[[cellTestMethod.contentView subviews] lastObject] removeFromSuperview];
        }
    }
    if(cellResult == nil){
        cellResult = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierResult];
    }
    else{
        if (cellResult.contentView.subviews.count == 2) {
            [[cellResult.contentView.subviews lastObject] removeFromSuperview];
        }
    }
    
    [cellCommon setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellResult setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cellTestMethod setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    switch (indexPath.section) {
        case 0:{
            if(indexPath.row < mTestChemicalList.count){
                [cellCommon.textLabel setText:mTestChemicalList[indexPath.row][@"chemicalname"]];
            }
            if (mSelectedChemicalIndex == indexPath.row) {
                [cellCommon setAccessoryType:UITableViewCellAccessoryCheckmark];
            }
            else{
                [cellCommon setAccessoryType:UITableViewCellAccessoryNone];
            }
            return cellCommon;
        }
            break;
        case 1:{
            [cellCommon.textLabel setText:mNatureList[indexPath.row]];
            if (mSelectedNatureIndex == indexPath.row) {
                [cellCommon setAccessoryType:UITableViewCellAccessoryCheckmark];
            }
            else{
                [cellCommon setAccessoryType:UITableViewCellAccessoryNone];
            }
            return cellCommon;
        }
            break;
        case 2:{
            if (mTestMethodList > 0) {
                
                UILabel *statelabel = [[UILabel alloc]initWithFrame:CGRectMake(cellTestMethod.frame.size.width - 64 - 44, 8 ,64, cellTestMethod.frame.size.height - 16)];
                [statelabel setText:@"已测试"];
                [statelabel setBackgroundColor:BLUE_COLOR];
                [statelabel setTextColor:[UIColor whiteColor]];
                [statelabel setTextAlignment:NSTextAlignmentCenter];
                [statelabel setFont:[UIFont systemFontOfSize:14.0f]];
                [statelabel.layer setMasksToBounds:YES];
                [statelabel.layer setCornerRadius:14];
                CGRect frame = statelabel.frame;
                
                if ([mTestMethodList[indexPath.row][@"tested"] boolValue] == YES) {
                    frame.size.width = 64;
                    [statelabel setFrame:frame];
                }
                else{
                    frame.size.width = 0;
                    [statelabel setFrame:frame];
                }
                [cellTestMethod.contentView addSubview:statelabel];
                
                UILabel *titlelabel = [[UILabel alloc]initWithFrame:CGRectMake(14, 0, cellTestMethod.frame.size.width - 44 - statelabel.frame.size.width - 10 - 14, cellTestMethod.frame.size.height)];
                [titlelabel setText:mTestMethodList[indexPath.row][@"name"]];
                [cellTestMethod.contentView addSubview:titlelabel];
                
                if(mSelectedTestMethodIndex == indexPath.row){
                    [cellTestMethod setAccessoryType:UITableViewCellAccessoryCheckmark];
                }
                else{
                    [cellTestMethod setAccessoryType:UITableViewCellAccessoryNone];
                }
                
            }
            return cellTestMethod;
        }
            break;
        case 3:{
            if (mSelectedEquipment[@"name"]) {
                [cellCommon.textLabel setText:mSelectedEquipment[@"name"]];
            }
            else{
                [cellCommon.textLabel setText:@"请选择"];
            }
            [cellCommon setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            return cellCommon;
        }
            break;
        case 4:{
            if (mTestEquipmentItemList.count > 0) {
                [cellCommon.textLabel setText:mTestEquipmentItemList[indexPath.row][@"metricname"]];
                if (mSelectedTestEquipmentItemIndex == indexPath.row) {
                    [cellCommon setAccessoryType:UITableViewCellAccessoryCheckmark];
                }
                else{
                    [cellCommon setAccessoryType:UITableViewCellAccessoryNone];
                }
            }
            else{
                [cellCommon.textLabel setText:@"无任何测试项目"];
            }
            return cellCommon;
        }
            break;
        case 5:{
            //单位选择
            if(mSelectedChemicalIndex != -1 && mSelectedEquipment){
                if (indexPath.row == 0) {
                    [cellResult.textLabel setText:@"数值"];
                    UITextField *textfield = [[UITextField alloc]initWithFrame:CGRectMake(100, 0, self.view.frame.size.width - 100- 30, 44)];
                    [textfield setKeyboardType:UIKeyboardTypeDecimalPad];
                    [cellResult.contentView addSubview:textfield];
                    mTestResultTextField = textfield;
                    mTestResultTextField.delegate = self;
                    if ([mCurrentUnitValue isEqualToString:@""]) {
                        [mTestResultTextField setText:@""];
                    }
                    else{
                        [mTestResultTextField setText:mCurrentUnitValue];
                    }
                    [cellResult setAccessoryType:UITableViewCellAccessoryNone];
                }
                else{
                    [cellResult.textLabel setText:@"单位"];
                    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(100, 0, 200, 44)];
                    [label setTextColor:[UIColor lightGrayColor]];
    
                    if (_mUnitList.count > 0) {
                        if ([mCurrentUnit isEqualToString:@""]) {
                            mCurrentUnit = _mUnitList[0][@"name"];
                        }
                        
                        if (_mUnitList.count > 1) {
                            [cellResult setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                        }
                        else{
                            [cellResult setAccessoryType:UITableViewCellAccessoryNone];
                        }
                        
                        [label setText:mCurrentUnit];
                    }
                    else{
                        [label setText:@""];
                    }

                    [cellResult.contentView addSubview:label];
                }
            }
            else{
                [cellResult.textLabel setText:@"请先选择测试设备和化学品"];
                [cellResult setAccessoryType:UITableViewCellAccessoryNone];
            }
        }
            break;
        default:
            break;
    }
    
    switch (indexPath.section) {
        case 0:
        case 1:
        case 3:
        case 4:
            return cellCommon;
            break;
        case 2:
            return cellTestMethod;
            break;
        case 5:
            return cellResult;
        default:
            return nil;
            break;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self hideKeyboard];
    
    switch (indexPath.section) {
        case 0:{
            
            if(indexPath.row ==0){
                UIStoryboard *story=[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                ChemicalSearchViewController *chemicalVC =[story instantiateViewControllerWithIdentifier:@"ChemicalSearchViewController"];            chemicalVC.delegate = self;
                [self.navigationController pushViewController:chemicalVC animated:YES];
            }else{
                mSelectedChemicalIndex = indexPath.row;
                mSelectedNatureIndex = -1;
                mSelectedTestEquipmentItemIndex = -1;
                mSelectedTestMethodIndex = -1;
                
                mTestMethodList = nil;
                [mSelectedEquipment removeAllObjects];
                mShowNatureSelect = YES;
                mShowEquipmentSelect = NO;
                mShowEquipmentTestItems = NO;
                mShowTestResult = NO;
                
                [self.uploadDataTableView reloadData];
            }
           
        }
            break;
        case 1:{
            mSelectedNatureIndex = indexPath.row;
            
            mCurrentUnit = @"";
            if (mTestChemicalList.count > 0 && mSelectedChemicalIndex < mTestChemicalList.count) {
                mShowEquipmentTestItems = NO;
               
              
                NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
                [parameters setValue:self.did forKey:@"disasterid"];
                
                [parameters setValue:mTestChemicalList[mSelectedChemicalIndex][@"chemicalid"] forKey:@"chemid"];
            
                [parameters setValue:[NSNumber numberWithInteger:mSelectedNatureIndex] forKey:@"sampletype"];
                
                [[AppDelegate sharedInstance].httpTaskManager postWithPortPath: GET_TESTMETHOD_SEQUENCE parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
                    NSArray *list = [dictionary valueForKey:@"list"];
                    if([list count] > 0){
                        mTestMethodList = list;
                      
                        mSelectedTestMethodIndex = -1;
                    }
                    else{
                                              [mSelectedEquipment removeAllObjects];
                        mShowEquipmentSelect = YES;
                    }
                    [self.uploadDataTableView reloadData];
                } onError:^(NSError *engineError) {
                    
                }];
                
            }
            else{
                //选择了其他，请其选择设备
                mShowEquipmentSelect = YES;
              
                mCurrentUnit = nil;
               
                
                if (mSelectedEquipment[@"id"]) {
                    [self getEquipmentDetail:mSelectedEquipment];
                }
                else{
                    [self.uploadDataTableView reloadData];
                }
            }
        }
            break;
        case 2:{
            mShowEquipmentSelect = YES;
            
            mSelectedTestMethodIndex = indexPath.row;
            if(!mSelectedEquipment){
                mSelectedEquipment = [[NSMutableDictionary alloc]init];
            }
            else{
                [mSelectedEquipment removeAllObjects];
            }
             [self.uploadDataTableView reloadData];
//            if (![mTestMethodList[mSelectedTestMethodIndex][@"eqclass"] isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
//                NSLog(@"%d",!mEquipmentList);
//                if (!mEquipmentList) {
//                    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@", EDRSHTTP, EDRSHTTP_GETEQUIPMENT_PAGE] params:@{} success:^(id responseObj) {
//                        NSLog(@"get the equipment detail successfully, response = %@", responseObj);
//                        mEquipmentList = responseObj;
//                        for (int i = 0; i< [responseObj count]; i++) {
//                            if ([responseObj[i][@"eqclass"] isEqualToString:mTestMethodList[mSelectedTestMethodIndex][@"eqclass"]]) {
//                                [mSelectedEquipment setObject:responseObj[i][@"id"] forKey:@"id"];
//                                [mSelectedEquipment setObject:responseObj[i][@"name"] forKey:@"name"];
//                                mShowTestResult = YES;
//                                break;
//                            }
//                        }
//                        [self.uploadDataTableView reloadData];
//                    } failure:^(NSError *err) {
//                        NSLog(@"fail to get equipment list , error = %@", err);
//                    }];
//                }
//                else{
//                    for (int i = 0; i< [mEquipmentList count]; i++) {
//                        NSLog(@"%@",mEquipmentList[i][@"eqclass"]);
//                        NSLog(@"eqclass =%@",mTestMethodList[mSelectedTestMethodIndex][@"eqclass"]);
//                        if ([mEquipmentList[i][@"eqclass"] isEqualToString:mTestMethodList[mSelectedTestMethodIndex][@"eqclass"]]) {
//                            [mSelectedEquipment setObject:mEquipmentList[i][@"id"] forKey:@"id"];
//                            [mSelectedEquipment setObject:mEquipmentList[i][@"name"] forKey:@"name"];
//                            mShowTestResult = YES;
//                            break;
//                        }
//                    }
//                    [self.uploadDataTableView reloadData];
//                }
//            }
//            else{
//                [self.uploadDataTableView reloadData];
//            }
        }
            break;
        case 3:{
            //进入设备选择页面
            [self performSegueWithIdentifier:@"EquipmentSelectSegue" sender:nil];
        }
            break;
        case 4:{
            if (mTestEquipmentItemList.count > 0) {
                mSelectedTestEquipmentItemIndex = indexPath.row;
                mCurrentUnit = @"";
                [self.uploadDataTableView reloadData];
            }
        }
            break;
        case 5:{
            if (indexPath.row == 1 && [_mUnitList count] > 1) {
                [self performSegueWithIdentifier:@"UnitSelectSegue" sender:nil];
            }
            else{
                return;
            }
        }
            break;
        default:
            break;
    }
}
-(void)refreshTableSection:(NSInteger)sectionindex{
    NSIndexSet *nd = [[NSIndexSet alloc]initWithIndex:sectionindex];
    [self.uploadDataTableView reloadSections:nd withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - 键盘事件
-(void)registerKeyboardNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
}
-(void)keyboardWasShown:(NSNotification *)noti{
    NSDictionary *info = [noti userInfo];
    CGSize kbsize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect tableFrame = self.uploadDataTableView.frame;
    CGFloat offset = self.view.frame.size.height - tableFrame.origin.y - tableFrame.size.height - kbsize.height;
    
    NSTimeInterval animationDuration = 0.3;
    [UIView beginAnimations:@"ResizeKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    if (offset < 0) {
        self.view.frame = CGRectMake(0, offset, SCREEN_WIDTH, SCREEN_HEIGHT);
    }
    
    [UIView commitAnimations];
}
-(void)keyboardWasHidden:(NSNotification *)noti{
    self.view.frame = CGRectMake(0, 0,SCREEN_WIDTH, SCREEN_HEIGHT);
}
-(void)hideKeyboard{
    [mTestResultTextField resignFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self hideKeyboard];
    return YES;
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    else{
        return YES;
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    mCurrentUnitValue = textField.text;
}

#pragma mark - 跳转
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"EquipmentSelectSegue"]) {
        EquipmentSelectViewController *targetVC = segue.destinationViewController;
        targetVC.selcetedEquipment = mSelectedEquipment;
        targetVC.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"UnitSelectSegue"]){
        SelectionTableViewController *targetVC = segue.destinationViewController;
        targetVC.selectionArray = _mUnitList;
        targetVC.isSpecial = @"0";
        targetVC.delegate = self;
    }
}

#pragma mark - 提交数据到上一个页面

-(void)submitData{
    [mTestResultTextField endEditing:YES];
    
    
    if(mSelectedChemicalIndex == -1){
         [CustomUtil showMBProgressHUD:@"请填写完整数据" view:self.view animated:YES];
        return ;
    }else{
        [MBProgressHUD showHUDAddedTo:self.view
                             animated:YES];
    }
   
    NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]init];
    [tmpDict setValue:self.did forKey:@"disasterid"];
    [tmpDict setValue:[[NSUserDefaults standardUserDefaults] stringForKey:USERID] forKey:@"staffid"];
    [tmpDict setValue:[NSString stringWithFormat:@"%0.8f",_mLocation.longitude ] forKey:@"lng"];
    [tmpDict setValue:[NSString stringWithFormat:@"%0.8f",_mLocation.latitude ] forKey:@"lat"];
    
    if(mSelectedEquipment[@"id"]!=nil){
        [tmpDict setObject:mSelectedEquipment[@"id"] forKey:@"equipment"];
        [tmpDict setObject:mSelectedEquipment[@"name"] forKey:@"equipmentname"];
    }
    
    
    
    
    if (mSelectedChemicalIndex < mTestChemicalList.count) {
         if(mSelectedChemicalIndex != -1){
             
            [tmpDict setObject:mTestChemicalList[mSelectedChemicalIndex][@"factorId"] forKey:@"chemical"];
            [tmpDict setObject:mTestChemicalList[mSelectedChemicalIndex][@"chemicalname"] forKey:@"chemicalname"];
            
            [tmpDict setObject:mTestChemicalList[mSelectedChemicalIndex][@"metricid"] forKey:@"metricid"];
            NSString *metric = mTestChemicalList[mSelectedChemicalIndex][@"metricname"];
             if(metric.length !=0){
                 [tmpDict setObject:metric forKey:@"metric"];
             }else{
                 [tmpDict setObject:@"865861EA-49D6-4E8D-ABBC-5AEEE855691C" forKey:@"metric"];
             }
         }
       
       
        if (mTestMethodList == nil || mTestMethodList.count <= 0) {
            [tmpDict setObject:@"" forKey:@"testmethod"];
        }
        else{
            [tmpDict setObject:mTestMethodList[mSelectedTestMethodIndex][@"id"] forKey:@"testmethod"];
        }
    }
//    else{
//        if(mSelectedTestEquipmentItemIndex !=-1){
//            [tmpDict setObject:mTestEquipmentItemList[mSelectedTestEquipmentItemIndex][@"id"] forKey:@"chemical"];
//            [tmpDict setObject:mTestEquipmentItemList[mSelectedTestEquipmentItemIndex][@"chemicalname"] forKey:@"chemicalname"];
//            
//            [tmpDict setObject:mTestEquipmentItemList[mSelectedTestEquipmentItemIndex][@"metricid"] forKey:@"metricid"];
//            NSString *metric = mTestChemicalList[mSelectedChemicalIndex][@"metricname"];
//            if(metric.length !=0){
//                [tmpDict setObject:metric forKey:@"metric"];
//            }else{
//                [tmpDict setObject:@"865861EA-49D6-4E8D-ABBC-5AEEE855691C" forKey:@"metric"];
//            }
//        }else{
//             [tmpDict setObject:@"865861EA-49D6-4E8D-ABBC-5AEEE855691C" forKey:@"metric"];
//        }
//      
//        [tmpDict setObject:@"" forKey:@"testmethod"];
//    }
    
    if(mCurrentUnitID!=nil){
        [tmpDict setObject:mCurrentUnitID forKey:@"unitid"];
        
    }
    if(![mCurrentUnitValue isEqualToString:@""]){
        [tmpDict setObject:mCurrentUnitValue forKey:@"value"];
    }
    
    if(mSelectedChemicalIndex != -1){
        [tmpDict setObject:[NSString stringWithFormat:@"%ld",(long)mSelectedNatureIndex] forKey:@"nature"];
    }
    
    [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@",EDRSHTTP, EDRSHTTP_GETDISASTER_DETAIL_SET_CHEMICALS] params:tmpDict success:^(id responseObj) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if([[responseObj valueForKey:@"success"] intValue]==1){
            [CustomUtil showMBProgressHUD:@"上传成功" view:self.view animated:YES];
        }else{
            [CustomUtil showMBProgressHUD:@"请填写完整数据" view:self.view animated:YES];
        }
        NSLog(@"%@",responseObj);
    } failure:^(NSError *err) {
        //
         [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"%@",[err description]);
    }];

}

#pragma mark - 委托实现
-(void)setSelectedEquipment:(NSMutableDictionary *)edict{
    NSLog(@"委托回调结果：%@",edict[@"id"]);
    NSLog(@"委托回调结果：%@",edict[@"name"]);
    mSelectedEquipment = edict;
    [self getEquipmentDetail:edict];
}

-(void)setSelectedValue:(NSString *)sid content:(NSString *)cont{
    NSLog(@"选择单位，结果%@",cont);
    mCurrentUnitID = sid;
    mCurrentUnit = cont;
    [self.uploadDataTableView reloadData];
}
-(void)setDisasterChemical:(NSMutableDictionary *)dict{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewChemical" object:dict];
}
#pragma mark - 获取equipmentdetail处理
-(void)getEquipmentDetail:(NSMutableDictionary *)edict{
    //if(mSelectedChemicalIndex < mTestChemicalList.count && mSelectedChemicalIndex != -1 && mTestMethodList.count > 0){
    mSelectedTestEquipmentItemIndex = -1;
    
    if(mSelectedChemicalIndex < mTestChemicalList.count && mSelectedChemicalIndex != -1){
        mShowEquipmentTestItems = NO;
        mShowTestResult = YES;
        [self.uploadDataTableView reloadData];
    }
    else{
        mShowEquipmentTestItems = YES;
        mShowTestResult = YES;
        [mTestEquipmentItemList removeAllObjects];
        
    }
}

@end
