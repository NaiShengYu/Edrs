//
//  TaskTableViewCell.m
//  VOC
//
//  Created by 林鹏, Leon on 2017/3/17.
//  Copyright © 2017年 林鹏, Leon. All rights reserved.
//

#import "TaskTableViewCell.h"

@implementation TaskTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self !=nil){
        _titleLB = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 100, 30)];
        _titleLB.numberOfLines = 99;
        _titleLB.font = [UIFont boldSystemFontOfSize:14];
        [self addSubview:_titleLB];
        
//        _subTitleLB = [[UILabel alloc]initWithFrame:CGRectMake(120, 10, SCREEN_WIDTH-120, 20)];
//        _subTitleLB.font = [UIFont systemFontOfSize:14];
//        [self addSubview:_subTitleLB];
        
        _itemListView = [[UIView alloc]initWithFrame:CGRectMake(120, 10, SCREEN_WIDTH-120, 50)];
        
        [self addSubview:_itemListView];
    }
    
    return  self ;
}

-(void)setCellInfoWith:(PlantTaskModel *)model{
    _titleLB.text = model.name ;
    if(model.anatype.count==0){
       _titleLB.frame = CGRectMake(10, 5, 100, 30) ;
    }else{
       _titleLB.frame = CGRectMake(10, 10, 100, model.anatype.count*25+10) ;
    }
    
    
    [_itemListView.subviews  makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if(model.anatype.count !=0){
        _itemListView.frame = CGRectMake(120, 10, SCREEN_WIDTH-120, model.anatype.count*25);
        for (NSInteger i = 0; i<model.anatype.count; i++) {
            NSDictionary *subDic = [model.anatype objectAtIndex:i];
            UILabel *label= [[UILabel alloc]initWithFrame:CGRectMake(0, i*25, _itemListView.width, 20)];
            label.text = [NSString stringWithFormat:@"-%@",[subDic valueForKey:@"name"]];
            label.font = [UIFont systemFontOfSize:13];
            label.textColor = [UIColor darkGrayColor];
            [_itemListView addSubview:label];
        }
    }else{
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
