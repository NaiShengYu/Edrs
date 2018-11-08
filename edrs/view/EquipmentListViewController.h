//
//  EquipmentListViewController.h
//  edrs
//
//  Created by 余文君, July on 15/8/14.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomHttp.h"
#import "EquipmentDetailViewController.h"

@interface EquipmentListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    int mPageIndex;
    int mPageSize;
    int mCount;
    
    NSMutableArray *mEquipmentList;
    NSMutableArray *mEquipmentType1List;
    NSMutableArray *mEquipmentType2List;
}

@property (strong, nonatomic)  UITableView *equipmentListTableView;

-(void)getEquipmentListDataLength;
-(void)getEquipmentListData;

@end
