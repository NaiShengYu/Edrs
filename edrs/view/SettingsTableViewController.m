//
//  SettingsTableViewController.m
//  edrs
//
//  Created by 余文君, July on 15/8/14.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "MMDrawerBarButtonItem.h"
@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController
-(void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [leftDrawerButton setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

-(void)leftDrawerButtonPress:(id)sender{
    [[AppDelegate sharedInstance].drawerVC toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLeftMenuButton];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:DUTYALARM] isEqualToString:@"true"] || [[NSUserDefaults standardUserDefaults] objectForKey:DUTYALARM] == nil) {
        [self.dutySwitch setOn:YES];
    }
    else{
        [self.dutySwitch setOn:NO];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 2;
    }
    else{
        return 1;
    }
}

-(void)logoutAction{
    [CustomAccount sharedCustomAccount].stationUrl = [[NSUserDefaults standardUserDefaults] objectForKey:STATIONURL];
    [SVProgressHUD show];
    [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@",EDRSHTTP,EDRSHTTP_LOGIN_OUT] params:nil success:^(id responseObj) {
        NSLog(@"%@",[responseObj description]);
        [SVProgressHUD dismiss];
        if([[responseObj valueForKey:@"Success"] intValue]==1){
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGOUT object:nil];
        }
    } failure:^(NSError *err) {
        [SVProgressHUD dismiss];
        NSLog(@"fail to request login, error = %@",err);
    }];
}

- (IBAction)actionLogout:(id)sender {
    [self logoutAction];
}

- (IBAction)actionClearCache:(id)sender {
    [CustomUtil deleteFileAtPath:nil];
    [CustomUtil showMBProgressHUD:@"清理缓存成功" view:self.view animated:YES];
}

- (IBAction)actionDutyAlarm:(id)sender {
    UISwitch *tmps = sender;
    NSString *tmpr = @"false";
    NSString *tmpstr = @"";
    if (tmps.on == YES) {
        tmpr = @"true";
        tmpstr = @"打开值班提醒成功";
    }
    else{
        tmpr = @"false";
        tmpstr = @"关闭值班提醒成功";
    }
    //传递参数
    [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@",EDRSHTTP, EDRSHTTP_DUTYSET] params:@{@"userId":[CustomAccount sharedCustomAccount].user.userId, @"remarks":tmpr} success:^(id responseObj) {
        NSLog(@"set duty is successfully , response = %@", responseObj);
        if ([responseObj[@"success"] boolValue] == YES) {
            [CustomUtil showMBProgressHUD:tmpstr view:self.view animated:YES];
            [[NSUserDefaults standardUserDefaults] setObject:tmpr forKey:DUTYALARM];
        }
        else{
            [CustomUtil showMBProgressHUD:@"关闭失败，请重试" view:self.view animated:YES];
        }
    } failure:^(NSError *err) {
        NSLog(@"fail to set duty, err = %@", err);
    }];
}

@end
