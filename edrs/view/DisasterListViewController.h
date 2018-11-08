//
//  DisasterListViewController.h
//  edrs
//
//  Created by 余文君, July on 15/8/14.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomHttp.h"
#import "CustomUtil.h"
#import "CommonDefinition.h"
#import "DisasterDetailViewController.h"
#import "DisasterAddViewController.h"
#import "MJRefresh.h"

@interface DisasterListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, DisasterAddDelegate>{
    NSMutableArray *mDisasterAllList;
    NSMutableArray *mDisasterCurrentList;
}

@property (strong, nonatomic)  UITableView *disasterListTableView;

-(void)getDisasterListData;

@end
