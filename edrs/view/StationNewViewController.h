//
//  StationNewViewController.h
//  edrs
//
//  Created by 余文君, July on 15/8/13.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomHttp.h"

@protocol StationNewDelegate <NSObject>
-(void)setStationNew:(NSMutableDictionary *)station;
@end

@interface StationNewViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *stationUriTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicatorView;
@property NSObject<StationNewDelegate> *delegate;

- (void)actionSubmit:(id)sender;

@end
