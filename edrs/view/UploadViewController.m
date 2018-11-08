//
//  UploadViewController.m
//  edrs
//
//  Created by 余文君, July on 15/8/20.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "UploadViewController.h"
#import "CheckBoxViewController.h"
#import "SelectDataModel.h"
#import "PollutionMapViewController.h"
#import "ChemicalSearchViewController.h"
#import "WindsViewController.h"
#import "PollutionsViewController.h"
#import "InputBatchModel.h"
#import "UploadViewController2.h"
@interface UploadViewController () <CheckBoxViewControllerDelegate,PollutionMapDelegate,ChemicalSearchDelegate,WindsDataDelegate,UITableViewDataSource,UITableViewDelegate>{
    NSString *selectedNature;
    NSMutableArray *uploadArray;
    BOOL isBig;
}

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,weak) IBOutlet NSLayoutConstraint *topMargin;
@end

@implementation UploadViewController
/*
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
    NSString *name ;
    NSString *idStr ;
    for (NSInteger i = 0; i<dataArray.count; i++) {
        SelectDataModel *sub = [dataArray objectAtIndex:i];
        if(sub.state){
            if(name==nil){
                name = sub.name;
            }else{
                name = [NSString stringWithFormat:@"%@,%@",name,sub.name];
            }
            
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
    
    
    selectedNature = idStr;
    return name;
}

-(void)topItemClicked:(id)sender{
    UIButton *button = (UIButton *)sender;
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];

    switch (button.tag) {
        case 0:{
           
            CheckBoxViewController *checkBoxVC = [[CheckBoxViewController alloc]init];
            checkBoxVC.dataArray = [self getGudingji];
            checkBoxVC.delegate  =self ;
            checkBoxVC.titleName = @"事故性质";
            [self addChildViewController:checkBoxVC];
            [self.view addSubview:checkBoxVC.view];
            break;
        }
        case 1:{
            
            PollutionMapViewController *vc = [story instantiateViewControllerWithIdentifier:@"PollutionMapViewController"];
            vc.delegate = self;
            vc.disasterid = self.did;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
            
        case 2:{
            ChemicalSearchViewController *chemicalVC =[story instantiateViewControllerWithIdentifier:@"ChemicalSearchViewController"];            chemicalVC.delegate = self;
            [self.navigationController pushViewController:chemicalVC animated:YES];
            break;
        }
        
        case 3:{
            WindsViewController *windsVC = [story instantiateViewControllerWithIdentifier:@"WindsViewController"];  
            windsVC.delegate = self;
            [self.navigationController pushViewController:windsVC animated:YES];
        }
        default:
            break;
    }
}

#pragma select Delegate
-(void)checkBoxSelect:(NSArray *)dataArray{
    [self getSelectedNature:dataArray];
    NSMutableDictionary *tmpdict = [self createSpecialInputbatch:SpecialInputTypeDisasterNatureIdentified refid1:@"" refid2:@"" remarks:selectedNature];
    [self updateInputbatch:tmpdict];
    NSInteger index = mUploadList.count - 1;
    [self actionAddInputbatch:index];
}


#pragma mark Uview
-(UIView *)topView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 30, SCREEN_WIDTH, 50)];
    NSArray *images = @[@"shandian",@"zuobiao",@"huaxuepin",@"fengxiang"];
    NSArray *titles = @[@"事故性质",@"事故坐标",@"检测因子",@"风速风向"];
    NSInteger padding = (SCREEN_WIDTH-70*4)/5;
    for (NSInteger i = 0; i<images.count; i++) {
        UIView *iconView = [[UIView alloc]initWithFrame:CGRectMake(padding+(70+padding)*i, 0, 70, 50)];
        
        UIImageView *imageView =[[UIImageView alloc]initWithFrame:CGRectMake(20, 0, 30, 30)];
        imageView.image = [UIImage imageNamed:images[i]];
        [iconView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, iconView.width, 20)];
        label.text = [titles objectAtIndex:i];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentCenter;
        [iconView addSubview:label];
        
        UIButton *button = [[UIButton alloc]initWithFrame:iconView.bounds];
        button.tag = i;
        [button addTarget:self action:@selector(topItemClicked:) forControlEvents:UIControlEventTouchUpInside];
        [iconView addSubview:button];
       
        
        [view addSubview:iconView];
    }
    
    return view;
}*/
-(void)submitData:(InputBatchModel *)model{
    [self.view endEditing:YES];
    
    NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]init];
    [tmpDict setValue:model.disasterid forKey:@"disasterid"];
    [tmpDict setValue:model.staffid forKey:@"staffid"];
    [tmpDict setValue:model.lng forKey:@"lng"];
    [tmpDict setValue:model.lat forKey:@"lat"];
    
    [tmpDict setObject:model.id forKey:@"chemical"];
    [tmpDict setObject:model.name forKey:@"chemicalname"];
    [tmpDict setObject:model.unitId forKey:@"unitid"];
    [tmpDict setObject:model.inptValue forKey:@"value"];
    [tmpDict setObject:model.nature forKey:@"nature"];
    
    
    
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

-(void)topButtonClickedAction:(id)sender{
    UIButton *topButton = (UIButton *)sender;
    isBig= !isBig;
    if(isBig){
        _tableView.scrollEnabled = YES;
        [UIView animateWithDuration:0.1 animations:^{
            self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) ;
        }];
        
         [topButton setImage:[UIImage imageNamed:@"moreup"] forState:UIControlStateNormal];
    }else{
       _tableView.scrollEnabled = NO;
        [UIView animateWithDuration:0.1 animations:^{
             self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 200) ;
        }];
         [topButton setImage:[UIImage imageNamed:@"moredown"] forState:UIControlStateNormal];
    }
    [self.tableView reloadData];
}

-(void)sendButtonAction:(id)sender{
    for (InputBatchModel *sub in uploadArray) {
        [self submitData:sub];
    }
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"locationData"];
    [self setFrameOffTableView];
    
}

-(UIView *)tableTopView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 300, 20)];
    label.text = @"本地保存数据";
    [view addSubview:label];
    
    UIButton *topButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-60, 10, 30, 30)];
    [topButton addTarget:self action:@selector(topButtonClickedAction:) forControlEvents:UIControlEventTouchUpInside];
    [topButton setImage:[UIImage imageNamed:@"moredown"] forState:UIControlStateNormal];
    [view addSubview:topButton];
    return view;
}

-(UIView *)tableBottomView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    UIButton *topButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-60, 10, 30, 30)];
    [topButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [topButton setImage:[UIImage imageNamed:@"send"] forState:UIControlStateNormal];
    [view addSubview:topButton];
    return view;
}

-(UITableView *)tableView{
    if(_tableView ==nil){
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,200)];
        _tableView.delegate = self;
        _tableView.dataSource =self;
        _tableView.tableHeaderView = [self tableTopView];
        _tableView.tableFooterView = [self tableBottomView];
        _tableView.scrollEnabled =NO;
    }
    
    return _tableView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [Utility configuerNavigationBackItem:self];
//    [self.view addSubview:[self topView]];
    mOffsetYBlockInScrollView = 0;
    mUploadList = [[NSMutableArray alloc]init];
    mUploadCellList = [[NSMutableArray alloc]init];
    mUploadCellHeight = [[NSMutableArray alloc]init];
    mWaitingUploadImages = [[NSMutableDictionary alloc]init];
    mWaitingUploadVoices = [[NSMutableArray alloc]init];
    mUploadTextField = [self createTextField];
    [self.uploadToolbar addSubview:mUploadTextField];
    mStaffId = [[NSUserDefaults standardUserDefaults] stringForKey:USERID];
    _locationLabel.text = _locationStr;
//    //定位创建

    //原生定位
    mLocationManager = [[CLLocationManager alloc]init];
    mLocationManager.delegate = self;
    mLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [mLocationManager requestWhenInUseAuthorization];
    [mLocationManager startUpdatingLocation];
//
    uploadArray = [[NSMutableArray alloc]init];
    mUploadList = [self readUploadList:self.did];
    [self initScrollView];
    [self registerForKeyboardNotifications];
   
   

}

