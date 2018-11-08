//
//  UploadDataViewController.m
//  VOC
//
//  Created by 林鹏, Leon on 2017/3/21.
//  Copyright © 2017年 林鹏, Leon. All rights reserved.
//

#import "VocUploadDataViewController.h"
#import "InputTableViewCell.h"
#import "SourceFactorModel.h"
#import "CheckBoxViewController.h"
#import "SelectDataModel.h"
#import "Utility.h"
#import "QBImagePickerController.h"
#import "SVProgressHUD.h"
#import "QRCodeReaderViewController.h"
#import "EditTableViewCell.h"
#import "ImageEditViewController.h"
#import "CustomAccount.h"
@interface VocUploadDataViewController ()<UITableViewDelegate,UITableViewDataSource,InputTableViewCellDelete,BMKLocationServiceDelegate,CheckBoxViewControllerDelegate,QBImagePickerControllerDelegate,QRCodeReaderViewControllerDelegate>{
    NSArray *_dataArray ;
    NSMutableDictionary *uploadDic;
    BMKLocationService *_locService;
    CLLocation  *location;
    NSString *inputID;
    NSArray *selectArray ;
    NSInteger _index;
    
    NSInteger allcount ;
    NSInteger currentindex;
    BOOL  isProduce;
    SourceFactorModel *imageModel;
    SourceFactorModel *qrcodeModel;
    
    NSInteger lineCount;
    NSMutableArray *imageArray;
    NSMutableArray *qrcodeArray;
}


@property(nonatomic,strong) UIView *tableViewFootView;
@property(nonatomic,strong) UITableView *tableView;
@end


@implementation VocUploadDataViewController


#pragma mark Method
-(NSArray *)getGudingji{
    NSArray *array = @[@"硫酸",@"硝酸",@"甲苯",@"甲醛",@"硫酸铜",@"三氯甲烷",@"氢氧化钠"];
    NSMutableArray *dataArray =[[NSMutableArray alloc]init];
    for (NSInteger i = 0; i<array.count; i++) {
        SelectDataModel *newModel = [[SelectDataModel alloc]init];
        newModel.id = [NSString stringWithFormat:@"i"];
        newModel.name = [array objectAtIndex:i];
        [dataArray addObject:newModel];
    }
    return dataArray ;
}
-(void)getSourceFactorList:(NSString *)layout{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:_plantTaskModel.typeid forKey:@"typeid"];
    [parameters setValue:layout forKey:@"layout"];
    
    @weakify(self);
    [[AppDelegate sharedInstance].httpTaskManager  getWithPortPath:SOURCE_FACTOR_LIST parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        
        @strongify(self);
        NSMutableArray *array = [[NSMutableArray alloc]init];
        if([layout intValue]==1){
            [self getSourceFactorList:@"9"];
        }else if ([layout intValue]==9){
            [array addObjectsFromArray:_dataArray];
        }
        NSArray *tempArray = [dictionary valueForKey:@"list"];
        for (NSDictionary *sub in tempArray) {
            SourceFactorModel *model = [SourceFactorModel modelWithDictionary:sub];
            if([model.name isEqualToString:@"现场照片"]){
                imageModel = model;
            }else if([model.name isEqualToString:@"二维码"]){
                qrcodeModel = model;
            }else{
               [array addObject:model];
            }
        } 
 
        _dataArray = array ;
        [_tableView reloadData];
    } onError:^(NSError *engineError) {
        
    }];
}


-(void)getSetInputID{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:_plantTaskModel.id forKey:@"taskid"];
    [parameters setValue:[CustomAccount sharedCustomAccount].user.userId forKey:@"staff"];
    [parameters setValue:[NSNumber numberWithFloat:[AppDelegate sharedInstance].location2D.longitude] forKey:@"lng"];
    [parameters setValue:[NSNumber numberWithFloat:[AppDelegate sharedInstance].location2D.latitude] forKey:@"lat"];
    [parameters setValue:_isFirst ? @"0":@"1" forKey:@"type"];
    
    [[AppDelegate sharedInstance].httpTaskManager  postWithPortPath:SET_INPUT_ID parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        inputID = [dictionary valueForKey:@"data"];
        inputID = [inputID stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    } onError:^(NSError *engineError) {
        
    }];
}

