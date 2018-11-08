//
//  CommonDefinition.h
//  edrs
//
//  Created by 余文君, July on 15/8/14.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//
#import "MJRefresh.h"//刷新控件
#import "Masonry.h"//界面布局控件
#import "MMDrawerBarButtonItem.h"//抽屉左按钮


#ifndef edrs_CommonDefinition_h
#define edrs_CommonDefinition_h

#endif

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define StartBarHeight ([UIApplication sharedApplication].statusBarFrame.size.height +44)

#define RGBA_COLOR(R,G,B,A) [UIColor colorWithRed:R/255.0f green:G/255.0 blue:B/255.0f alpha:A]
//设置字体大小
#define FontSize(font) [UIFont systemFontOfSize:font]


#define BLUE_COLOR RGBA_COLOR(0,122.0f,255.0f,1.0f)
#define WHITE_COLOR RGBA_COLOR(255.0,255.0,255.0,1.0f)
#define LIGHTGRAY_COLOR RGBA_COLOR(240.0,240.0f,240.0f,1.0f)
#define ORANGE_COLOR RGBA_COLOR(255.0,192.0f,0.0f,1.0f)
#define MAROON_COLOR RGBA_COLOR(192.0,0.0f,0.0f,1.0f)
#define LIGHTORANGE_COLOR RGBA_COLOR(254.0,203.0f,109.0f,1.0f)

#define iosdeviese if(@available(iOS 11.0, *)){_myTable.contentInsetAdjustmentBehavior =UIScrollViewContentInsetAdjustmentNever;_myTable.estimatedRowHeight = 0;_myTable.estimatedSectionHeaderHeight = 0;_myTable.estimatedSectionFooterHeight = 0;}

//防止Block中的self循环引用的宏定义
#define WS(blockSelf) __weak __typeof(&*self)blockSelf = self;


#define EMPTY_GUID @"00000000-0000-0000-0000-000000000000"

// SD is the selected disaster
#define SD [CustomAccount sharedCustomAccount].selectedDisaster
