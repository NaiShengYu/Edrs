//
//  StationNewViewController.m
//  edrs
//
//  Created by 余文君, July on 15/8/13.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "StationNewViewController.h"

@interface StationNewViewController ()

@end

@implementation StationNewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Utility configuerNavigationBackItem:self];
    UIBarButtonItem * submitButton= [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(actionSubmit:)];
    [submitButton setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = submitButton;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    
    NSLog(@"dealloc");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - 键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark - 提交
- (IBAction)actionSubmit:(id)sender {
     
    
    NSString *stationurl = [self.stationUriTextField.text stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    stationurl = [stationurl stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    [CustomAccount sharedCustomAccount].stationUrl = stationurl;
    
    if (stationurl.length > 0) {
        NSArray *tmpurlarr = [stationurl componentsSeparatedByString:@":"];
        
        NSLog(@"%@", tmpurlarr[0]);
        //新增检测站
        [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@", EDRSHTTP , EDRSHTTP_GETSTATION] params:@{@"stationurl":tmpurlarr[0]} success:^(id responseObj) {
            NSLog(@"get station success, response = %@", responseObj);
            
            //新增完毕，回传数据
            NSMutableDictionary *tmpStation = [[NSMutableDictionary alloc]init];
            [tmpStation setObject:responseObj[@"id"] forKey:@"stationId"];
            [tmpStation setObject:responseObj[@"name"] forKey:@"stationName"];
            [tmpStation setObject:@"0" forKey:@"stationSelected"];
            [tmpStation setObject:stationurl forKey:@"stationUrl"];
            
            [self.delegate setStationNew:tmpStation];
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(NSError *err) {
            NSLog(@"fail to get station, errormsg = %@", err);
        }];
        
        //通信时
        [self.loadingIndicatorView startAnimating];
    }
}
@end
