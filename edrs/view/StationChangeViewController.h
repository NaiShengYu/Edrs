//
//  StationChangeViewController.h
//  edrs
//
//  Created by 余文君, July on 15/8/13.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StationNewViewController.h"
#import "CustomUtil.h"

@protocol StationChangeDelegate <NSObject>
-(void)setStationChange:(NSMutableDictionary *)station;
@end


@interface StationChangeViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, StationNewDelegate>{
    NSMutableArray *mStationsArray;
}

@property (weak, nonatomic) NSString *selectedStationId;
@property (weak, nonatomic) IBOutlet UITableView *stationsTableView;
@property NSObject<StationChangeDelegate> *delegate;

@end
