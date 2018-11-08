//
//  WindsViewController.m
//  edrs
//
//  Created by bchan on 15/12/28.
//  Copyright © 2015年 julyyu. All rights reserved.
//

#import "WindsViewController.h"

@interface WindsViewController ()

@end

@implementation WindsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Utility configuerNavigationBackItem:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)actionSubmitWindsData:(id)sender {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:_windDirectTextField.text forKey:@"windDirection"];
    [dict setObject:_windSpeedTextField forKey:@"windSpeed"];
    
    [self.delegate setWindsData:[NSString stringWithFormat:@"%@,%@", _windDirectTextField.text, _windSpeedTextField.text]];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
