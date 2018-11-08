//
//  EquipmentDetailViewController.h
//  edrs
//
//  Created by 余文君, July on 15/8/14.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"
#import "CustomHttp.h"

@interface EquipmentDetailViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    NSMutableArray *mBaseinfo;
    NSMutableArray *mWarranty;
}

@property NSString *eid;

@property (weak, nonatomic) IBOutlet UITableView *equipmentDetailTableView;

-(void)getEquipmentDetailData;

-(void)equipmentToArrays:(NSMutableDictionary *)dict;
@end
