//
//  DataPickerViewController.h
//  MarketingAssistant
//
//  Created by 林鹏, Leon on 2017/4/12.
//  Copyright © 2017年 林鹏, Leon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^Dissmiss)(NSInteger index);
@interface DataPickerView : UIWindow


@property(nonatomic, strong) NSArray *titleArray;
@property(nonatomic,unsafe_unretained) NSInteger selectedIndex;


+ (void)showWithTitleArray:(NSArray *)array selectIndex:(NSInteger)selectIndex dissMiss:(Dissmiss)dissMiss;
@end
