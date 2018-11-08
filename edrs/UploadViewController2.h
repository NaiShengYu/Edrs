//
//  UploadViewController2.h
//  edrs
//
//  Created by 林鹏, Leon on 2017/9/14.
//  Copyright © 2017年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputBatchModel.h"
#import "SamplePlanModel.h"
@interface UploadViewController2 : UIViewController<UITableViewDelegate,UITableViewDataSource>


@property (strong, nonatomic) NSString *did;
@property (strong, nonatomic) InputBatchModel *codeModel;
@property (strong, nonatomic) SamplePlanModel *planModel;
@property (strong, nonatomic) SamplePlanModel *sampleModel;
@property (strong, nonatomic) NSArray *taskArray;
@property (strong, nonatomic) NSArray *qrcodeInfo;
@end
