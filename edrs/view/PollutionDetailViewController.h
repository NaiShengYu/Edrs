//
//  PollutionDetailViewController.h
//  edrs
//
//  Created by 余文君, July on 15/8/14.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonDefinition.h"
#import "DetailViewController.h"
#import "ChemicalDetailViewController.h"

@interface PollutionDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    NSMutableDictionary *mPollutionDetail;
    NSMutableArray *mBaseinfo;
    NSMutableArray *mRelative;
}

@property NSString *pid;
@property (strong, nonatomic)  UITableView *pollutionDetailTableView;

-(void)getPollutionDetailData;
-(void)pollutionToArrays;

@end
