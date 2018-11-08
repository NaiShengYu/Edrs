//
//  CustomeSearchView.m
//  ProjectDemo
//
//  Created by Nasheng Yu on 2018/1/12.
//  Copyright © 2018年 俞乃胜, Stephen. All rights reserved.
//

#import "CustomeSearchView.h"

@implementation CustomeSearchView

- (instancetype)initWithFrame:(CGRect)frame{
    self =[super initWithFrame:frame];
    if (self) {
        
        UIView *lineView =[[UIView alloc]initWithFrame:CGRectMake(0, frame.size.height-1, frame.size.width, 1)];
        lineView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self addSubview:lineView];
        
    }
    
    return self;
    
}

- (void)setContentInset:(UIEdgeInsets )contentInset{
 
    
     _contentInset.top = contentInset.top;
     _contentInset.bottom = contentInset.bottom;
     _contentInset.left = contentInset.left;
     _contentInset.right = contentInset.right;
     
     self.isChangeFrame = YES;
     [self layoutSubviews];
    

    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    for (UIView *subView in self.subviews[0].subviews) {
        
        if ([subView isKindOfClass:[UIImageView class]]) {
            
            //移除UISearchBarBackground
            [subView removeFromSuperview];
        }
        if ([subView isKindOfClass:[UITextField class]]) {
            
            CGFloat height = self.bounds.size.height;
            CGFloat width = self.bounds.size.width;
            
            if (_isChangeFrame) {
                //说明contentInset已经被赋值
                // 根据contentInset改变UISearchBarTextField的布局
                subView.frame = CGRectMake(_contentInset.left, _contentInset.top, width - 2 * _contentInset.left, height - 2 * _contentInset.top);
            } else {
            
                // contentSet未被赋值
                // 设置UISearchBar中UISearchBarTextField的默认边距
                CGFloat top = (height - 28.0) / 2.0;
                CGFloat bottom = top;
                CGFloat left = 8.0;
                CGFloat right = left;
                _contentInset = UIEdgeInsetsMake(top, left, bottom, right);
            }

            
        }
    }
  
}



@end
