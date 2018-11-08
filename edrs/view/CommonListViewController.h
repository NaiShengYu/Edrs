//
//  CommonListViewController.h
//  edrs
//
//  Created by 余文君, July on 15/10/2.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChemicalDetailViewController.h"
#import "PollutionDetailViewController.h"
#import "CustomHttp.h"
#import "MJRefresh.h"

@interface CommonListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate,UISearchDisplayDelegate,UITextFieldDelegate>{
    

}

@property (weak, nonatomic) NSString *listType;
@property (strong, nonatomic)  UITableView *myTable;

-(void)getListDataLength;
-(void)getListData;

@end
