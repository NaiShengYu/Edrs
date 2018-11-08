//
//  StandardListViewController.m
//  edrs
//
//  Created by 林鹏, Leon on 2017/9/15.
//  Copyright © 2017年 julyyu. All rights reserved.
//

#import "StandardListViewController.h"
#import "AppDelegate.h"
#import "WebApiPath.h"
@interface StandardListViewController ()

@end

@implementation StandardListViewController


-(void)getStandardList{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:@"0" forKey:@"pageIndex"];
    [parameters setValue:@"3" forKey:@"typ"];
    @weakify(self);
    [[AppDelegate sharedInstance].httpTaskManager postWithPortPath:DISASTER_STANDARD_LIST parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        @strongify(self);
      
        
    } onError:^(NSError *engineError) {
        
    }];
}
- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self getStandardList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
