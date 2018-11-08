//
//  UploadTableViewCell.m
//  edrs
//
//  Created by 余文君, July on 15/9/16.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "UploadTableViewCell.h"

@implementation UploadTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
    }
    return self;
}

-(void)setBaseinfoLabel:(UILabel *)baseinfoLabel{
    NSLog(@"%@", baseinfoLabel.text);
}
@end
