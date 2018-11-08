//
//  DetailViewController.h
//  edrs
//
//  Created by 余文君, July on 15/8/18.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property NSString *dName;
@property NSString *dLabel;
@property NSString *dContent;

@property (weak, nonatomic) IBOutlet UILabel *labelLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

@end
