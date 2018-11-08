//
//  ChemicalListViewController.h
//  edrs
//
//  Created by 余文君, July on 15/8/14.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChemicalDetailViewController.h"
#import "CustomHttp.h"
#import "UIScrollView+SVPullToRefresh.h"

@interface ChemicalListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate,UISearchDisplayDelegate,UITextFieldDelegate>{
    NSMutableArray *mChemicalList;
    NSMutableArray *mSearchResultList;
    
    int mPageIndex;
    int mPageSize;
    int mCount;
}

@property (weak, nonatomic) IBOutlet UISearchBar *chemicalListSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *chemicalListTableView;

-(void)getChemicalListDataLength;
-(void)getChemicalListData;

@end
