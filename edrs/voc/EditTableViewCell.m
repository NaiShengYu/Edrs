//
//  EditTableViewCell.m
//  edrs
//
//  Created by 林鹏, Leon on 2017/6/5.
//  Copyright © 2017年 julyyu. All rights reserved.
//

#import "EditTableViewCell.h"

@implementation EditTableViewCell


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self= [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-80, 46)];
        [self addSubview:_titleLabel];
        
        
        _deleteButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-60, 5, 60, 40)];
        [_deleteButton setImage:[UIImage imageNamed:@"btn_picker_close_select_h"] forState:UIControlStateNormal];
        [self addSubview:_deleteButton];
    }
    
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
