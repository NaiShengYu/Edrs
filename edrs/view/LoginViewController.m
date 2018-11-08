//
//  LoginViewController.m
//  edrs
//
//  Created by 余文君, July on 15/8/13.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "LoginViewController.h"
#import "UIAlertView+Blocks.h"

@interface LoginViewController (){
    BOOL isExitUser;
    
}

@property(weak,nonatomic) IBOutlet NSLayoutConstraint *login_toppadding;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    // Do any additional setup after loading the view.
    //获取本机用户信息
    
    if(iPad){
        _login_toppadding.constant = 230;
    }
    self.loginButton.layer.cornerRadius = 4;

    [self.rememberPwdSwitch setTintColor:LIGHT_BLUE];
    [self.rememberPwdSwitch setOnTintColor:LIGHT_BLUE];
    __weak __typeof(self) weakSelf = self;
    [weakSelf initUser];
    
    _titleLab.text = @"应急指挥APP\nEmergencyCommand";
    
    
    
}

-(void)getServiceVersion{
    [CustomAccount sharedCustomAccount].stationUrl = [[NSUserDefaults standardUserDefaults] objectForKey:STATIONURL];
    
   
    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@",EDRSHTTP,EDRSHTTP_APPVERSION] params:nil success:^(id responseObj) {
            NSLog(@"%@",[responseObj description]);
                NSString *version = [responseObj valueForKey:@"data"];
                version = [version stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            if([version length]>0){
                [CustomAccount sharedCustomAccount].isNewVersion =YES;
            }
        
                 } failure:^(NSError *err) {
                    
                     if ([[err localizedDescription] isEqualToString:TIMEOUTSTR]){
                         [self.loadingIndicatorView stopAnimating];
                     }
                     NSLog(@"fail to request login, error = %@",err);
                 }];
}

-(void)logoutAction{
    [CustomAccount sharedCustomAccount].stationUrl = [[NSUserDefaults standardUserDefaults] objectForKey:STATIONURL];
    
    [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@",EDRSHTTP,EDRSHTTP_LOGIN_OUT] params:nil success:^(id responseObj) {
        NSLog(@"%@",[responseObj description]);
        NSString *version = [responseObj valueForKey:@"data"];
        version = [version stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        if([version length]>0){
            [CustomAccount sharedCustomAccount].isNewVersion =YES;
        }
        
    } failure:^(NSError *err) {
        
        NSLog(@"fail to request login, error = %@",err);
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [self getServiceVersion];
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self registerForKeyboardNotifications];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    NSLog(@"dealloc");
}

-(void)initUser{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userdefaults stringForKey:USERNAME];
    NSString *password = [userdefaults stringForKey:PASSWORD];
    NSString *stationid = [userdefaults stringForKey:STATIONID];
    NSString *station = [userdefaults stringForKey:STATION];
    BOOL remember = [userdefaults boolForKey:REMEMBERPWD];
    
    if (remember == YES) {
        mStationId = stationid;
        mStationName = station;
        [self.usernameTextField setText:username];
        [self.passwordTextField setText:password];
        [self.stationChangeButton setTitle:mStationName forState:UIControlStateNormal];
    }
    else{
        [self.stationChangeButton setTitle:@"请选择检测站" forState:UIControlStateNormal];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionLogOut) name:LOGOUT object:nil];
}

-(void)actionLogOut{
    if (self.rememberPwdSwitch.on == NO) {
        [self.usernameTextField setText:@""];
        [self.passwordTextField setText:@""];
    }
}


