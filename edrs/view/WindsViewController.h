//
//  WindsViewController.h
//  edrs
//
//  Created by bchan on 15/12/28.
//  Copyright © 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WindsDataDelegate <NSObject>

-(void)setWindsData:(NSString *)dict;

@end

@interface WindsViewController : UIViewController

@property (weak, nonatomic) id<WindsDataDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *windDirectTextField;
@property (weak, nonatomic) IBOutlet UITextField *windSpeedTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitButton;
- (IBAction)actionSubmitWindsData:(id)sender;

@end
