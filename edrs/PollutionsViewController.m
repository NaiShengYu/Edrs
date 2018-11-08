//
//  PollutionListViewController.m
//  edrs
//
//  Created by 林鹏, Leon on 2017/10/19.
//  Copyright © 2017年 julyyu. All rights reserved.
//

#import "PollutionsViewController.h"
#import "SamplePlanModel.h"
#import "TaskDetailViewController.h"
#import "DisasterMapViewController.h"
#import "UploadViewController2.h"
@interface PollutionsViewController ()<UITableViewDelegate,UITableViewDataSource>


@property(nonatomic,strong) UITableView *tableView;
@end

@implementation PollutionsViewController


#pragma mark Method
-(void)getNearPlanModle{
 
    for (NSInteger i =0; i<_dataArray.count; i++) {
        SamplePlanModel *model = [_dataArray objectAtIndex:i];
        CLLocationCoordinate2D location = [AppDelegate sharedInstance].location2D;
        CLLocation *orig=[[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
        CLLocation* dist=[[CLLocation alloc] initWithLatitude:model.lat  longitude:model.lng];
        CLLocationDistance kilometers=[orig distanceFromLocation:dist]/1000;
        model.farmetter = kilometers;
        
    }
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"farmetter" ascending:YES];
    _dataArray =[_dataArray sortedArrayUsingDescriptors:@[descriptor]];
}

-(void)showMapViewAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    DisasterMapViewController *vc = [story instantiateViewControllerWithIdentifier:@"DisasterMapViewController"];
    vc.disasterId = self.did;
    vc.taskArray = self.dataArray;
    vc.hadLocation = _showLocationInfo;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark UIView
-(UITableView *)tableView{
    if(_tableView ==nil){
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}

-(void)configuerNavigationRightItem{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [button setImage:[UIImage imageNamed:@"add_white"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showMapViewAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *righrtItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = righrtItem;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"采样点列表";
    [Utility configuerNavigationBackItem:self];
    [self configuerNavigationRightItem];
    [self getNearPlanModle];
    [self.view addSubview:self.tableView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark UITableView Datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"pollutionListCell"];
    if(cell ==nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"pollutionListCell"];
    }
    
    SamplePlanModel *sampleModel = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text =  sampleModel.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f km",sampleModel.farmetter];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
 
    
    UploadViewController2  *uploadVC = [[UploadViewController2 alloc]init];
    uploadVC.taskArray =  _dataArray;
    uploadVC.did = self.did;
//    uploadVC.planModel = [self.dataArray objectAtIndex:indexPath.row];
    uploadVC.sampleModel = [_dataArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:uploadVC animated:YES];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
