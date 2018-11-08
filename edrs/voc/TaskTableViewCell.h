//
//  TaskTableViewCell.h
//  VOC
//
//  Created by 林鹏, Leon on 2017/3/17.
//  Copyright © 2017年 林鹏, Leon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlantTaskModel.h"
@interface TaskTableViewCell : UITableViewCell


@property(nonatomic,strong) UILabel *titleLB ;
@property(nonatomic,strong) UILabel *subTitleLB ;
@property(nonatomic,strong) UIView *itemListView;


-(void)setCellInfoWith:(PlantTaskModel *)model;
@end