-(void)setFrameOffTableView{
    NSString *localData = [[NSUserDefaults standardUserDefaults] valueForKey:@"locationData"];
    [self.tableView removeFromSuperview];
    [uploadArray removeAllObjects];
    
    if(localData !=nil){
        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:[localData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
       
        for (NSDictionary *sub in dataArray) {
            InputBatchModel *model = [InputBatchModel modelWithDictionary:sub];
            [uploadArray addObject:model];
        }
        
        if(uploadArray.count>0){
            isBig =NO;
            
            self.topMargin.constant = 200;
            
            [self.view addSubview:self.tableView];
            [self.tableView reloadData];
        }
    }else{
        self.topMargin.constant = 0;
    }

}
-(void)viewWillAppear:(BOOL)animated{
    [self setFrameOffTableView];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    mLocationManager.delegate = nil;
    mLocationManager.delegate = self;
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
 
    [self.view endEditing:YES];
    [mLocationManager stopUpdatingLocation];
    mLocationManager.delegate = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    NSLog(@"dealloc");
}

#pragma mark - 创建文本输入框
-(UITextField *)createTextField{
    UITextField *textfield = [[UITextField alloc]initWithFrame:CGRectMake(98, 6, self.view.frame.size.width - 98 - 98, 32)];
    [textfield setBorderStyle:UITextBorderStyleRoundedRect];
    [textfield setBackgroundColor:[UIColor whiteColor]];
    [textfield setReturnKeyType:UIReturnKeyDone];
    textfield.delegate = self;
    return textfield;
}

#pragma mark - keyboard about & textfield edit end
-(void)registerForKeyboardNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)keyboardWillShow:(NSNotification *)noti{
    //键盘出现，计算高度大小
    NSDictionary *info = [noti userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSInteger keyboardhight= 216;
   
    //输入框位置动画加载
   
    NSTimeInterval animationDuration = 0.1;
    [UIView beginAnimations:@"ResizeForkeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
   
    self.view.frame = CGRectMake(0, -keyboardhight, self.view.frame.size.width, self.view.frame.size.height);
    
    
    [UIView commitAnimations];
    
}
-(void)keyboardWillHide:(NSNotification *)noti{
    NSTimeInterval animationDuration = 0.15;
    [UIView beginAnimations:@"Restorekeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}
-(void)hideKeyboard{
    [mUploadTextField resignFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textfield text = %@", textField.text);
    if (textField.text.length > 0) {
        
        //创建一个text detail
        NSMutableDictionary *dict = [self createTextInputbatch:textField.text];
        [self updateInputbatch:dict];
        
        [mUploadTextField setText:@""];
    }
    
    [self hideKeyboard];
    return YES;
}

#pragma mark - location delegate 

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations{
    if(locations.count>0){
        CLLocation *newlocation = locations[0];
        mLocationCoor.longitude = newlocation.coordinate.longitude;
        mLocationCoor.latitude = newlocation.coordinate.latitude;
        NSLog(@"bd lat = %f, lng = %f", newlocation.coordinate.latitude, newlocation.coordinate.longitude);

        [self.locationLabel setText:[NSString stringWithFormat:@"%0.04fE , %0.04fN",
                                        newlocation.coordinate.longitude,
                                        newlocation.coordinate.latitude]];
    }

}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{

}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    if ([error code] == kCLErrorDenied || [error code] == kCLErrorLocationUnknown) {
        [CustomUtil showMBProgressHUD:@"无法定位，请开启定位后重试" view:self.view animated:YES];
    }

}

/*
-(void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    mLocationCoor.longitude = userLocation.location.coordinate.longitude;
    mLocationCoor.latitude = userLocation.location.coordinate.latitude;
    NSLog(@"bd lat = %f, lng = %f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    
    [self.locationLabel setText:[NSString stringWithFormat:@"%0.04fE , %0.04fN",
                                 round(userLocation.location.coordinate.longitude*100)/100,
                                 round(userLocation.location.coordinate.latitude*100)/100]];
    
}

-(void)didFailToLocateUserWithError:(NSError *)error{
    if ([error code] == kCLErrorDenied || [error code] == kCLErrorLocationUnknown) {
        [CustomUtil showMBProgressHUD:@"无法定位，请开启定位后重试" view:self.view animated:YES];
    }
}*/

/*
-(void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    NSLog(@"current result address = %@", result.address);
    
    //上传污染源定位
    NSMutableDictionary *tmpdict = [self createSpecialInputbatch:SpecialInputTypeDisasterLocationPinpointed refid1:@"" refid2:@"" remarks:[NSString stringWithFormat:@"%f,%f_$%@",result.location.longitude, result.location.latitude, result.address]];
    [self updateInputbatch:tmpdict];
    NSInteger index = 0;
    if(mUploadList.count > 0){
        index = mUploadList.count - 1;
    }
    [self actionAddInputbatch:index];
}*/

//-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
//    CLLocation *curLocation = [locations lastObject];
//    NSLog(@"lat = %f, lng = %f", curLocation.coordinate.latitude, curLocation.coordinate.longitude);
//}
//-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
//    if ([error code] == kCLErrorDenied || [error code] == kCLErrorLocationUnknown) {
//        [CustomUtil showMBProgressHUD:@"无法定位，请开启定位后重试" view:self.view animated:YES];
//    }
//}

#pragma mark - tableview delegate

#pragma mark UITableView DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(uploadArray.count>0){
        if(isBig){
            return uploadArray.count;
        }else{
            return 1;
        }
    }else{
        return 0;
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@""];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    InputBatchModel *model = uploadArray[indexPath.section];
    if(indexPath.row==0){
        cell.textLabel.text = @"数值";
        
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(100, 0, SCREEN_WIDTH-120, 40)];
        textField.textAlignment = NSTextAlignmentRight;
        textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        textField.tag = indexPath.section;
        textField.delegate = self;
        [cell.contentView addSubview:textField];
        textField.userInteractionEnabled = NO;
        textField.text = model.inptValue;

        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        cell.textLabel.text = @"单位";
        cell.detailTextLabel.text =model.unitName;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(uploadArray.count>0){
    InputBatchModel *model = [uploadArray objectAtIndex:section];
    return model.name;
    }else{
        return nil;
    }
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 10;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return 1;
//}
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return mUploadList.count;
//}
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
//    return [[[[cell contentView] subviews] lastObject] frame].size.height + MARGIN;
//}
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    NSString *identifier = @"uploadTableViewCellIdentifier";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//    }
//    else{
//        if ([[cell.contentView  subviews] lastObject]) {
//            [[[cell.contentView subviews] lastObject] removeFromSuperview];
//        }
//    }
//    
//    NSMutableDictionary *dict = mUploadList[indexPath.row];
//    
//    //创建Block
//    UIView *blockview = [[UIView alloc]init];
//    [blockview setBackgroundColor:LIGHTGRAY_COLOR];
//    [blockview.layer setCornerRadius:8];
//    [blockview.layer setMasksToBounds:YES];
//    
//    //Details
//    for (int i = 0; i < [dict[@"details"] count]; i++) {
//        //base on InputbatchType To Create Views
//        NSMutableDictionary *detailDict = dict[@"details"][i];
//        
//        switch ([detailDict[@"type"] intValue]) {
//            case InputbatchTypeText:{
//                UILabel *typeTextLabel = [CustomUtil setTextInLabel:detailDict[@"contents"][@"text"] labelW:CONTENT_WIDTH labelPadding:0 textAlign:NSTextAlignmentRight textFont:[UIFont systemFontOfSize:17]];
//                [typeTextLabel setFrame:CGRectMake(PADDING, LASTOBJECT_OFFSET, typeTextLabel.frame.size.width, typeTextLabel.frame.size.height)];
//                
//                [blockview addSubview:typeTextLabel];
//            }
//                break;
//            case InputbatchTypeImage:{
//                NSString *uploadKey = detailDict[@"contents"][@"uploadkey"];
//                
//                UIImage *image = [self getImageFromDocument:uploadKey];
//                UIImageView *imageview;
//                if (image.size.width > CONTENT_WIDTH) {
//                    imageview = [[UIImageView alloc]initWithFrame:CGRectMake(PADDING, LASTOBJECT_OFFSET, CONTENT_WIDTH, (image.size.height / image.size.width) * CONTENT_WIDTH)];
//                }
//                else{
//                    imageview = [[UIImageView alloc]initWithFrame:CGRectMake(PADDING, LASTOBJECT_OFFSET, image.size.width, image.size.height)];
//                }
//                [imageview setImage:image];
//                
//                [blockview addSubview:imageview];
//            }
//                break;
//            case InputbatchTypeData:{
//                NSString *datastr = [NSString stringWithFormat:@"使用%@测定%@的%@,值为%@%@",detailDict[@"contents"][@"equipment"], detailDict[@"contents"][@"chemical"], detailDict[@"contents"][@"metric"], detailDict[@"contents"][@"value"], detailDict[@"contents"][@"unit"]];
//                UILabel *typeDataLabel = [CustomUtil setTextInLabel:datastr labelW:CONTENT_WIDTH labelPadding:0 textAlign:NSTextAlignmentRight textFont:[UIFont systemFontOfSize:17.0f]];
//                [typeDataLabel setFrame:CGRectMake(PADDING, LASTOBJECT_OFFSET, typeDataLabel.frame.size.width, typeDataLabel.frame.size.height)];
//                
//                [blockview addSubview:typeDataLabel];
//            }
//                break;
//            case InputbatchTypeVoice:{
//                
//            }
//                break;
//            case InputbatchTypeSpecial:{
//                
//                NSString *specstr = @"";
//                
//                switch ([detailDict[@"contents"][@"specialtype"] intValue]) {
//                    case SpecialInputTypeDisasterNatureIdentified:{
//                        if ([detailDict[@"contents"][@"remarks"] intValue] == 0) {
//                            specstr = [NSString stringWithFormat:@"当前事故性质为:大气事故"];
//                        }
//                        else if([detailDict[@"contents"][@"remarks"] intValue] == 1) {
//                            specstr = [NSString stringWithFormat:@"当前事故性质为:水事故"];
//                        }
//                    }
//                        break;
//                    case SpecialInputTypeDisasterLocationPinpointed:{
//                        specstr = [NSString stringWithFormat:@"污染源位置已定，坐标为：%@",detailDict[@"contents"][@"remarks"]];
//                    }
//                        break;
//                    case SpecialInputTypeDisasterChemicalIdentified:{
//                        specstr = [NSString stringWithFormat:@"污染源相关化学品为%@",detailDict[@"contents"][@"remarks"]];
//                    }
//                        break;
//                    default:
//                        break;
//                }
//                
//                UILabel *typeSpecLabel = [CustomUtil setTextInLabel:specstr labelW:CONTENT_WIDTH labelPadding:0 textAlign:NSTextAlignmentRight textFont:[UIFont systemFontOfSize:17.0f]];
//                [typeSpecLabel setFrame:CGRectMake(PADDING, LASTOBJECT_OFFSET, typeSpecLabel.frame.size.width, typeSpecLabel.frame.size.height)];
//                
//                [blockview addSubview:typeSpecLabel];
//            }
//                break;
//            default:
//                break;
//        }
//    }
//    
//    //添加操作栏
//    UIView *optView = [self createOptionView:@{@"state":dict[@"state"], @"uploadTime":dict[@"uploadTime"]==nil?@"":[CustomUtil getFormatedDateString:dict[@"uploadTime"]], @"index":[NSString stringWithFormat:@"%ld", (long)indexPath.row] }];
//    [optView setFrame:CGRectMake(0, LASTOBJECT_OFFSET , optView.frame.size.width, optView.frame.size.height)];
//    
//    [blockview addSubview:optView];
//    [blockview setFrame:CGRectMake(MARGIN, MARGIN, SCREEN_WIDTH - MARGIN*2, optView.frame.size.height + optView.frame.origin.y)];
//    
//    if([dict[@"type"] intValue] == InputbatchTypeSpecial){
//        [blockview setBackgroundColor:LIGHTORANGE_COLOR];
//    }
//    else{
//        [blockview setBackgroundColor:LIGHTGRAY_COLOR];
//    }
//    
//    [cell.contentView addSubview: blockview];
//    
//    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//    return cell;
//}

#pragma mark - upload option views&events
-(UIView *)createOptionView:(NSDictionary *)dict{
    CGFloat optionWidth = SCREEN_WIDTH - PADDING*2 - MARGIN*2;
    CGFloat iPADDING = 4;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, optionWidth, LINE_HEIGHT)];
    UIImageView *stateImage;
    UILabel *stateLabel;
    UIButton *uploadButton = [[UIButton alloc]initWithFrame:CGRectMake(0, iPADDING, 29, 29)];
    [uploadButton setImage:[UIImage imageNamed:@"icon-action-upload"] forState:UIControlStateNormal];
    UIButton *deleteButton = [[UIButton alloc]initWithFrame:CGRectMake(0, iPADDING, 29, 29)];
    [deleteButton setTitle:@"del" forState:UIControlStateNormal];
    [deleteButton setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
    
    UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [loadingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [loadingView setCenter:CGPointMake(22, 22)];
    
    NSString *stateStr;
    
    if ([dict[@"state"] intValue] == UploadStateSuccess) {
        //已上传
        stateImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon-state-right"]];
        stateStr = [NSString stringWithFormat:@"已上传 %@", dict[@"uploadTime"]];
        [uploadButton setHidden:YES];
        [loadingView stopAnimating];
    }
    else if([dict[@"state"] intValue] == UploadStateFailure){
        //上传失败
        stateImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon-state-wrong"]];
        stateStr = [NSString stringWithFormat:@"上传失败 %@",dict[@"uploadTime"]];
        [uploadButton setHidden:NO];
        [loadingView stopAnimating];
    }
    else if([dict[@"state"] intValue] == UploadStateLoading){
        //正在上传
        stateImage = [[UIImageView alloc]initWithImage:nil];
        stateStr = [NSString stringWithFormat:@"正在上传 请稍候..."];
        [uploadButton setHidden:YES];
        [loadingView startAnimating];
    }
    else{
        //等待上传
        stateImage = [[UIImageView alloc]initWithImage:nil];
        stateStr = @"";//[NSString stringWithFormat:@"%@",@"点击上传"];
        [uploadButton setHidden:NO];
        [loadingView stopAnimating];
        
    }
    [stateImage setFrame:CGRectMake(iPADDING,(LINE_HEIGHT-stateImage.frame.size.height)/2, 29, 29)];
    [uploadButton setFrame:CGRectMake(optionWidth - uploadButton.frame.size.width + PADDING, iPADDING, uploadButton.frame.size.width, uploadButton.frame.size.height)];
    
    [deleteButton setFrame:CGRectMake(optionWidth - deleteButton.frame.size.width - uploadButton.frame.size.width, iPADDING, deleteButton.frame.size.width, deleteButton.frame.size.height)];
    stateLabel = [[UILabel alloc]initWithFrame:CGRectMake(stateImage.frame.size.width + stateImage.frame.origin.x + PADDING,
                                                         0,
                                                          optionWidth - PADDING*2 - stateImage.frame.size.width - uploadButton.frame.size.width , LINE_HEIGHT)];
    [stateLabel setText:stateStr];
    [stateLabel setTextColor:[UIColor grayColor]];
    [stateLabel setFont:[UIFont systemFontOfSize:14.0f]];
    
    [uploadButton addTarget:self action:@selector(actionUploadInputbatch:) forControlEvents:UIControlEventTouchUpInside];
    uploadButton.tag = [dict[@"index"] intValue];
    [deleteButton addTarget:self action:@selector(actionDeleteInputbatch:) forControlEvents:UIControlEventTouchUpInside];
    deleteButton.tag = [dict[@"index"] intValue];
    
    [view addSubview:loadingView];
    [view addSubview:stateImage];
    [view addSubview:stateLabel];
    [view addSubview:uploadButton];
    [view addSubview:deleteButton];
    if([dict[@"state"] intValue] != UploadStateSuccess && [dict[@"state"] intValue] != UploadStateLoading){
        [deleteButton setHidden:NO];
    }
    else{
        [deleteButton setHidden:YES];
    }
//    [deleteButton setHidden:YES];
    
    return view;
}

-(void)actionDeleteInputbatch:(id)sender{
    NSLog(@"只能删除未上传成功的inputbatch");
    NSInteger index = [(UIButton *)sender tag];
    UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:@"删除" message:@"确认删除此条信息？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertview setTag:index];
    [alertview show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSLog(@"确定");
        [mUploadList removeObjectAtIndex:alertView.tag];
        [self removeBlockViewInScrollView:(int)alertView.tag];
        //[self updateScrollView];
        [self saveUploadList:mUploadList disasterid:self.did];
    }
    else{
        NSLog(@"取消");
    }
}

-(void)actionUploadInputbatch:(id)sender{
    NSLog(@"test upload");
    
    NSInteger index = [(UIButton *)sender tag];
    
    [self actionAddInputbatch:index];
}

-(void)actionAddInputbatch:(NSInteger)index{
    //显示loading指示
    NSMutableDictionary *currentDict = [[NSMutableDictionary alloc]initWithDictionary:mUploadList[index]];
    if ([currentDict[@"lat"] intValue] == 0 || [currentDict[@"lng"] intValue] == 0) {
        if (mLocationCoor.latitude  == 0 || mLocationCoor.longitude == 0) {
            [CustomUtil showMBProgressHUD:@"无法定位，不可上传数据" view:self.view animated:YES];
            return;
        }
        else{
            [mLocationManager stopUpdatingLocation];
            [mLocationManager startUpdatingLocation];
            [currentDict setObject:[NSString stringWithFormat:@"%f",mLocationCoor.longitude] forKey:@"lat"];
            [currentDict setObject:[NSString stringWithFormat:@"%f",mLocationCoor.latitude] forKey:@"lng"];
        }
    }
    
    [currentDict setObject:[NSString stringWithFormat:@"%ld",(long)UploadStateLoading] forKey:@"state"];
    [mUploadList replaceObjectAtIndex:index withObject:currentDict];
    [self updateOptionViewInBlockView:currentDict inputbatchIndex:(int)index];
    
    //进行上传
    [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@",EDRSHTTP, EDRSHTTP_UPLOAD_ADD] params:currentDict success:^(id responseObj) {
        NSLog(@"get inputbatch add state = %@", responseObj);
        if (responseObj[@"id"]) {
            
            [currentDict setObject:responseObj[@"id"] forKey:@"id"];
            [currentDict setObject:[NSString stringWithFormat:@"%ld",(long)UploadStateLoading] forKey:@"state"];
            [self updateOptionViewInBlockView:currentDict inputbatchIndex:(int)index];
            
            //上传完之后判断当前对象中是否包含文件
            if([currentDict[@"type"] intValue] == InputbatchTypeImage || [currentDict[@"type"] intValue] == InputbatchTypeVoice){
                //返回数据中的id逐个写入
                for (int i = 0; i < [responseObj[@"pairs"] count]; i++) {
                    for (int j = 0; j < [currentDict[@"details"] count]; j++) {
                        //返回id写入之后，开始上传fragment
                        if ([responseObj[@"pairs"][i][@"uploadkey"] isEqualToString:
                             currentDict[@"details"][j][@"contents"][@"uploadkey"]]) {
                            [currentDict[@"details"][j] setObject:responseObj[@"pairs"][i][@"recordid"] forKey:@"id"];
                            break;
                        }
                    }
                }
                //upload fragment
                [self actionUploadFiles:currentDict inputbatchIndex:index];
            }
            else{
                //不包含文件则直接Commit
                [self actionCommitInputbatch:responseObj[@"id"] dicIndex:index inputbatch:currentDict];
            }
            
        }
    } failure:^(NSError *err) {
        NSLog(@"fail to get inputbatch add state, error = %@", err);
        
        [currentDict setObject:[NSString stringWithFormat:@"%ld",(long)UploadStateFailure] forKey:@"state"];
        [mUploadList replaceObjectAtIndex:index withObject:currentDict];
        [self saveUploadList:mUploadList disasterid:self.did];
        [self updateOptionViewInBlockView:currentDict inputbatchIndex:(int)index];
        //[self updateScrollView];
        
    }];
}

-(void)actionCommitInputbatch:(NSString *)responseid dicIndex:(NSInteger)index inputbatch:(NSMutableDictionary *)currentDict{
    //不包含文件则直接Commit
    [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@",EDRSHTTP, EDRSHTTP_UPLOAD_COMMIT] params:@{@"id":responseid} success:^(id responseObj) {
        NSLog(@"commit inputbatch uploaded successfully , response = %@", responseObj);
        if ([responseObj[@"success"] intValue] == 1) {
            [currentDict setObject:[NSString stringWithFormat:@"%ld",(long)UploadStateSuccess] forKey:@"state"];
            [currentDict setObject:responseObj[@"time"] forKey:@"uploadTime"];
            
            [self updateOptionViewInBlockView:currentDict inputbatchIndex:(int)index];
            [mUploadList replaceObjectAtIndex:index withObject:currentDict];
            [self saveUploadList:mUploadList disasterid:self.did];
        }
        else if([responseObj[@"success"] intValue] == 0){
            if (responseObj[@"reason"]) {
                [mUploadList removeObjectAtIndex:index];
                [self removeBlockViewInScrollView:(int)index];
                [self saveUploadList:mUploadList disasterid:self.did];
            }
            else{
                [currentDict setObject:[NSString stringWithFormat:@"%ld",(long)UploadStateFailure] forKey:@"state"];
                
                [self updateOptionViewInBlockView:currentDict inputbatchIndex:(int)index];
                [mUploadList replaceObjectAtIndex:index withObject:currentDict];
                [self saveUploadList:mUploadList disasterid:self.did];
            }
        }
    } failure:^(NSError *err) {
        NSLog(@"fail to get inputbatch commit response, error = %@", err);
    }];
}

//-(void)actionUploadFiles:(NSMutableArray *)array{
//    for (int i = 0; i < [array count]; i++) {
//        if ([array[i][@"type"] intValue] == InputbatchTypeImage) {
//            //上传图片
////            UIImage *tmpimg = mWaitingUploadImages[array[i][@"contents"][@"uploadkey"]];
////            NSData *tmpimagedata = UIImageJPEGRepresentation(tmpimg, 1.0);
//            UIImage *tmpimg = [self getImageFromDocument:array[i][@"contents"][@"uploadkey"]];
//            NSData *tmpimagedata = UIImageJPEGRepresentation(tmpimg, 1.0);
//            NSString *tmpdata = [CustomUtil UIImageToBase64:tmpimg];
//            
//            [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@", EDRSHTTP, EDRSHTTP_UPLOAD_FILE]
//                          params:@{@"key":array[i][@"contents"][@"uploadkey"],
//                                   @"buffer":tmpdata,
//                                   @"length":[NSNumber numberWithInteger:tmpimagedata.length],
//                                   @"index":@"1"}
//                         success:^(id responseObj) {
//                             NSLog(@"upload file successfully, response = %@", responseObj);
//                         }
//                         failure:^(NSError *err) {
//                             NSLog(@"fail to upload file , error = %@", err);
//                         }];
//        }
//    }
//}

-(void)actionUploadFiles:(NSMutableDictionary *)inputbatch inputbatchIndex:(NSInteger)index{
    
    NSMutableArray *detailArr = inputbatch[@"details"];
    for (int i = 0; i < detailArr.count ; i++) {
        if([detailArr[i][@"type"] intValue] == InputbatchTypeImage){
           // dispatch_async(globalQueue, ^{
                if (/* DISABLES CODE */ (NO)) {
                    NSLog(@"停止上传");
                    return;
                }
                else{
                    NSLog(@"上传%d", i);
                    NSData *tmpdata = [self getImageDataFromDocument:detailArr[i][@"contents"][@"uploadkey"]];
                    
                    int tmplen = [detailArr[i][@"contents"][@"size"] intValue];
                    NSMutableArray *bufarr = [self uploadImageBuffers:tmpdata length:tmplen];
                    [self actionUploadImage:inputbatch inputbatchIndex:index detailIndex:i bufferIndex:0 bufferArr:bufarr];
                    
//                    NSString *tmpstr = [self getImageDataFromDocument:detailArr[i][@"contents"][@"uploadkey"]];
//                    NSData *tmpdata = [CustomUtil base64NSStringToNsData:tmpstr];
//                    int length = [detailArr[i][@"contents"][@"size"] intValue];
//                    int count = length/BUFFERMAX +1;
//                    
//                    dispatch_queue_t queue = dispatch_queue_create("bufferQueue", DISPATCH_QUEUE_SERIAL);
//                    for (int v = 0; v < count; v++) {
//                        NSData *bufData;
//                        NSString *buf = @"";
//                        if (v == count-1) {
//                            bufData = [tmpdata subdataWithRange:NSMakeRange(v*BUFFERMAX, length%BUFFERMAX)];
//                            NSLog(@"此时剩余块大小为%d",length%BUFFERMAX);
//                        }
//                        else{
//                            bufData = [tmpdata subdataWithRange:NSMakeRange(v*BUFFERMAX, BUFFERMAX)];
//                        }
//                        buf = [bufData base64EncodedStringWithOptions:0];
//                        
//                        NSString *upindex = detailArr[i][@"index"];
//                        NSString *checklen = [NSString stringWithFormat:@"%d",v*BUFFERMAX];
//                        if([upindex isEqualToString:checklen]){
//                            dispatch_async(queue, ^{
//                                [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@",EDRSHTTP, EDRSHTTP_UPLOAD_FILE]
//                                              params:@{@"key":detailArr[i][@"contents"][@"uploadkey"],
//                                                       @"buffer":buf,
//                                                       @"length":[NSString stringWithFormat:@"%lu",bufData.length],
//                                                       @"index":upindex}
//                                             success:^(id responseObj) {
//                                                 NSLog(@"upload img %@ successfully, response = %@", detailArr[i][@"contents"][@"uploadkey"], responseObj);
//                                                 //上传成功，给当前项目打上标记
//                                                 [detailArr[i][@"contents"] setObject:responseObj[@"count"] forKey:@"index"];
//                                                 
//                                                 [inputbatch setObject:detailArr forKey:@"details"];
//                                                 [mUploadList replaceObjectAtIndex:index withObject:inputbatch];
//                                             }
//                                             failure:^(NSError *err) {
//                                                 NSLog(@"fail to upload img %@ , response = %@", detailArr[i][@"contents"][@"uploadkey"], err);
//                                             }];
//                            });
//                        }
//                        else{
//                            NSLog(@"上一个还没执行完");
//                        }
//                    
//                    }
                    
                    
                    
//                    NSString *tmpdata = [self getImageDataFromDocument:detailArr[i][@"contents"][@"uploadkey"]];
//                    NSString *upindex = detailArr[i][@"index"];
//                    
//                    [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@",EDRSHTTP, EDRSHTTP_UPLOAD_FILE]
//                                  params:@{@"key":detailArr[i][@"contents"][@"uploadkey"],
//                                           @"buffer":tmpdata,
//                                           @"length":detailArr[i][@"contents"][@"size"],
//                                           @"index":upindex}
//                                 success:^(id responseObj) {
//                                     NSLog(@"upload img %@ successfully, response = %@", detailArr[i][@"contents"][@"uploadkey"], responseObj);
//                                     //上传成功，给当前项目打上标记
//                                     [detailArr[i][@"contents"] setObject:responseObj[@"count"] forKey:@"index"];
//                                 }
//                                 failure:^(NSError *err) {
//                                     NSLog(@"fail to upload img %@ , response = %@", detailArr[i][@"contents"][@"uploadkey"], err);
//                                 }];
                }
            //});
        }
    }
}

//上传图片块
-(NSMutableArray *)uploadImageBuffers:(NSData *)tmpdata length:(int)length{
    //NSString *tmpstr = [self getImageDataFromDocument:detailArr[dindex][@"contents"][@"uploadkey"]];
    //NSData *tmpdata = [CustomUtil base64NSStringToNsData:base64];
    //int length = [detailArr[dindex][@"contents"][@"size"] intValue];
    int count = length/BUFFERMAX +1;
    
    NSMutableArray *tmparr = [[NSMutableArray alloc]init];
    for (int bindex = 0; bindex < count; bindex++) {
        NSData *bufData;
        NSString *buf = @"";
        if (bindex == count-1) {
            bufData = [tmpdata subdataWithRange:NSMakeRange(bindex*BUFFERMAX, length%BUFFERMAX)];
            NSLog(@"此时剩余块大小为%d",length%BUFFERMAX);
        }
        else{
            bufData = [tmpdata subdataWithRange:NSMakeRange(bindex*BUFFERMAX, BUFFERMAX)];
        }
        buf = [bufData base64EncodedStringWithOptions:0];
        [tmparr addObject:@{@"buflen":[NSString stringWithFormat:@"%lu",(unsigned long)bufData.length], @"buf":buf}];

//用于显示上传图片
//        UIWindow *window =[[UIApplication sharedApplication].delegate window];
//        UIButton *imageV =[[UIButton alloc]initWithFrame:window.bounds];
//        [imageV setImage:[UIImage imageWithData:bufData] forState:UIControlStateNormal];
//        [imageV addTarget:self action:@selector(showimage:) forControlEvents:UIControlEventTouchUpInside];
//        [window addSubview:imageV];
     

    }
    
    return tmparr;
}
- (void)showimage:(UIButton *)but{
    [but removeFromSuperview];
}
-(void)actionUploadImage:(NSMutableDictionary *)inputbatch inputbatchIndex:(NSInteger)iindex detailIndex:(NSInteger)dindex bufferIndex:(NSInteger)bindex bufferArr:(NSMutableArray *)buffer{
    NSMutableArray *detailArr = inputbatch[@"details"];
    
//    NSString *tmpstr = [self getImageDataFromDocument:detailArr[dindex][@"contents"][@"uploadkey"]];
//    NSData *tmpdata = [CustomUtil base64NSStringToNsData:tmpstr];
    int length = [detailArr[dindex][@"contents"][@"size"] intValue];
    int count = length/BUFFERMAX +1;
//
//    NSData *bufData;
//    NSString *buf = @"";
//    if (bindex == count-1) {
//        bufData = [tmpdata subdataWithRange:NSMakeRange(bindex*BUFFERMAX, length%BUFFERMAX)];
//        NSLog(@"此时剩余块大小为%d",length%BUFFERMAX);
//    }
//    else{
//        bufData = [tmpdata subdataWithRange:NSMakeRange(bindex*BUFFERMAX, BUFFERMAX)];
//    }
//    buf = [bufData base64EncodedStringWithOptions:0];
    
    NSString *upindex = detailArr[dindex][@"index"];
    
    NSLog(@"当前参数为：uploadkey = %@, bufstring =, length = %@, index = %@",detailArr[dindex][@"contents"][@"uploadkey"],buffer[bindex][@"buflen"],upindex);
    
    [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@",EDRSHTTP, EDRSHTTP_UPLOAD_FILE]
                  params:@{@"key":detailArr[dindex][@"contents"][@"uploadkey"],
                           @"buffer":buffer[bindex][@"buf"],
                           @"length":buffer[bindex][@"buflen"],
                           @"index":upindex}
                 success:^(id responseObj) {
                     NSLog(@"upload img %@ successfully, response = %@", detailArr[dindex][@"contents"][@"uploadkey"], responseObj);
                     //上传成功，给当前项目打上标记
                     if([responseObj[@"count"] intValue]==0){
                         return;
                     }
                     else{
                         if ([responseObj[@"count"] intValue] == BUFFERMAX) {
                             [detailArr[dindex] setObject:[NSNumber numberWithInteger:(bindex+1)*BUFFERMAX] forKey:@"index"];
                         }
                         else{
                             [detailArr[dindex] setObject:[NSNumber numberWithInteger:bindex*BUFFERMAX+[responseObj[@"count"] intValue]] forKey:@"index"];
                         }
                         
                         [inputbatch setObject:detailArr forKey:@"details"];
                         [mUploadList replaceObjectAtIndex:iindex withObject:inputbatch];
                         
                         if (bindex == count-1) {
                             NSLog(@"图片上传完毕");
                             //检查同个Inputbacth中其他image是否上传完成
                             BOOL tmpUploadEndedFlag = YES;
                             for (int i = 0; i < [inputbatch[@"details"] count]; i++) {
                                 if ([inputbatch[@"details"][i][@"type"] intValue]==InputbatchTypeImage) {
                                     if ([inputbatch[@"details"][i][@"index"] intValue] != [inputbatch[@"details"][i][@"contents"][@"size"] intValue]) {
                                         tmpUploadEndedFlag = NO;
                                         break;
                                     }
                                 }
                             }
                             //所有图片上传完成则Commit
                             if (tmpUploadEndedFlag) {
                                 [self actionCommitInputbatch:inputbatch[@"id"] dicIndex:iindex inputbatch:inputbatch];
                             }
                         }
                         else{
                             NSLog(@"上传图片块为%@", responseObj[@"count"]);
                             [self actionUploadImage:inputbatch inputbatchIndex:iindex detailIndex:dindex bufferIndex:(bindex+1) bufferArr:buffer];
                         }
                     }
                     
                 }
                 failure:^(NSError *err) {
                     NSLog(@"fail to upload img %@ , response = %@", detailArr[dindex][@"contents"][@"uploadkey"], err);
                 }];
}




//-(NSMutableDictionary *)actionUploadImage:(NSMutableDictionary *)dict success:(void (^)(id))success failure:(void (^)(NSError *))failure{
//    NSString *tmpdata = [self getImageDataFromDocument:dict[@"contents"][@"uploadkey"]];
//    NSString *upindex = dict[@"index"];
//    [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@",EDRSHTTP, EDRSHTTP_UPLOAD_FILE]
//                  params:@{@"key":dict[@"contents"][@"uploadkey"],
//                           @"buffer":tmpdata,
//                           @"length":dict[@"contents"][@"size"],
//                           @"index":upindex}
//                 success:^(id responseObj) {
//                     NSLog(@"upload img %@ successfully, response = %@", dict[@"contents"][@"uploadkey"], responseObj);
//                     //上传成功，给当前项目打上标记
//                     //[dict[@"contents"] setObject:responseObj[@"count"] forKey:@"index"];
//                     if (success) {
//                         success(responseObj);
//                     }
//                 }
//                 failure:^(NSError *err) {
//                     if (failure) {
//                         failure(err);
//                     }
//                     NSLog(@"fail to upload img %@ , response = %@", dict[@"contents"][@"uploadkey"], err);
//                 }];
//    return dict;
//}



#pragma mark - taking photos
- (IBAction)actionCamera:(id)sender {
    //判断当前是否能拍照，进入页面
    NSLog(@"is camera available? = %d",[UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]);
    NSLog(@"is photolibrary is available ? = %d",[UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]);
    
    if(![self isCameraAvailable] && [self isCameraSupportTakingPhotos]){
        UIImagePickerController *controller = [[UIImagePickerController alloc]init];
        controller.delegate = self;
        [controller setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        //UIImagePickerController继承于UINavigationController，用模态弹出。。
        [self.navigationController showDetailViewController:controller sender:self];
    }
    else{
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [picker setDelegate:self];
        [self.navigationController showDetailViewController:picker sender:self];
    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //delegate方法
    NSLog(@"选择图片成功,info = %@", info);
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        if([mediaType isEqualToString:(NSString *)kUTTypeImage]){
            UIImage *img = nil;
            if ([picker allowsEditing]) {
                img = [info objectForKey:UIImagePickerControllerEditedImage];
            }
            else{
                img = [info objectForKey:UIImagePickerControllerOriginalImage];
            }
            SEL selectorToCall = @selector(imageSavedSuccessfully:didFinishSavingWithError:contextInfo:);
            UIImageWriteToSavedPhotosAlbum(img, self, selectorToCall, NULL);
            
            NSMutableDictionary *dict = [self createImageInputbatch:info];
            [self updateInputbatch:dict];
        }
    }
    else{
        //获取图片
        NSMutableDictionary *dict = [self createImageInputbatch:info];
        [self updateInputbatch:dict];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imageSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void*)paramContextInfo{
    if (paramError == nil) {
        NSLog(@"image saving successfully");
    }
    else{
        NSLog(@"an error happened");
        NSLog(@"error=%@",paramError);
    }
}

-(BOOL)cameraSupportMedia:(NSString *)mediatype sourceType:(UIImagePickerControllerSourceType)sourcetype{
    __block BOOL result = NO;
    if ([mediatype length]==0) {
        return NO;
    }
    NSArray *availableMediaType = [UIImagePickerController availableMediaTypesForSourceType:sourcetype];
    [availableMediaType enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *tmpMediaType = obj;
        if ([mediatype isEqualToString:tmpMediaType]) {
            *stop = YES;
            result = YES;
        }
    }];
    return result;
}
-(BOOL)isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}
-(BOOL)isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
}
-(BOOL)isCameraSupportTakingPhotos{
    return  [self cameraSupportMedia:(NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

#pragma mark - add datas
-(void)updateInputbatch:(NSMutableDictionary *)dict{
    //添加之前进行定位数据检查
    if ([dict[@"type"] intValue] != InputbatchTypeSpecial &&
        [dict[@"contents"][@"specialtype"] intValue] != SpecialInputTypeDisasterLocationPinpointed) {
//        mLocationCoor.longitude = 121.56;
//        mLocationCoor.latitude = 29.86;
    
        //leon
//        if(mLocationCoor.longitude == 0 || mLocationCoor.latitude == 0) {
//            [CustomUtil showMBProgressHUD:@"请稍后，正在获取定位信息" view:self.view animated:YES];
//            [mLocationService stopUserLocationService];
//            [mLocationService startUserLocationService];
//            [self performSelector:@selector(updateInputbatch:) withObject:dict afterDelay:5.0f];
//            return;
//        }
    }
    
    
    //获取当前mUploadList的最后一个对象
    NSMutableDictionary *lastobj = [[NSMutableDictionary alloc]initWithDictionary:mUploadList.lastObject];
    //存在上一个，且正在等待上传（可以继续添加）
    if (mUploadList.lastObject && [lastobj[@"state"] intValue] == UploadStateWait && [lastobj[@"type"] intValue] != InputbatchTypeSpecial && [dict[@"type"] intValue] != InputbatchTypeSpecial) {
        NSMutableArray *arr = [[NSMutableArray alloc]init];
        for (int i = 0; i <[[lastobj objectForKey:@"details"] count]; i++) {
            [arr addObject:[lastobj objectForKey:@"details"][i]];
        }
        [arr addObject:dict];
        [lastobj setObject:arr forKey:@"details"];
        //图片或者音频存在，则修改外部type以供判断
        if ([dict[@"type"] intValue] == InputbatchTypeVoice || [dict[@"type"] intValue] == InputbatchTypeImage) {
            [lastobj setObject:dict[@"type"] forKey:@"type"];
        }
        [mUploadList replaceObjectAtIndex:mUploadList.count-1 withObject:lastobj];
        
        NSLog(@"当前list = %@", mUploadList);
        [self saveUploadList:mUploadList disasterid:self.did];
        [self updateBlockViewInScrollView:[mUploadList lastObject] inputbatchIndex:(int)mUploadList.count-1];
    }
    else{
        //新增一个数据
        NSMutableArray *newArr = [[NSMutableArray alloc]init];
        [newArr addObject:dict];
        
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc]init];
        [newDict setObject:[NSString stringWithFormat:@"%ld",(long)UploadStateWait] forKey:@"state"];
        [newDict setObject:self.did forKey:@"disasterid"];
        [newDict setObject:mStaffId forKey:@"staffid"];
        [newDict setObject:[NSString stringWithFormat:@"%0.8f",mLocationCoor.longitude] forKey:@"lng"];
        [newDict setObject:[NSString stringWithFormat:@"%0.8f",mLocationCoor.latitude] forKey:@"lat"];
        [newDict setObject:newArr forKey:@"details"];
        [newDict setObject:dict[@"type"] forKey:@"type"];
     //   [newDict setObject:@"" forKey:@"nature"];
        
        [mUploadList addObject:newDict];
        
        NSLog(@"当前list = %@", mUploadList);
        [self saveUploadList:mUploadList disasterid:self.did];
        [self addNewBlockViewInScrollView:newDict inputbatchIndex:(int)mUploadList.count - 1];
    }
    
    //[self updateScrollView];
}

-(NSMutableDictionary *)createTextInputbatch:(NSString *)text{
    NSMutableDictionary *textDict = [[NSMutableDictionary alloc]init];
    [textDict setObject:[NSString stringWithFormat:@"%ld",(long)InputbatchTypeText] forKey:@"type"];
    [textDict setObject:@"0" forKey:@"index"];
    
    NSMutableDictionary *contentDict = [[NSMutableDictionary alloc]init];
    [contentDict setObject:text forKey:@"text"];

    [textDict setObject:contentDict forKey:@"contents"];
    
    return textDict;
}

#pragma mark --编辑图片尺寸
-(NSMutableDictionary *)createImageInputbatch:(NSDictionary *)imageinfo{
    UIImage *oriImage = [imageinfo objectForKey:@"UIImagePickerControllerOriginalImage"];
    UIImage *image = [CustomUtil fixOrientation:oriImage];
    //NSURL *imageurl = [imageinfo valueForKey:UIImagePickerControllerReferenceURL];
    
    NSData *tmpimgdata = UIImageJPEGRepresentation([CustomUtil scaleImage:image toScale:0.5], 0.3f);
    
    NSMutableDictionary *imageDict = [[NSMutableDictionary alloc]init];
    [imageDict setObject:[NSString stringWithFormat:@"%ld",(long)InputbatchTypeImage] forKey:@"type"];
    [imageDict setObject:@"0" forKey:@"index"];
    
    int iw = image.size.width;
    int ih = image.size.height;
    
    NSMutableDictionary *contentDict = [[NSMutableDictionary alloc]init];
    [contentDict setObject:[NSString stringWithFormat:@"%d",iw] forKey:@"width"];
    [contentDict setObject:[NSString stringWithFormat:@"%d",ih] forKey:@"height"];
//    [contentDict setObject:[NSNumber numberWithInteger:tmpimgdata.length] forKey:@"size"];
    [contentDict setObject:[[NSUUID UUID] UUIDString] forKey:@"uploadkey"];
    [contentDict setObject:@"tmp.jpg" forKey:@"path"];
 
    
    //image搁到另外的数据里
    //[mWaitingUploadImages setObject:image forKey:contentDict[@"uploadkey"]];
    [self saveImageToDocument:image imagekey:contentDict[@"uploadkey"]];
    
    NSData *tmpdata = [self getImageDataFromDocument:contentDict[@"uploadkey"]];
    [contentDict setObject:[NSNumber numberWithInteger:tmpdata.length] forKey:@"size"];

    
    [imageDict setObject:contentDict forKey:@"contents"];
    
    
    
    return imageDict;
}

-(NSMutableDictionary *)createDataInputbatch:(NSString *)c equipment:(NSString *)e metric:(NSString *)m unit:(NSString *)u value:(NSString *)v{
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc]init];
    [dataDict setObject:[NSString stringWithFormat:@"%ld", (long)InputbatchTypeData] forKey:@"type"];
    [dataDict setObject:@"0" forKey:@"index"];
    
    NSMutableDictionary *contentDict = [[NSMutableDictionary alloc]init];
    [contentDict setObject:c forKey:@"chemical"];
    [contentDict setObject:e forKey:@"equipment"];
    [contentDict setObject:m forKey:@"metric"];
    [contentDict setObject:u forKey:@"unit"];
    [contentDict setObject:v forKey:@"value"];
    
    [dataDict setObject:contentDict forKey:@"contents"];
    
    return dataDict;
}
-(NSMutableDictionary *)createDataInputbatch:(NSMutableDictionary *)contentDict{
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc]init];
    [dataDict setObject:[NSString stringWithFormat:@"%ld", (long)InputbatchTypeData] forKey:@"type"];
    [dataDict setObject:@"0" forKey:@"index"];
    [dataDict setObject:contentDict forKey:@"contents"];
    
    return dataDict;
}