-(void)uplaodInfo:(NSString *)factorID content:(NSString *)content{
    if(inputID == nil){
        return;
    }
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:_plantTaskModel.id forKey:@"taskid"];
    [parameters setValue:factorID forKey:@"factor"];
    [parameters setValue:content forKey:@"val1"];
    [parameters setValue:[Utility NSDateToNSString1:[NSDate date]] forKey:@"date"];
    [parameters setValue:inputID forKey:@"inputid"];
  
    [[AppDelegate sharedInstance].httpTaskManager  postWithPortPath: FACTOR_DATA_ADD parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        currentindex = currentindex +1;
        if(currentindex == allcount){
            currentindex =0;
            [SVProgressHUD showSuccessWithStatus:@"上传成功"];
        }
    } onError:^(NSError *engineError) {
       
    }];
}

-(void)uploadImage{
    for (NSInteger i = 0; i<imageArray.count; i++) {
        
        NSData *data = UIImageJPEGRepresentation(imageArray[i], 0.5);
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
        [parameters setValue:_plantTaskModel.id forKey:@"taskid"];
        [parameters setValue:imageModel.id forKey:@"path"];
        [parameters setValue:[data base64EncodedString] forKey:@"buffer"];

        
        [[AppDelegate sharedInstance].httpTaskManager  postWithPortPath: TASK_UPLOAD_FRAGMENT parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
            
        } onError:^(NSError *engineError) {
            
        }];
    }
}


-(void)getTaskAnalysisTypeList{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:_plantTaskModel.id forKey:@"taskid"];
    
    [[AppDelegate sharedInstance].httpTaskManager getWithPortPath: TASK_ANALYSLS_TYPELIST parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        NSMutableArray *temArray = [[NSMutableArray alloc]init];
        NSArray *array = [dictionary valueForKey:@"list"];
        for (NSDictionary *sub in array ) {
            SelectDataModel *model = [SelectDataModel modelWithDictionary:sub];
            [temArray addObject:model];
        }
        selectArray = temArray ;
    } onError:^(NSError *engineError) {
        
    }];
}

-(void)nextButtonClicked:(id)sender{
    [self uploadTextInfo];
    VocUploadDataViewController *uploadVC = [[VocUploadDataViewController alloc]init];
    uploadVC.isFirst = NO ;
    uploadVC.plantTaskModel = _plantTaskModel;
    [self.navigationController pushViewController:uploadVC animated:YES];
}

-(void)uploadTextInfo{
    NSArray *allKey = [[ModelLocator sharedInstance].uploadDic allKeys] ;
    allcount = allKey.count;
    for (NSInteger i = 0; i<allKey.count; i++) {
        NSString *key = [allKey objectAtIndex:i];
        NSString *content = [[ModelLocator sharedInstance].uploadDic valueForKey:key];
        if(content == nil){
            content = @"";
        }
        [self uplaodInfo:key content:content];
    }
}

-(void)uploadQRcode{
    NSMutableString *qrcodeStr = [[NSMutableString alloc]init];
    for (NSInteger i = 0; i<qrcodeArray.count; i++) {
        NSString *sub = qrcodeArray[i];
        [qrcodeStr appendString:sub];
        if(i <qrcodeArray.count-1){
            [qrcodeStr appendString:@","];
        }
    }

    if([qrcodeStr length]>0){
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
        [parameters setValue:_plantTaskModel.id forKey:@"taskid"];
        [parameters setValue:qrcodeModel.id forKey:@"factor"];
        [parameters setValue:qrcodeStr forKey:@"val1"];
        [parameters setValue:[Utility NSDateToNSString4:[NSDate date]] forKey:@"date"];
        [parameters setValue:inputID forKey:@"inputid"];
        [SVProgressHUD show];
        
        @weakify(self);
        [[AppDelegate sharedInstance].httpTaskManager  postWithPortPath: FACTOR_DATA_ADD parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
            @strongify(self);
            [SVProgressHUD dismissWithSuccess:@"上传成功"];
            [self.navigationController popViewControllerAnimated:YES];
        } onError:^(NSError *engineError) {
            [SVProgressHUD dismissWithError:@"接口异常"];
        }];
    }
}

-(void)uploadButtonClicked:(id)sender{
    if(imageModel){
        [self uploadImage];
    }
    
    if(qrcodeModel){
        [self uploadQRcode];
    }
    [self uploadTextInfo];
    
}

-(void)showKeyboard:(NSNotification *)notification{
    UIView *view= [[ UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 250)];
    _tableView.tableFooterView = view ;
    
}
-(void)hideKeyboard:(NSNotification *)notification{
    _tableView.tableFooterView = nil ;
}

