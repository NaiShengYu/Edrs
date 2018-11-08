//
//  TaskViewController.m
//  VOC
//
//  Created by 林鹏, Leon on 2017/3/14.
//  Copyright © 2017年 林鹏, Leon. All rights reserved.
//

#import "TaskViewController.h"
#import "SamplePlanModel.h"
#import "MapViewController.h"
#import "TaskDetailViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "MJRefresh.h"
@interface TaskViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray *planList;
    UITableView *_tableView;
    NSInteger pageIndex;
    NSInteger  totals ;
}

@end

@implementation TaskViewController

#pragma mark Method
-(void)getSamplePlanList{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:[NSNumber numberWithInteger:pageIndex] forKey:@"pageIndex"];
    [[AppDelegate sharedInstance].httpTaskManager postWithPortPath:SAMPLE_LIST parameters:parameters onSucceeded:^(NSDictionary *dictionary) {
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        [tempArray addObjectsFromArray:planList];
        NSArray *array = [dictionary valueForKey:@"Items"];
        for (NSDictionary *sub in array ) {
            SamplePlanModel *model = [SamplePlanModel modelWithJSON:sub];
            [tempArray addObject:model];
        }
        totals = [[dictionary valueForKey:@"Totals"] intValue];
        
        
        planList = tempArray ;
        [_tableView.footer endRefreshing];
        [_tableView reloadData];
    } onError:^(NSError *engineError) {
    
    }];
}

-(void)showMapView{
    MapViewController *mapVc = [[MapViewController alloc]init];
    mapVc.planList = planList ;
    [self.navigationController pushViewController:mapVc animated:YES];
}
#pragma mark Uiveiw
-(void)initSubViews{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    _tableView.delegate = self ;
    _tableView.dataSource = self ;
    [self.view addSubview:_tableView];
}
-(void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [leftDrawerButton setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

-(void)leftDrawerButtonPress:(id)sender{
    [[AppDelegate sharedInstance].drawerVC toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}


-(void)configuerNavigationRightItem{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 40)];
    [button addTarget:self action:@selector(showMapView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"采样任务";
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupLeftMenuButton];
    [self configuerNavigationRightItem];
    [self initSubViews];
    
    @weakify(self);
    _tableView.footer  = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        
        if(planList.count == totals && totals>0){
             [_tableView.footer endRefreshingWithNoMoreData];
        }else{
            pageIndex = pageIndex +1;
            [self getSamplePlanList];
           
        }
       
    }];
}

-(void)viewWillAppear:(BOOL)animated{
     [super viewWillAppear:animated];
     [self getSamplePlanList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return planList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell className]];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[UITableViewCell className]];
    }
    
    
    SamplePlanModel *model = [planList objectAtIndex:[indexPath row]];
    cell.textLabel.text = model.name;
    if(model.status ==1){
        cell.detailTextLabel.text = @"应急";
        cell.detailTextLabel.textColor= LIGHT_RED;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    }
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
    TaskDetailViewController *detailVC = [[TaskDetailViewController alloc]init];
    detailVC.sampleModel = [planList objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
