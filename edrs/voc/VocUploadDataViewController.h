//
//  UploadDataViewController.h
//  VOC
//
//  Created by 林鹏, Leon on 2017/3/21.
//  Copyright © 2017年 林鹏, Leon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlantTaskModel.h"
#import <BaiduMapAPI_Location/BMKLocationService.h>
@interface VocUploadDataViewController : UIViewController


@property(nonatomic,unsafe_unretained) BOOL isFirst;
@property(nonatomic,strong) PlantTaskModel *plantTaskModel ;

@end
