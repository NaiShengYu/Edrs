//
//  MainSearchResultViewController.h
//  edrs
//
//  Created by 余文君, July on 15/8/14.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CateItem.h"
#import "CommonDefinition.h"
#import "ChemicalDetailViewController.h"
#import "EquipmentDetailViewController.h"
#import "PollutionDetailViewController.h"
#import "DisasterDetailViewController.h"

@interface MainSearchResultViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    NSMutableArray *mResultArray;
    NSMutableArray *mResultSectionTitleArray;
    NSMutableArray *mResultSegueIdentifierArray;
}

@property (weak, nonatomic) NSString *keyword;
@property (weak, nonatomic) IBOutlet UITableView *searchResultTableView;

-(void)getSearchResultData;


@end