#pragma mark - keyboard about & textfield edit end
-(void)registerForKeyboardNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)keyboardWillShow:(NSNotification *)noti{
    //键盘出现，计算高度大小
    NSDictionary *info = [noti userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
//    CGRect textFieldFrame = _usernameTextField.frame;
//    CGFloat offset = textFieldFrame.origin.y + textFieldFrame.size.height + 6 - (self.view.frame.size.height - kbSize.height);
    
    CGFloat offset=170.0f;
    
    NSTimeInterval animationDuration = 0.35;
    [UIView beginAnimations:@"ResizeForkeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    if (offset > 0) {
        
        self.view.frame = CGRectMake(0, -offset, self.view.frame.size.width, self.view.frame.size.height);
    }
    [UIView commitAnimations];
}

-(void)keyboardWillHide:(NSNotification *)noti{
    
    NSTimeInterval animationDuration = 0.2;
    [UIView beginAnimations:@"RestoreKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
//    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

-(void)hideKeyboard{
    [_usernameTextField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textfield text = %@", textField.text);
    if (textField.text.length > 0) {
        
        //创建一个text detail
//        NSMutableDictionary *dict = [self createTextInputbatch:textField.text];
//        [self updateInputbatch:dict];
//        
//        [mUploadTextField setText:@""];
    }
    
    [self hideKeyboard];
    return YES;
}


#pragma mark - 键盘事件
//-(void)keyboardHide{
//    [self.view endEditing:YES];
//}
//-(void)keyboardDidShow:(NSNotification *)noti{
//    //计算当前contentsize
//    NSValue *value = [[noti userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey];
//    CGSize keyboardSize = [value CGRectValue].size;
//    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
//    
//    [self.editingScrollView setContentSize:CGSizeMake(self.editingScrollView.frame.size.width, screenSize.height - keyboardSize.height - self.editingScrollView.frame.origin.y)];
//
//}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark - 登录

-(void)loginAction{
    //数据传输时
    [self.loadingIndicatorView startAnimating];
    
    //数据
    NSString *tmpUsername = [self.usernameTextField text];
    NSString *tmpPassword = [self.passwordTextField text];
    NSString *tmpStation = [self.stationChangeButton titleLabel].text;
    //userdel=1
    NSString *tmpStatus = @"false";
    if (self.rememberPwdSwitch.on==YES) {
        tmpStatus = @"true";
    }
    
    NSLog(@"url = %@", [[NSUserDefaults standardUserDefaults] objectForKey:STATIONURL]);
    
    [CustomAccount sharedCustomAccount].stationUrl = [[NSUserDefaults standardUserDefaults] objectForKey:STATIONURL];
    NSLog(@"url = %@", [CustomAccount sharedCustomAccount].stationUrl);
    
    if (mStationId == nil || mStationName == nil) {
        [CustomUtil showMBProgressHUD:@"请选择检测站" view:self.view animated:YES];
        [self.loadingIndicatorView stopAnimating];
        return;
    }
    else{
        
    NSLog(@"mStationId===%@,mStationName===%@,tmpStatus==%@",mStationId,mStationName,tmpStatus);
        
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
        [params setValue:tmpUsername forKey:@"UserName"];
        [params setValue:tmpPassword forKey:@"Password"];
        [params setValue:tmpStatus forKey:@"rememberStatus"];
        [params setValue:mStationId forKey:@"sid"];
        [params setValue:mStationName forKey:@"sname"];
        NSLog(@"密码：%@",tmpPassword);
        if([CustomAccount sharedCustomAccount].isNewVersion){
            [params setValue:@"1" forKey:@"userdel"];
        }
        [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@",EDRSHTTP,EDRSHTTP_LOGIN] params:params
                     success:^(id responseObj) {
                         
                         isExitUser = NO;
                         NSLog(@"login request success, response = %@", responseObj);
                         [self.loadingIndicatorView stopAnimating];
                         
                         if ([[NSString stringWithFormat:@"%@",responseObj[@"success"]] isEqualToString:@"1"]) {
                   
                             //登录成功后
                             //是否需要存储用户信息
                             NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
                             if (self.rememberPwdSwitch.on==YES) {
                                 [userdefaults setObject:tmpUsername forKey:USERNAME];
                                 [userdefaults setObject:tmpPassword forKey:PASSWORD];
                                 [userdefaults setObject:tmpStation forKey:STATION];
                                 [userdefaults setObject:mStationId forKey:STATIONID];
                                 [userdefaults setBool:YES forKey:REMEMBERPWD];
                                 [userdefaults setObject:responseObj[@"userid"] forKey:USERID];
                             }
                             else{
                                 [userdefaults removeObjectForKey:REMEMBERPWD];
                             }
                             [userdefaults synchronize];
                             
                             //更新全局变量
                             AccountModel *tmpAccountModel = [[AccountModel alloc]init];
                             [tmpAccountModel setStationId:mStationId];
                             [tmpAccountModel setStationName:mStationName];
                             [tmpAccountModel setUserName:tmpUsername];
                             [tmpAccountModel setPassword:tmpPassword];
                             [tmpAccountModel setUserId:responseObj[@"userid"]];
                             
                             NSString *token ;
                             if([CustomAccount sharedCustomAccount].isNewVersion){
                                 token= [NSString stringWithFormat:@"Bearer %@",responseObj[@"token"]];
                                 [tmpAccountModel setToken:token];
                             }else{
                                 token = [NSString stringWithFormat:@"Basic %@",responseObj[@"userauth"]];
                                 [tmpAccountModel setToken:token];
                             }
                             [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"USERTOKEN"];
                             [CustomAccount sharedCustomAccount].user = tmpAccountModel;
                             
                             //跳转到主页面
                             [[AppDelegate sharedInstance] setRootForMenu];
                             
                         }
                         else{
                             NSString *tmperr = [NSString stringWithFormat:@"%@",responseObj[@"error"]];
                             if(tmperr!=nil && [tmperr isEqualToString:@"USERLIMITREACHED"]) {
                                 [CustomUtil showMBProgressHUD:@"用户数已达上限" view:self.view animated:YES];
                             }else if(tmperr!=nil && [tmperr isEqualToString:@"ExistUser"]) {
                                 //                                 [CustomUtil showMBProgressHUD:@"用户数已达上限" view:self.view animated:YES];
                                 [UIAlertView showAlertViewWithTitle:@"异常登录" message:@"你的账户处于登录状态，是否强制登录" cancelButtonTitle:@"取消" otherButtonTitles:@[@"强制登录"] onDismiss:^(int buttonIndex) {
                                     [self loginAction];
                                 } onCancel:^{
                                     
                                 }];
                             }
                             else {
                                 [CustomUtil showMBProgressHUD:@"请确认用户名和密码填写正确" view:self.view animated:YES];
                             }
                             
                         }
                         
                     } failure:^(NSError *err) {
                         if ([[err localizedDescription] isEqualToString:TIMEOUTSTR]){
                             [self.loadingIndicatorView stopAnimating];
                         }
                         NSLog(@"fail to request login, error = %@",err);
                     }];
    }

}

- (IBAction)actionLogin:(id)sender {
    [self loginAction];
}

#pragma mark - 检测站选择
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"StationChangeSegue"]) {
        //跳转到检测站选择页面
        StationChangeViewController *targetVC = segue.destinationViewController;
        targetVC.delegate = self;
        targetVC.selectedStationId = mStationId;
    }
    else if([segue.identifier isEqualToString:@"MainSegue"]){
       
    }
}
-(void)setStationChange:(NSMutableDictionary *)station{
    [self.stationChangeButton setTitle:station[@"stationName"] forState:UIControlStateNormal];
    mStationId = station[@"stationId"];
    mStationName = station[@"stationName"];
    
}

@end
