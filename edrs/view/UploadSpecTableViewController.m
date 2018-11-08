//
//  UploadSpecTableViewController.m
//  edrs
//
//  Created by 余文君, July on 15/8/21.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "UploadSpecTableViewController.h"

@interface UploadSpecTableViewController ()

@end

@implementation UploadSpecTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Utility configuerNavigationBackItem:self];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"PropertySelectSegue"]) {
        SelectionTableViewController *targetVC = segue.destinationViewController;
        //获取plist中的数据
        NSMutableArray *array = [[NSMutableArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DisasterNature" ofType:@"plist"]];
        NSLog(@"plist array = %@", array);
        targetVC.selectionArray = array;
        targetVC.isSpecial = @"1";
        targetVC.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"PollutionLocationSelectSegue"]){
        PollutionMapViewController *targetVC = segue.destinationViewController;
        targetVC.delegate = self;
        
    }
    else if([segue.identifier isEqualToString:@"DisasterChemicalSegue"]){
        ChemicalSearchViewController *targetVC = segue.destinationViewController;
        targetVC.mChemicalsList = self.mChemicalsList;
        targetVC.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"WindsDataSegue"]){
        WindsViewController *targetVC = segue.destinationViewController;
        targetVC.delegate = self;
    }
}
-(void)dealloc{
    NSLog(@"dealloc");
}

#pragma mark - 回调委托

-(void)setSelectedValue:(NSString *)sid content:(NSString *)cont{
    NSLog(@"事故性质回传，选择%@",cont);
    
    NSMutableDictionary *tmpdict = [[NSMutableDictionary alloc]init];
    [tmpdict setObject:sid forKey:@"id"];
    [tmpdict setObject:cont forKey:@"value"];
    
    [self.delegate setDisasterNature:tmpdict];
}

-(void)setPollutionLocation:(CLLocationCoordinate2D)coor{
    NSLog(@"污染源位置，lat=%f, lng=%f", coor.latitude, coor.longitude);
    [self.delegate setPollutionLocation:coor];
}

-(void)setDisasterChemical:(NSMutableDictionary *)dict{
    [self.delegate setDisasterChemical:dict];
}

-(void)setWindsData:(NSString *)dict{
    [self.delegate setWindsData:dict];
}

@end
