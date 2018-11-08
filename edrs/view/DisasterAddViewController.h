//
//  DisasterAddViewController.h
//  edrs
//
//  Created by bchan on 16/3/22.
//  Copyright © 2016年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomUtil.h"
#import "CustomHttp.h"

@protocol DisasterAddDelegate <NSObject>

-(void)addNewDisasterSuccess;

@end

@interface DisasterAddViewController : UIViewController{
    NSArray *disasterNatureList;
    NSString *selectedNature;
}

@property (weak, nonatomic) id<DisasterAddDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextField *mDisasterName;

- (IBAction)actionDisasterAdd:(id)sender;

@end
