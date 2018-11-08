//
//  SettingsTableViewController.h
//  edrs
//
//  Created by 余文君, July on 15/8/14.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "CustomAccount.h"
#import "CustomUtil.h"
#import "CustomHttp.h"

@interface SettingsTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *dutySwitch;

- (IBAction)actionLogout:(id)sender;
- (IBAction)actionClearCache:(id)sender;
@end
