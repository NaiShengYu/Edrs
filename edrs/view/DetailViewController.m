//
//  DetailViewController.m
//  edrs
//
//  Created by 余文君, July on 15/8/18.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Utility configuerNavigationBackItem:self];
    NSAttributedString *attrStr = [[NSAttributedString alloc]initWithData:[self.dContent dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    
    [self.navigationItem setTitle:self.dName];
    [self.labelLabel setText:self.dLabel];
    [self.contentTextView setAttributedText:attrStr];
    
    [self.contentTextView setFont:[UIFont systemFontOfSize:17.0f]];
    [self.contentTextView setTextColor:[UIColor grayColor]];
    [self.contentTextView setTextContainerInset:UIEdgeInsetsMake(15, 15, 15, 15)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
