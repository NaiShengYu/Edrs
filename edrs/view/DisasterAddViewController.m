//
//  DisasterAddViewController.m
//  edrs
//
//  Created by bchan on 16/3/22.
//  Copyright © 2016年 julyyu. All rights reserved.
//

#import "DisasterAddViewController.h"
#import "DataPickerView.h"
#import "CheckBoxViewController.h"
#import "SelectDataModel.h"
@interface DisasterAddViewController ()<UITableViewDelegate,UITableViewDataSource,CheckBoxViewControllerDelegate,UITextFieldDelegate>

@property(nonatomic,strong) UITableView *tableview;
@end

@implementation DisasterAddViewController

#pragma mark - 新增事故事件
- (IBAction)actionDisasterAdd:(id)sender {
    [self.view endEditing:YES];
    if([self.mDisasterName.text length]==0){
        [SVProgressHUD showErrorWithStatus:@"请输入事故名称"];
        return;
    }
    [SVProgressHUD show];
    [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@",EDRSHTTP, EDRSHTTP_DISASTER_ADD] params:@{@"name":self.mDisasterName.text, @"nature": selectedNature, @"sid": [CustomAccount sharedCustomAccount].user.stationId} success:^(id responseObj) {
        if (responseObj!= NULL) {
            [SVProgressHUD dismissWithSuccess:@"新增成功"];
            [self.delegate addNewDisasterSuccess];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [SVProgressHUD dismissWithError:@"无数据返回"];
        }
    } failure:^(NSError *err) {
        [SVProgressHUD dismissWithError:@"异常返回"];
    }];
    
}

-(NSArray *)getTitleArray{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (NSDictionary *sub in disasterNatureList) {
        SelectDataModel *model = [SelectDataModel new];
        model.name = [sub valueForKey:@"value"];
        model.id = [sub valueForKey:@"id"];
        if(![model.id isEqualToString: @"-1"]){
            [array addObject:model];
        }
    }
    
    return array;
}
#pragma mark UIView
-(UITableView *)tableview{
    if(_tableview == nil){
        _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
        _tableview.dataSource = self;
        _tableview.delegate = self;
        _tableview.tableFooterView = [UIView new];
    }
    
    return _tableview;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Utility configuerNavigationBackItem:self];
    selectedNature= @"";
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"DisasterNature" ofType:@"plist"];
    disasterNatureList = [NSArray arrayWithContentsOfFile:filepath];
    
    [self.view addSubview:self.tableview];
    
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableView Datasource 
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[UITableViewCell className]];
    
    if(indexPath.row == 0){
        cell.textLabel.text = @"故事名称:";
        if(_mDisasterName == nil){
            _mDisasterName = [[UITextField alloc]initWithFrame:CGRectMake(120, 0, SCREEN_WIDTH-130, 50)];
            _mDisasterName.placeholder = @"请输入新增事故名称";
            _mDisasterName.textAlignment = NSTextAlignmentRight;
            _mDisasterName.returnKeyType = UIReturnKeyDone;
            _mDisasterName.font = [UIFont systemFontOfSize:16];
            _mDisasterName.delegate = self;
            [cell.contentView addSubview:_mDisasterName];
        }
        
    }else if(indexPath.row ==1){
        cell.textLabel.text = @"故事性质:";
        cell.detailTextLabel.text = @"请选择事故性质";
        cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.row ==1){
        [self.view endEditing:YES];
        CheckBoxViewController *checkBoxVC = [[CheckBoxViewController alloc]init];
        checkBoxVC.dataArray = [self getTitleArray];
        checkBoxVC.delegate  =self ;
        [self addChildViewController:checkBoxVC];
        [self.view addSubview:checkBoxVC.view];
//        @weakify(self);
//        [DataPickerView showWithTitleArray:[self getTitleArray] selectIndex:selectedNature dissMiss:^(NSInteger index) {
//            @strongify(self);
//            UITableViewCell *cell = [self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
//            selectedNature = index;
//            cell.detailTextLabel.text = [[self getTitleArray] objectAtIndex:index];
//            cell.detailTextLabel.textColor = [UIColor blackColor];
//        } ];
    }
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
-(void)checkBoxSelect:(NSArray *)dataArray{
            UITableViewCell *cell = [self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            cell.detailTextLabel.text = [self getSelectedNature:dataArray];
            cell.detailTextLabel.textColor = [UIColor blackColor];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}
/*
#pragma mark - pickerview delegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return disasterNatureList.count;
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return disasterNatureList[row][@"value"];
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    //select row
    [self.view endEditing:YES];
    
    selectedNature = row;
    [self.mDisasterNature setTitle:disasterNatureList[row][@"value"] forState:UIControlStateNormal];
}

#pragma mark - 键盘事件
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
*/

@end
