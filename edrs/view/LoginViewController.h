//
//  LoginViewController.h
//  edrs
//
//  Created by 余文君, July on 15/8/13.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "StationChangeViewController.h"
#import "CustomAccount.h"
#import "CustomHttp.h"
#import "CustomUtil.h"

@interface LoginViewController : UIViewController<UITextFieldDelegate,StationChangeDelegate>{
    NSString *mStationId;
    NSString *mStationName;
}
@property (strong, nonatomic) IBOutlet UILabel *titleLab;

@property (weak, nonatomic) IBOutlet UIButton *stationChangeButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UISwitch *rememberPwdSwitch;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicatorView;
@property (weak, nonatomic) IBOutlet UIScrollView *editingScrollView;

- (IBAction)actionLogin:(id)sender;

//- (void)keyboardDidShow:(NSNotification *)noti;
//- (void)keyboardDidHide:(NSNotification *)noti;


@end
