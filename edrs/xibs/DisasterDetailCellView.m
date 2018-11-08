//
//  DisasterDetailCellView.m
//  edrs
//
//  Created by 余文君, July on 15/9/25.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "DisasterDetailCellView.h"

@implementation DisasterDetailCellView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)init{
    self.textLabels = [[NSMutableArray alloc]init];
    self.imageViews = [[NSMutableArray alloc]init];
    self.dataLabels = [[NSMutableArray alloc]init];
    self.specLabels = [[NSMutableArray alloc]init];
    self.loadingimgViews = [[NSMutableArray alloc]init];
    
    return [super init];
}
@end
