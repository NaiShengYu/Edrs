//
//  InputTableViewCell.h
//  VOC
//
//  Created by 林鹏, Leon on 2017/3/21.
//  Copyright © 2017年 林鹏, Leon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SourceFactorModel.h"

@protocol InputTableViewCellDelete

-(void)textFieldEndInput:(NSString *)factorId  content:(NSString *)content;
-(void)textFieldEndInputAtIndex:(NSInteger)index;
@end
@interface InputTableViewCell : UITableViewCell<UITextFieldDelegate>


@property(nonatomic,weak) id<InputTableViewCellDelete>delegate ;
@property(nonatomic,weak) IBOutlet UILabel *titleLB ;
@property(nonatomic,weak) IBOutlet UILabel *subTitleLB ;
@property(nonatomic,weak) IBOutlet UITextField *textField;

@property(nonatomic,unsafe_unretained) NSInteger index;
@property(nonatomic,strong) SourceFactorModel *model ;

@end
