//
//  EquipmentSelectViewController.h
//  edrs
//
//  Created by 余文君, July on 15/8/21.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomHttp.h"

@protocol EquipmentSelectDelegate <NSObject>

-(void)setSelectedEquipment:(NSMutableDictionary *)edict;

@end

@interface EquipmentSelectViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    NSMutableArray *mEquipmentList;
    int mLength;
    int mSelectedIndex;
}

@property (weak, nonatomic) NSMutableDictionary *selcetedEquipment;
@property (weak, nonatomic) IBOutlet UITableView *equipmentSelectTableView;
@property (weak, nonatomic) id<EquipmentSelectDelegate> delegate;

-(void)submitButton;
-(void)getEquipmentListLength;
-(void)getEquipmentListData;


@end
