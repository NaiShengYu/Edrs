//
//  ChemicalTestMethodViewController.m
//  edrs
//
//  Created by 余文君, July on 15/9/20.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "ChemicalTestMethodViewController.h"

@interface ChemicalTestMethodViewController ()

@end

@implementation ChemicalTestMethodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Utility configuerNavigationBackItem:self];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    style.firstLineHeadIndent = 10;
    style.headIndent = 10;
    style.tailIndent = -10;
    
    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@",EDRSHTTP, EDRSHTTP_GETCHEMICAL_TEST_DETAIL]
                 params:@{@"id":self.mid}
                success:^(id responseObj) {
                    NSLog(@"get chemical's methods successfully, response = %@", responseObj);
                    
                    NSMutableAttributedString *namestr = [[NSMutableAttributedString alloc]initWithString:responseObj[@"name"]];
                    [namestr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0,namestr.length)];
                    
                    [self.methodNameLabel setAttributedText:namestr];
                    
                    NSMutableAttributedString *equipstr = [[NSMutableAttributedString alloc]initWithString:self.equipcls];
                    [equipstr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, equipstr.length)];
                    
                    [self.equipmentLabel setAttributedText:equipstr];
                    
                    if(self.equipcls.length > 0){
                        mRemarksTextView = [[UITextView alloc]initWithFrame:CGRectMake(0, self.equipmentLabel.frame.size.height + self.equipmentLabel.frame.origin.y + 1, SCREEN_WIDTH , self.view.frame.size.height - self.equipmentLabel.frame.size.height - self.equipmentLabel.frame.origin.y)];
                        NSMutableAttributedString *htmlStr = [[NSMutableAttributedString alloc]initWithData:[responseObj[@"remarks"] dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
                        [htmlStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, htmlStr.length)];
                        [mRemarksTextView setAttributedText:htmlStr];
                        [mRemarksTextView setEditable:NO];
                        [self.view addSubview:mRemarksTextView];
                    }
                    
    }
                failure:^(NSError *err) {
                    NSLog(@"fail to get chemical's methods , error = %@", err);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
