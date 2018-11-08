//
//  InputTableViewCell.m
//  VOC
//
//  Created by 林鹏, Leon on 2017/3/21.
//  Copyright © 2017年 林鹏, Leon. All rights reserved.
//

#import "InputTableViewCell.h"

@implementation InputTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setModel:(SourceFactorModel *)model{
    _model = model ;
    self.titleLB.text = model.name ;
    NSString *content = nil ;
    
    if([model.name isEqualToString:@"检测项目"] ||[model.name isEqualToString:@"采样时间"]||[model.name isEqualToString:@"固定剂"]||[model.name isEqualToString:@"现场照片"]||[model.name isEqualToString:@"二维码"]  ){
        _textField.hidden = YES ;
        _subTitleLB.hidden = NO;
    }else{
        _textField.hidden = NO;
        _subTitleLB.hidden = YES;
    }
    if([ModelLocator sharedInstance].uploadDic){
        content = [[ModelLocator sharedInstance].uploadDic valueForKey:model.id];
    }
   
    if(content){
        _textField.text = content;
    }
    

}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self.delegate textFieldEndInput:_model.id content:_textField.text];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.delegate textFieldEndInputAtIndex:_index];
    return YES ;
}
@end
