//
//  CheckBoxViewController.h
//  VOC
//
//  Created by 林鹏, Leon on 2017/3/23.
//  Copyright © 2017年 林鹏, Leon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CheckBoxViewControllerDelegate <NSObject>

-(void)checkBoxSelect:(NSArray *)dataArray;

@end
@interface CheckBoxViewController : UIViewController


@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) NSArray *dataArray ;
@property(nonatomic,strong) NSString *titleName;
@property(nonatomic,unsafe_unretained) BOOL fullScreen;
@property(nonatomic,unsafe_unretained) id<CheckBoxViewControllerDelegate>delegate;
@end