-(NSMutableDictionary *)createVoiceInputbatch{
    return nil;
}

-(NSMutableDictionary *)createSpecialInputbatch:(NSInteger)s refid1:(NSString *)r1 refid2:(NSString *)r2 remarks:(NSString *)rm{
    NSMutableDictionary *specDict = [[NSMutableDictionary alloc]init];
    [specDict setObject:[NSString stringWithFormat:@"%ld",(long)InputbatchTypeSpecial] forKey:@"type"];
    [specDict setObject:@"0" forKey:@"index"];
    
    NSMutableDictionary *contentDict = [[NSMutableDictionary alloc]init];
    [contentDict setObject:[NSString stringWithFormat:@"%ld", (long)s] forKey:@"specialtype"];
    [contentDict setObject:r1 forKey:@"refid1"];
    [contentDict setObject:r2 forKey:@"refid2"];
    [contentDict setObject:rm forKey:@"remarks"];
    
    [specDict setObject:contentDict forKey:@"contents"];
    
    return specDict;
}

#pragma mark - image 缓存等

-(void)saveImageToDocument:(UIImage *)image imagekey:(NSString *)name{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *sandboxpath = NSHomeDirectory();
    NSString *folderpath = [sandboxpath stringByAppendingPathComponent:[NSString stringWithFormat:@"/Documents/edrsCache/%@%@",EDRS_UD_UP_IMAGES, [CustomAccount sharedCustomAccount].user.userId]];
    BOOL isdir;
    if (![manager fileExistsAtPath:folderpath isDirectory:&isdir]) {
        [manager createDirectoryAtPath:folderpath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    float scale = SCREEN_WIDTH/image.size.width < 1 ? SCREEN_WIDTH/image.size.width : 1;
    
    NSString *imgpath = [folderpath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",name]];
    NSString *scaleimgpath = [folderpath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@.jpg",name]];
    
    NSData *scaleimgdata = UIImageJPEGRepresentation([CustomUtil scaleImage:image toScale:scale], 0.7f);
    NSData *imgdata = UIImageJPEGRepresentation([CustomUtil scaleImage:image toScale:0.5], 0.7f);
    
    if ([scaleimgdata writeToFile:scaleimgpath atomically:YES] && [imgdata writeToFile:imgpath atomically:YES] ) {
        NSLog(@"写入图片和缩略图成功");
    }
    
//    NSString *newpath = [CustomUtil getFilePath:[NSString stringWithFormat:@"%@%@.plist", EDRS_UD_UP_IMAGES,[CustomAccount sharedCustomAccount].user.userId]];
//    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
//
//    BOOL isdir;
//    if ([manager fileExistsAtPath:newpath isDirectory:&isdir]) {
//        dict = [[NSMutableDictionary alloc]initWithContentsOfFile:newpath];
//    }
//    
//    NSString *base64img = [CustomUtil UIImageToBase64:image];
//    [dict setObject:base64img forKey:name];
//    if ([dict writeToFile:newpath atomically:YES]) {
//        NSLog(@"写入成功");
//    }
}


-(void)updateImageInDocument:(NSString *)uploadkey newUploadKey:(NSString *)newkey{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *sandboxpath = NSHomeDirectory();
    NSString *folderpath = [sandboxpath stringByAppendingPathComponent:[NSString stringWithFormat:@"/Documents/edrsCache/%@%@",EDRS_UD_UP_IMAGES, [CustomAccount sharedCustomAccount].user.userId]];
    
    NSString *oldimgpath = [folderpath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",uploadkey]];
    NSString *oldscaleimgpath = [folderpath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@.jpg",uploadkey]];
    NSString *newimgpath = [folderpath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",newkey]];
    NSString *newscaleimgpath = [folderpath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@.jpg",newkey]];
    
    if ([manager moveItemAtPath:oldimgpath toPath:newimgpath error:nil]) {
        NSLog(@"重命名成功");
    }
    if ([manager moveItemAtPath:oldscaleimgpath toPath:newscaleimgpath error:nil]) {
        NSLog(@"缩略图重命名成功");
    }
    
    
//    NSString *filepath = [CustomUtil getFilePath:[NSString stringWithFormat:@"%@%@.plist", EDRS_UD_UP_IMAGES,[CustomAccount sharedCustomAccount].user.userId]];
//    NSMutableDictionary *tmpdict = [[NSMutableDictionary alloc]initWithContentsOfFile:filepath];
//    NSString *base64img = [tmpdict objectForKey:uploadkey];
//    [tmpdict removeObjectForKey:uploadkey];
//    [tmpdict setObject:base64img forKey:newkey];
//    
//    if ([tmpdict writeToFile:filepath atomically:YES]) {
//        NSLog(@"写入成功");
//    }
}

-(UIImage *)getImageFromDocument:(NSString *)name{
    NSString *sandboxpath = NSHomeDirectory();
    NSString *imgpath = [sandboxpath stringByAppendingPathComponent:[NSString stringWithFormat:@"/Documents/edrsCache/%@%@/thumb_%@.jpg", EDRS_UD_UP_IMAGES,[CustomAccount sharedCustomAccount].user.userId, name]];
    UIImage *img = [UIImage imageWithContentsOfFile:imgpath];
    return img;
    
}

-(NSData *)getImageDataFromDocument:(NSString *)name{

    NSString *sandboxpath = NSHomeDirectory();
    NSString *imgpath = [sandboxpath stringByAppendingPathComponent:[NSString stringWithFormat:@"/Documents/edrsCache/%@%@/%@.jpg", EDRS_UD_UP_IMAGES,[CustomAccount sharedCustomAccount].user.userId, name]];
    NSData *imgdata = [NSData dataWithContentsOfFile:imgpath];
    return imgdata;
}




#pragma mark - segue
-(IBAction)showUploadDataView:(id)sender{
    
    
    PollutionsViewController *pollutionsVC = [[PollutionsViewController alloc]init];
    pollutionsVC.dataArray = self.taskArray;
    pollutionsVC.did = self.did;
    [self.navigationController pushViewController:pollutionsVC animated:YES];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"UploadDataSegue"]) {
        UploadDataViewController *targetVC = segue.destinationViewController;
        targetVC.mLocation = mLocationCoor;
        targetVC.delegate = self;
        targetVC.did = self.did;
    }
    else if([segue.identifier isEqualToString:@"UploadSpecSegue"]){
        UploadSpecTableViewController *targetVC = segue.destinationViewController;
        targetVC.delegate = self;
    }
}

#pragma mark - self def delegates
-(void)SetData:(NSMutableDictionary *)dict{
    //获取数据
    NSLog(@"获取data upload= %@", dict);
    
    //更新数据列表
    NSMutableDictionary *tmpdict = [self createDataInputbatch:dict];
    
    [self updateInputbatch:tmpdict];
    
}

-(void)setDisasterNature:(NSMutableDictionary *)dict{
    NSLog(@"获取，事故性质定义= %@", dict[@"value"]);
    
    //更新数据列表
    NSMutableDictionary *tmpdict = [self createSpecialInputbatch:SpecialInputTypeDisasterNatureIdentified refid1:@"" refid2:@"" remarks:dict[@"id"]];
    [self updateInputbatch:tmpdict];
    
    NSInteger index = mUploadList.count - 1;
    [self actionAddInputbatch:index];
}

-(void)setPollutionLocation:(CLLocationCoordinate2D)coor{
    NSLog(@"获取，污染源位置，lat = %f, lng = %f", coor.latitude, coor.longitude);
    
    BMKGeoCodeSearch *search =[[BMKGeoCodeSearch alloc]init];
    search.delegate = self;
    BMKReverseGeoCodeOption *opt = [[BMKReverseGeoCodeOption alloc]init];
    opt.reverseGeoPoint = coor;
    NSLog(@"%d", [search reverseGeoCode:opt]);
 
    //转到onGetReverseGeoCodeResult进行数据上传
    //更新数据列表
//    NSMutableDictionary *tmpdict = [self createSpecialInputbatch:SpecialInputTypeDisasterLocationPinpointed refid1:@"" refid2:@"" remarks:[NSString stringWithFormat:@"%f,%f",coor.longitude, coor.latitude]];
//    [self updateInputbatch:tmpdict];
//    
//    NSInteger index = mUploadList.count - 1;
//    [self actionAddInputbatch:index];
}

-(void)setDisasterChemicalNotification:(NSNotification *)notification{
    NSDictionary *dic = [notification object];
    [self setDisasterChemical:dic];
}

-(void)setDisasterChemical:(NSDictionary *)dict{
    NSLog(@"获取，化学品%@", dict[@"name"]);
    
    NSMutableDictionary *tmpdict ;
    NSNumber *typeNum = [dict valueForKey:@"typeIndex"];
    if([typeNum integerValue] == 0){
       tmpdict = [self createSpecialInputbatch:SpecialInputTypeDisasterChemicalIdentified refid1:@"" refid2:dict[@"id"] remarks:dict[@"name"]];
    }else{
       tmpdict = [self createSpecialInputbatch:SpecialInputTypeDisasterChemicalIdentified refid1:dict[@"id"] refid2:@"" remarks:dict[@"name"]];
    }
    

    [self updateInputbatch:tmpdict];
    
    NSInteger index = mUploadList.count - 1;
    [self actionAddInputbatch:index];
}

-(void)setWindsData:(NSString *)dict{
    NSLog(@"获取，风向风速为%@",dict);
    NSMutableDictionary *tmpdict = [self createSpecialInputbatch:SpecialInputTypeDisasterWindDirectionSpeed refid1:@"" refid2:@"" remarks:dict];
    [self updateInputbatch:tmpdict];
    
    NSInteger index = mUploadList.count - 1;
    [self actionAddInputbatch:index];
}

#pragma mark - view updates
-(NSInteger)getLastSubViewStartY:(UIView *)view{
    UIView *lastView=(UIView *) [[view subviews] lastObject];
    return lastView.frame.size.height + lastView.frame.origin.y + 10;
}

/* 创建block 中的内容 */
-(void)createContentInBlockView:(UIView *)blockview detail:(NSMutableDictionary *)detailDict{
    switch ([detailDict[@"type"] intValue]) {
        case InputbatchTypeText:{
            UILabel *typeTextLabel = [CustomUtil setTextInLabel:detailDict[@"contents"][@"text"] labelW:CONTENT_WIDTH labelPadding:0 textAlign:NSTextAlignmentRight textFont:[UIFont systemFontOfSize:17]];
            [typeTextLabel setFrame:CGRectMake(PADDING,[self  getLastSubViewStartY:blockview], typeTextLabel.frame.size.width, typeTextLabel.frame.size.height)];
            
            [blockview addSubview:typeTextLabel];
        }
            break;
        case InputbatchTypeImage:{
            NSString *uploadKey = detailDict[@"contents"][@"uploadkey"];
            
            UIImage *image = [self getImageFromDocument:uploadKey];
            UIImageView *imageview;
            if (image.size.width > CONTENT_WIDTH) {
                imageview = [[UIImageView alloc]initWithFrame:CGRectMake(PADDING, [self  getLastSubViewStartY:blockview], CONTENT_WIDTH, (image.size.height / image.size.width) * CONTENT_WIDTH)];
            }
            else{
                imageview = [[UIImageView alloc]initWithFrame:CGRectMake(PADDING, [self  getLastSubViewStartY:blockview], image.size.width, image.size.height)];
            }
            [imageview setImage:image];
            
            [blockview addSubview:imageview];
        }
            break;
        case InputbatchTypeData:{
            NSString *datastr = [NSString stringWithFormat:@"使用%@测定%@%@,值为%@%@",detailDict[@"contents"][@"equipmentname"], detailDict[@"contents"][@"chemicalname"],detailDict[@"contents"][@"metric"],  detailDict[@"contents"][@"value"], detailDict[@"contents"][@"unit"]];
            UILabel *typeDataLabel = [CustomUtil setTextInLabel:datastr labelW:CONTENT_WIDTH labelPadding:0 textAlign:NSTextAlignmentRight textFont:[UIFont systemFontOfSize:17.0f]];
            [typeDataLabel setFrame:CGRectMake(PADDING, [self  getLastSubViewStartY:blockview], typeDataLabel.frame.size.width, typeDataLabel.frame.size.height)];
            
            [blockview addSubview:typeDataLabel];
        }
            break;
        case InputbatchTypeVoice:{
            
        }
            break;
        case InputbatchTypeSpecial:{
            
            NSString *specstr = @"";
            
            switch ([detailDict[@"contents"][@"specialtype"] intValue]) {
                case SpecialInputTypeDisasterNatureIdentified:{
                    if ([detailDict[@"contents"][@"remarks"] intValue] == 100) {
                        specstr = [NSString stringWithFormat:@"当前事故性质为:大气事故"];
                    }else if([detailDict[@"contents"][@"remarks"] intValue] == 10) {
                        specstr = [NSString stringWithFormat:@"当前事故性质为:水事故"];
                    }else if([detailDict[@"contents"][@"remarks"] intValue] == 1) {
                        specstr = [NSString stringWithFormat:@"当前事故性质为:土事故"];
                    }
                    else if([detailDict[@"contents"][@"remarks"] intValue] == 11) {
                        specstr = [NSString stringWithFormat:@"当前事故性质为:水、土事故"];
                    }else if([detailDict[@"contents"][@"remarks"] intValue] == 101) {
                        specstr = [NSString stringWithFormat:@"当前事故性质为:气、土事故"];
                    }else if([detailDict[@"contents"][@"remarks"] intValue] == 111) {
                        specstr = [NSString stringWithFormat:@"当前事故性质为:气、水、土事故"];
                    }
                    else if([detailDict[@"contents"][@"remarks"] intValue] == 0) {
                        specstr = [NSString stringWithFormat:@"当前事故性质为:未知"];
                    }
                }
                    break;
                case SpecialInputTypeDisasterLocationPinpointed:{
                    specstr = [NSString stringWithFormat:@"污染源位置已定，坐标为：%@",[detailDict[@"contents"][@"remarks"] componentsSeparatedByString:@"_$"][0]];
                }
                    break;
                case SpecialInputTypeDisasterChemicalIdentified:{
                    specstr = [NSString stringWithFormat:@"污染源相关化学品为%@",detailDict[@"contents"][@"remarks"]];
                }
                    break;
                case SpecialInputTypeDisasterWindDirectionSpeed:{
                    NSArray *tmparr = [detailDict[@"contents"][@"remarks"] componentsSeparatedByString:@","];
                    specstr = [NSString stringWithFormat:@"当前的风向为%@度%@,风速为%@m/s", tmparr[0],[CustomUtil getWindType:tmparr[0]], tmparr[1]];
                }
                    break;
                default:
                    break;
            }
            
            UILabel *typeSpecLabel = [CustomUtil setTextInLabel:specstr labelW:CONTENT_WIDTH labelPadding:0 textAlign:NSTextAlignmentRight textFont:[UIFont systemFontOfSize:17.0f]];
            [typeSpecLabel setFrame:CGRectMake(PADDING, [self  getLastSubViewStartY:blockview], typeSpecLabel.frame.size.width, typeSpecLabel.frame.size.height)];
            
            [blockview addSubview:typeSpecLabel];
        }
            break;
        default:
            break;
    }
}

/* 创建block view */
-(UIView *)createBlockView:(NSMutableDictionary *)inputbatch inputbatchIndex:(int)iindex{
    //创建Block
    UIView *blockview = [[UIView alloc]init];
    [blockview setBackgroundColor:LIGHTGRAY_COLOR];
    [blockview.layer setCornerRadius:8];
    [blockview.layer setMasksToBounds:YES];
    
    //添加操作栏
    UIView *optView = [self createOptionView:@{@"state":inputbatch[@"state"], @"uploadTime":inputbatch[@"uploadTime"]==nil?@"":[CustomUtil getFormatedDateString:inputbatch[@"uploadTime"]], @"index":[NSString stringWithFormat:@"%d", iindex] }];
    optView.tag = 1000;
    [optView setFrame:CGRectMake(0, 0 , optView.frame.size.width, optView.frame.size.height)];
    [blockview addSubview:optView];
    //Details
    for (int i = 0; i < [inputbatch[@"details"] count]; i++) {
        //base on InputbatchType To Create Views
        NSMutableDictionary *detailDict = inputbatch[@"details"][i];
        [self createContentInBlockView:blockview detail:detailDict];
    }
    
  
    
    
    [blockview setFrame:CGRectMake(MARGIN, MARGIN, SCREEN_WIDTH - MARGIN*2, [self  getLastSubViewStartY:blockview])];
    
    if([inputbatch[@"type"] intValue] == InputbatchTypeSpecial){
        [blockview setBackgroundColor:LIGHTORANGE_COLOR];
    }
    else{
        [blockview setBackgroundColor:LIGHTGRAY_COLOR];
    }
    
    return blockview;
}

/* 更新block view中最后一个元素 */
-(void)updateBlockViewInScrollView:(NSMutableDictionary *)inputbatch inputbatchIndex:(int)iindex{
    UIView *blockview = [mUploadCellList objectAtIndex:iindex];
    float oldH = blockview.frame.size.height;
    
//    [[[blockview subviews] lastObject] removeFromSuperview];
    NSMutableDictionary *detailDict = [inputbatch[@"details"] lastObject];
    [self createContentInBlockView:blockview detail:detailDict];
    
//    UIView *optView = [self createOptionView:@{@"state":inputbatch[@"state"], @"uploadTime":inputbatch[@"uploadTime"]==nil?@"":[CustomUtil getFormatedDateString:inputbatch[@"uploadTime"]], @"index":[NSString stringWithFormat:@"%d", iindex] }];
//    [optView setFrame:CGRectMake(0, LASTOBJECT_OFFSET , optView.frame.size.width, optView.frame.size.height)];
//    
//    [blockview addSubview:optView];
   [blockview setFrame:CGRectMake(blockview.frame.origin.x, blockview.frame.origin.y, blockview.frame.size.width, [self  getLastSubViewStartY:blockview])];
    
    float newH = blockview.frame.size.height;
    
    [[[self.uploadScrollView subviews] lastObject] removeFromSuperview];
    
    float blockOffsetY = self.uploadScrollView.contentSize.height - oldH + newH;
    [self.uploadScrollView addSubview:blockview];
    [self.uploadScrollView setContentSize:CGSizeMake(self.view.frame.size.width, blockOffsetY)];
    [self scrollToBottom];
}
/* 添加新的Blockview */
-(void)addNewBlockViewInScrollView:(NSMutableDictionary *)inputbatch inputbatchIndex:(int)iindex{
    int blockOffsetY = self.uploadScrollView.contentSize.height;
    
    UIView *blockview = [self createBlockView:inputbatch inputbatchIndex:iindex];
    [blockview setFrame:CGRectMake(blockview.frame.origin.x, blockOffsetY, blockview.frame.size.width, blockview.frame.size.height)];
    blockOffsetY += blockview.frame.size.height + 10;
    [mUploadCellList addObject:blockview];
    [self.uploadScrollView addSubview:blockview];
    [self.uploadScrollView setContentSize:CGSizeMake(self.view.frame.size.width, blockOffsetY)];
    [self scrollToBottom];
}
/* 删除某个blockview */
-(void)removeBlockViewInScrollView:(int)iindex{
    UIView *delblockview = [mUploadCellList objectAtIndex:iindex];
    
    float tmpOffsetY = delblockview.frame.origin.y;
    
    for (int i = iindex+1 ; i < mUploadCellList.count; i++) {
        UIView *blockview = [mUploadCellList objectAtIndex:i];
        [blockview setFrame:CGRectMake(blockview.frame.origin.x, tmpOffsetY, blockview.frame.size.width, blockview.frame.size.height)];
        UIView *optview = [[blockview subviews] lastObject];
        UIButton *delbtn = [[optview subviews] lastObject];
        [delbtn setTag:i-1];
        
        tmpOffsetY += blockview.frame.size.height + 10;
    }
    
    UIView *blockview = [mUploadCellList objectAtIndex:iindex];
    [blockview removeFromSuperview];
    [mUploadCellList removeObjectAtIndex:iindex];
    
    [self.uploadScrollView setContentSize:CGSizeMake(self.view.frame.size.width, tmpOffsetY)];
    [self scrollToBottom];
}
/* 更新blockView中的操作栏 */
-(void)updateOptionViewInBlockView:(NSMutableDictionary *)inputbatch inputbatchIndex:(int)iindex{
    if (mUploadCellList.count > iindex) {
        UIView *blockview = [mUploadCellList objectAtIndex:iindex];
        
        UIView *subView = [blockview viewWithTag:1000];
        [subView removeFromSuperview];
        UIView *optView = [self createOptionView:@{@"state":inputbatch[@"state"], @"uploadTime":inputbatch[@"uploadTime"]==nil?@"":[CustomUtil getFormatedDateString:inputbatch[@"uploadTime"]], @"index":[NSString stringWithFormat:@"%d", iindex]}];
        [optView setFrame:CGRectMake(0, 0 , optView.frame.size.width, optView.frame.size.height)];
        optView.tag = 1000;
        [blockview addSubview:optView];
    }
}

-(void)initScrollView{
    int blockOffsetY = 10;
    
    for (int i = 0; i < mUploadList.count; i++) {
        NSMutableDictionary *dict = mUploadList[i];
        
        UIView *blockview = [self createBlockView:dict inputbatchIndex:i];
        
        [blockview setFrame:CGRectMake(blockview.frame.origin.x, blockOffsetY, blockview.frame.size.width, blockview.frame.size.height)];
        blockOffsetY += blockview.frame.size.height + 10;
        
        [self.uploadScrollView addSubview:blockview];
        
        [mUploadCellList addObject:blockview];
    }
    
    [self.uploadScrollView setContentSize:CGSizeMake(self.view.frame.size.width, blockOffsetY)];
    [self scrollToBottom];
}
-(void)scrollToBottom{
    if (self.uploadScrollView.contentSize.height > self.uploadScrollView.frame.size.height) {
        [self.uploadScrollView setContentOffset:CGPointMake(0, self.uploadScrollView.contentSize.height - self.uploadScrollView.frame.size.height)];
    }
}



#pragma mark - cache read & write
-(void)saveUploadList:(NSMutableArray *)arr disasterid:(NSString *)did{
//    [[NSUserDefaults standardUserDefaults] setObject:arr forKey:[NSString stringWithFormat:@"%@%@",EDRS_UD_UPLOAD,did]];
//    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *newpath = [CustomUtil getFilePath:[NSString stringWithFormat:@"%@%@_%@.plist",EDRS_UD_UPLOAD,[CustomAccount sharedCustomAccount].user.userId,did]];
    if ([arr writeToFile:newpath atomically:YES]) {
        NSLog(@"save successfully");
    }
}

-(NSMutableArray *)readUploadList:(NSString *)did{
//    NSMutableArray *tmparr ;
//    if([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",EDRS_UD_UPLOAD,did]]){
//        tmparr = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",EDRS_UD_UPLOAD,did]]];
//    }
//    else{
//        tmparr = [[NSMutableArray alloc]init];
//    }
//    return tmparr;
    
    NSString *filepath = [CustomUtil getFilePath:[NSString stringWithFormat:@"%@%@_%@.plist",EDRS_UD_UPLOAD,[CustomAccount sharedCustomAccount].user.userId,did]];
    NSMutableArray *tmparr = [[NSMutableArray alloc]initWithContentsOfFile:filepath];
    if (!tmparr) {
        tmparr = [[NSMutableArray alloc]init];
    }
    else{
        NSLog(@"start to update cache");
        //处理数据，将上传时报错的image uploadkey替换掉
        BOOL tmpSaveFlag = NO;
        for(int i = 0; i < tmparr.count; i++){
            NSMutableDictionary *inputbatchDict = tmparr[i];
            if ([inputbatchDict[@"type"] intValue] == InputbatchTypeImage && [inputbatchDict[@"state"] intValue] == UploadStateFailure) {
                for (int j = 0; j < [inputbatchDict[@"details"] count]; j++) {
                    NSMutableDictionary *contentDict = inputbatchDict[@"details"][j][@"contents"];
                    NSString *olduuid = contentDict[@"uploadkey"];
                    NSString *newuuid = [[NSUUID UUID] UUIDString];
                    [self updateImageInDocument:olduuid newUploadKey:newuuid];
                    [contentDict setObject:newuuid forKey:@"uploadkey"];
                    tmpSaveFlag = YES;
                }
            }
        }
        if (tmpSaveFlag) {
            [self saveUploadList:tmparr disasterid:self.did];
        }
        NSLog(@"end update cache");
    }
    return tmparr;
}

@end
