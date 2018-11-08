//
//  ChemicalDetailViewController.h
//  edrs
//
//  Created by 余文君, July on 15/8/14.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomHttp.h"
#import "Chemical.h"
#import "CellModel.h"
#import "CommonDefinition.h"
#import "CustomUtil.h"
#import "DetailViewController.h"
#import "MBProgressHUD.h"
#import "ChemicalTestMethodViewController.h"

@interface ChemicalDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    Chemical *mChemical;
    
    
    NSMutableArray *mBaseinfo;
    NSMutableArray *mProperty;
    
    NSMutableArray *mTestMethods;
    
}

@property NSString *cid;
@property (weak, nonatomic) IBOutlet UITableView *chemicalDetailTableView;

-(void)getChemicalDetailData;
-(void)chemicalToArrays;

@end