-(NSString *)getSelectedItemString{
    NSString *selectStr = nil ;
    for (SelectDataModel *model in selectArray) {
        if(model.state){
            if(selectStr == nil){
                selectStr = model.name;
            }else{
                selectStr = [NSString stringWithFormat:@"%@,%@",selectStr,model.name];
            }
           
        }
    }
    return selectStr;
}

-(NSInteger)getCheckBoxAtIndex{
    for (NSInteger i = 0; i<_dataArray.count; i++) {
        SourceFactorModel *model = [_dataArray objectAtIndex:i];
        if([model.name isEqualToString:isProduce ? @"检测项目":@"固定剂"]){
            return i ;
        }
    }
    
    return 0;
}


-(void)showImagePicker{
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;
    
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.allowsEdit = YES;
    
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    navi.navigationBar.translucent = NO;
    //navigation background Color
    navi.navigationBar.barTintColor = [UIColor colorWithRed:151/255.0 green:217/255.0 blue:204/255.0 alpha:0.5];
    //navigation letf or right nafigationItem Color
    navi.navigationBar.tintColor = [UIColor whiteColor];
    [self presentViewController:navi animated:YES completion:NULL];
}

-(NSInteger)getImagePadding{
    if(SCREEN_WIDTH==320){
        lineCount= 4;
    }else{
        lineCount = 5;
    }
    NSInteger padding = (SCREEN_WIDTH-60*lineCount)/(lineCount+1);
    
    return padding;
}
#pragma mark View]
-(UIView *)tableViewFootView{
    if(_tableViewFootView ==nil){
        NSInteger padding = [self getImagePadding];
        CGFloat scale = SCREEN_HEIGHT/SCREEN_WIDTH;
        _tableViewFootView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60*scale+20)];
       
        UIButton *addButton =[[UIButton alloc]initWithFrame:CGRectMake(padding, 10, 60,60*scale )];
        [addButton setImage:[UIImage imageNamed:@"addImage"] forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(showImagePicker) forControlEvents:UIControlEventTouchUpInside];
        [_tableViewFootView addSubview:addButton];
        
    }
    return _tableViewFootView;
}

-(UITableView *)tableView{
    if(_tableView ==nil){
        _tableView = [[UITableView alloc]initWithFrame:_isFirst?CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-50): CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}
-(UIView *)nextButtonView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-64-50, SCREEN_WIDTH, 50)];
    view.layer.borderWidth = 1;
    view.layer.borderColor = LIGHT_GRAN.CGColor;
    view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-120, 0, 120, 50)];
    [button setBackgroundColor:LIGHT_BLUE];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:@"下一步" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    return view;
}
-(void)showImageEditViewWith:(id )sender{
    UIButton *button = (UIButton *)sender;
    ImageEditViewController *editVC =[[ ImageEditViewController alloc]init];

    editVC.image = [imageArray objectAtIndex:button.tag];
    editVC.imageBlock = ^(UIImage *image) {
        [imageArray removeObject:image];
        [self tableFootViewAddImageArray];
    };
    [self.navigationController pushViewController:editVC animated:YES];
}

