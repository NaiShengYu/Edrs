//
//  TaskDetailViewController.h
//  VOC
//
//  Created by 林鹏, Leon on 2017/3/16.
//  Copyright © 2017年 林鹏, Leon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SamplePlanModel.h"
@interface TaskDetailViewController : UIViewController

@property(nonatomic,strong) NSString *did;
@property(nonatomic,strong) SamplePlanModel *sampleModel ;

@end
