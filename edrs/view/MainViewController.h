//
//  MainViewController.h
//  edrs
//
//  Created by 余文君, July on 15/8/13.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonDefinition.h"
#import <QuartzCore/QuartzCore.h>
#import "MainSearchResultViewController.h"
#import "Constants.h"
#import "DisasterDetailViewController.h"
#import "CustomUtil.h"
#import "CommonListViewController.h"
#import "MJRefresh.h"

@interface MainViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate>{
    BOOL mWithProgressingEvents;
    
    NSMutableArray *mProgressingEventsArray;
    NSMutableArray *mDatasCateArray;
    NSMutableArray *mDatasCountArray;
    
    NSString *mSearchKeyword;
    NSTimer *timer;
}

@property (weak, nonatomic) IBOutlet UISearchBar *mainSearchBar;
@property (strong, nonatomic)  UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *DutyButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *SettingsButtonItem;

-(void)keyboardHide;
-(void)getMainData;

@end