-(void)tableFootViewAddImageArray{
    [_tableViewFootView removeAllSubviews];
    CGFloat scale = SCREEN_HEIGHT/SCREEN_WIDTH;
  
    _tableViewFootView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 60*scale+20);
    NSInteger lineNum = 0;
    NSInteger padding = [self getImagePadding];
  
    if((imageArray.count+1)%lineCount==0){
        lineNum = (imageArray.count+1)/lineCount;
    }else{
         lineNum = (imageArray.count+1)/lineCount+1;
    }
    
    _tableViewFootView.height = lineNum*(60*scale+10);
    for (NSInteger i = 0; i<=imageArray.count; i++) {
        NSInteger n = (i/lineCount);
        NSInteger m = i-lineCount*n;
      
        if(i== imageArray.count){
            UIButton *addButton =[[UIButton alloc]initWithFrame:CGRectMake(padding+(60+padding)*m, 10+(60*scale+10)*n, 60,60*scale )];
            [addButton setImage:[UIImage imageNamed:@"addImage"] forState:UIControlStateNormal];
            [addButton addTarget:self action:@selector(showImagePicker) forControlEvents:UIControlEventTouchUpInside];
            [_tableViewFootView addSubview:addButton];
        }else{
            
            
            UIButton *imageView= [[UIButton alloc]initWithFrame:CGRectMake(padding+(60+padding)*m, 10+(60*scale+10)*n, 60,60*scale )];
            imageView.tag = i;
            [imageView addTarget:self action:@selector(showImageEditViewWith:) forControlEvents:UIControlEventTouchUpInside];
            [imageView setImage:[imageArray objectAtIndex:i] forState:UIControlStateNormal];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
        
            [_tableViewFootView addSubview:imageView];
        }
    }
    [_tableView reloadData];
}
-(void)configuerRightBarItem{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 40)];
    [button setImage:[UIImage imageNamed:@"icon_upload"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(uploadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    qrcodeArray = [[NSMutableArray alloc]init];
    imageArray= [[NSMutableArray alloc]init];
    [Utility configuerNavigationBackItem:self];
    [self.view addSubview:self.tableView];
    uploadDic= [[NSMutableDictionary alloc]init];
    if(_isFirst){
        self.title = @"基础数据";
       
      
    }else{
        self.title = @"样品数据";
        [self configuerRightBarItem];

    }
    
    [self getSetInputID];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(_isFirst){
        [self  getSourceFactorList:@"0"];
        [self.view addSubview:[self nextButtonView]] ;
    }else{
        [self  getSourceFactorList:@"1"];
    }
   
    [self getTaskAnalysisTypeList];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.view endEditing:YES];
    
}



#pragma mark UitableView Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(qrcodeModel !=nil && imageModel !=nil){
        return 3;
    }else if ((qrcodeModel !=nil && imageModel ==nil)|| (qrcodeModel ==nil && imageModel !=nil)){
        return 2;
    }else{
        return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0){
        return _dataArray.count;
    }else{
        if(qrcodeModel !=nil &&section==1){
            return qrcodeArray.count +1;
        }else {
            return 1;
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section ==0){
        InputTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:[InputTableViewCell className]];
        
        if(cell ==nil){
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"InputTableViewCell" owner:self options:nil];
            cell = [array objectAtIndex:0];
        }
        
        SourceFactorModel *model = [_dataArray objectAtIndex:indexPath.row];
        cell.delegate = self ;
        cell.model = model;
        cell.index = [indexPath row];
        if([model.name isEqualToString:@"检测项目"]||[model.name isEqualToString:@"采样时间"]||[model.name isEqualToString:@"固定剂"]){
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
             cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if(indexPath.row == _dataArray.count -1){
            cell.textField.returnKeyType = UIReturnKeyDone;
        }
        return cell;
    }else{
      
        
       
        if(indexPath.section ==1 && qrcodeModel !=nil){
            if(indexPath.row == qrcodeArray.count){
                UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
                cell.textLabel.text = @"扫描样本二维码";
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.textColor = LIGHT_BLUE;
                return  cell;
            }else{
                EditTableViewCell *cell = [[EditTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EditTableViewCell"];
                NSString *qrcode = [qrcodeArray objectAtIndex:indexPath.row];
                cell.titleLabel.text = [NSString stringWithFormat:@"样本%ld ：%@",(long)indexPath.row,qrcode] ;
                cell.titleLabel.font = [UIFont systemFontOfSize:14];
                cell.titleLabel.textAlignment = NSTextAlignmentLeft;
                UIButton *deleteButton = cell.deleteButton;
                objc_setAssociatedObject(deleteButton, "name", qrcode, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                [cell.deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                return cell;
            }
        }else{
            UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
            if(self.tableViewFootView){
                [self.tableViewFootView removeFromSuperview];
            }
            [cell.contentView addSubview:self.tableViewFootView];
             return  cell;
        }
       
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.section ==0){
    SourceFactorModel *model = [_dataArray objectAtIndex:indexPath.row];
        if([model.name isEqualToString:@"检测项目"]){
            isProduce = YES ;
            [self.view endEditing:YES];
            CheckBoxViewController *checkBoxVC = [[CheckBoxViewController alloc]init];
            checkBoxVC.dataArray = selectArray;
            checkBoxVC.delegate  =self ;
            [self addChildViewController:checkBoxVC];
            [self.view addSubview:checkBoxVC.view];
        }else if([model.name isEqualToString:@"采样时间"]){
            InputTableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
            cell.subTitleLB.text = [Utility NSDateToNSString1:[NSDate date]];
        }else if([model.name isEqualToString:@"固定剂"]){
            isProduce = NO;
            [self.view endEditing:YES];
            CheckBoxViewController *checkBoxVC = [[CheckBoxViewController alloc]init];
            checkBoxVC.dataArray = [self getGudingji];
            checkBoxVC.delegate  =self ;
            checkBoxVC.titleName = @"检测项目选项";
            [self addChildViewController:checkBoxVC];
            [self.view addSubview:checkBoxVC.view];
        }
    }else{
        [self.view endEditing:YES];
        if(indexPath.section ==1 && qrcodeModel !=nil && indexPath.row == qrcodeArray.count){
           
            QRCodeReaderViewController *qrVC =[[QRCodeReaderViewController alloc]init];
            qrVC.delegate = self;
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:qrVC];
            [self.navigationController presentViewController:nav animated:YES completion:^{
                
            }];
        }
    }
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section==0){
        return nil;
    }else if (section ==1){
        if(qrcodeModel !=nil){
            return @"二维码";
        }else{
            return @"现场照片";
        }
    }else{
        return @"现场照片";
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section ==0){
        return 46;
    }else{
        if(indexPath.section == 1 &&qrcodeModel !=nil){
            return 46;
        }else if (indexPath.section == 1 && qrcodeModel ==nil){
            return self.tableViewFootView.height;
        }else{
            return self.tableViewFootView.height;
        }
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section==0){
        return 1;
    }else{
        return 40;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

-(void)textFieldEndInput:(NSString *)factorId  content:(NSString *)content{
    [uploadDic setValue:content forKey:factorId];
    [[ModelLocator sharedInstance].uploadDic setDictionary:uploadDic];
}

-(void)textFieldEndInputAtIndex:(NSInteger)index{
    InputTableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [cell.textField resignFirstResponder];
    if(index+1 <_dataArray.count-1){
        InputTableViewCell *nextCell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index+1 inSection:0]];
        [nextCell.textField becomeFirstResponder];
    }
}


#pragma select Delegate
-(void)checkBoxSelect:(NSArray *)dataArray{
    selectArray = dataArray ;
    NSString *str = [self getSelectedItemString];
    NSInteger index = [self getCheckBoxAtIndex];
    InputTableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.subTitleLB.text = str;

}


#pragma mark - QBImagePickerControllerDelegate

- (void)imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info
{
    
    if(imagePickerController.allowsMultipleSelection) {
        NSArray *mediaInfoArray = (NSArray *)info;
        [self dismissViewControllerAnimated:YES completion:^{
            NSMutableArray *array = [[NSMutableArray alloc]init];
            for (NSDictionary *sub in  mediaInfoArray) {
                UIImage *image = [sub objectForKey:@"UIImagePickerControllerOriginalImage"];
                [array addObject:image];
            }
            if(array){
                [imageArray addObjectsFromArray:array];
            } ;
            [self tableFootViewAddImageArray];
        }];
        
    } else {
        NSDictionary *mediaInfo = (NSDictionary *)info;
        NSLog(@"Selected: %@", mediaInfo);
        
   
        
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    NSLog(@"取消选择");
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (NSString *)descriptionForSelectingAllAssets:(QBImagePickerController *)imagePickerController
{
    return @"";
}

- (NSString *)descriptionForDeselectingAllAssets:(QBImagePickerController *)imagePickerController
{
    return @"";
}

- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos
{
    return [NSString stringWithFormat:@"图片%lu张", (unsigned long)numberOfPhotos];
}

- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfVideos:(NSUInteger)numberOfVideos
{
    return [NSString stringWithFormat:@"视频%lu", (unsigned long)numberOfVideos];
}



- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos numberOfVideos:(NSUInteger)numberOfVideos
{
    return [NSString stringWithFormat:@"图片%d 视频%lu", numberOfPhotos, (unsigned long)numberOfVideos];
}

#pragma mark QRCodeReader Delegate
-(void)getQRCodeWithSting:(NSString *)code{
    BOOL added = NO;
    for (NSString *sub in qrcodeArray) {
        if([sub isEqualToString:@"code"]){
            added = YES ;
        }
    }
    
    if(!added){
        [qrcodeArray addObject:code];
    }
    
    [_tableView reloadData];
}

-(void)deleteButtonClicked:(id)sender{
    NSString *qrcode = objc_getAssociatedObject(sender, "name");
    [qrcodeArray removeObject:qrcode];
    [_tableView reloadData];
}
@end

