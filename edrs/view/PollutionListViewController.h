//
//  PollutionListViewController.h
//  edrs
//
//  Created by 余文君, July on 15/8/14.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomHttp.h"
#import "PollutionDetailViewController.h"
#import "UIScrollView+SVPullToRefresh.h"

@interface PollutionListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>{
    NSMutableArray *mPollutionList;
    
    int mPageIndex;
    int mPageSize;
    int mCount;
    
}

@property (weak, nonatomic) IBOutlet UISearchBar *pollutionListSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *pollutionListTableView;

-(void)getPollutionListData;


@end
