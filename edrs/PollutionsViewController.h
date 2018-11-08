//
//  PollutionListViewController.h
//  edrs
//
//  Created by 林鹏, Leon on 2017/10/19.
//  Copyright © 2017年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PollutionsViewController : UIViewController

@property(nonatomic,strong) NSString *did;
@property(nonatomic,unsafe_unretained) BOOL showLocationInfo;
@property(nonatomic,strong) NSArray *dataArray;
@end
