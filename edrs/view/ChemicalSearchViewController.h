//
//  ChemicalSearchViewController.h
//  edrs
//
//  Created by 余文君, July on 15/9/17.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomHttp.h"
#import "CustomUtil.h"
#import "CommonDefinition.h"
#import "MJRefresh.h"

@protocol ChemicalSearchDelegate <NSObject>

-(void)setDisasterChemical:(NSMutableDictionary *)dict;

@end

@interface ChemicalSearchViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,
UISearchBarDelegate>{
    NSMutableArray *mDisasterChemicalArray;
    BOOL mSubmitFlag;
    BOOL mSearchFlag;
    CGFloat mNoChemicalLabelHeight;
    NSInteger mSelectedIndex;
    
    int mPageIndex;
    int mPageSize;
    int mCount;
    
}

@property (weak, nonatomic) id<ChemicalSearchDelegate> delegate;
@property (weak, nonatomic) IBOutlet UISearchBar *chemicalSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *chemicalResultTableView;
@property (weak , nonatomic) NSArray *mChemicalsList;

- (IBAction)actionSubmitDisasterChemicals:(id)sender;

@end
