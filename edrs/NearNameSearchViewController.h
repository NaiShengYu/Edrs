//
//  NearNameSearchViewController.h
//  edrs
//
//  Created by Nasheng Yu on 2018/6/22.
//  Copyright © 2018年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NearNameSearchViewController : UIViewController

@property (nonatomic,assign)CLLocationCoordinate2D location;

@property (nonatomic,copy) void (^selectSucceseBlock)(CLLocationCoordinate2D location);
@end
