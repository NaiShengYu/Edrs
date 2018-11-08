//
//  UploadSpecTableViewController.h
//  edrs
//
//  Created by 余文君, July on 15/8/21.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectionTableViewController.h"
#import "PollutionMapViewController.h"
#import "ChemicalSearchViewController.h"
#import "WindsViewController.h"
#import "Constants.h"

@protocol UploadSpecDelegate <NSObject>

-(void)setWindsData:(NSString *)dict;
-(void)setDisasterNature:(NSMutableDictionary *)dict;
-(void)setPollutionLocation:(CLLocationCoordinate2D)coor;
-(void)setDisasterChemical:(NSMutableDictionary *)dict;

@end

@interface UploadSpecTableViewController : UITableViewController<SelectionDelegate,PollutionMapDelegate,ChemicalSearchDelegate,WindsDataDelegate>{
    NSMutableArray *mSpecSelectionArray;
}
@property (weak , nonatomic) NSArray *mChemicalsList;
@property (weak, nonatomic) id<UploadSpecDelegate> delegate;

@end
