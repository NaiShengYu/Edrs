//
//  ImageEditViewController.h
//  edrs
//
//  Created by 林鹏, Leon on 2017/6/5.
//  Copyright © 2017年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ImageDeleteBlock)(UIImage *image);
@interface ImageEditViewController : UIViewController

@property(nonatomic,strong) UIImage *image;
@property(nonatomic,unsafe_unretained) ImageDeleteBlock imageBlock;
@end
