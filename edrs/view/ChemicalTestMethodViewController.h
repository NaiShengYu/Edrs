//
//  ChemicalTestMethodViewController.h
//  edrs
//
//  Created by 余文君, July on 15/9/20.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomHttp.h"
#import "CommonDefinition.h"

@interface ChemicalTestMethodViewController : UIViewController{
    UITextView *mRemarksTextView;
}

@property (weak, nonatomic) NSString *mid;
@property (weak, nonatomic) NSString *equipcls;

@property (weak, nonatomic) IBOutlet UILabel *methodNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *equipmentLabel;

@end
