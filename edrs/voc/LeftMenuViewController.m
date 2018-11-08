//
//  LeftMenuViewController.m
//  VOC
//
//  Created by 林鹏, Leon on 2017/3/14.
//  Copyright © 2017年 林鹏, Leon. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "CustomAccount.h"
#import "TaskViewController.h"
#import "MainViewController.h"
#import "MainTypeTowViewController.h"
#import "SettingsTableViewController.h"
#import "EquipmentListViewController.h"
#import "SuccessfulCasesListViewController.h"//成功案例列表
#import "EmergencyPlanListViewController.h"
#import "MonitoringMethodViewController.h"//监测方法
#import "EnvironmentalStandardsViewController.h"//环境标准

#import "InputBatchModel.h"
#import "UploadViewController2.h"
#import "QRCodeReaderViewController.h"
#import "StandardListViewController.h"
@interface LeftMenuViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView ;
    NSIndexPath *currentIndexPath;
}

@end

@implementation LeftMenuViewController

-(NSArray *)imageArray{
    return @[@[@"menu2"],@[@"menu1"],@[@"menu3",@"menu4",@"menu5",@"menu4",@"menu5",@"",@""],@[@"menu6",@"qrcode"]];
}
-(NSArray *)titlesArray{
    return @[@[@"应急"],@[@"采样任务"],@[@"污染源",@"化学品",@"设备",@"成功案例",@"应急方案",@"监测方法库",@"环境质量标准"],@[@"设置",@"扫描"]];
}
-(UIView *)headView{
    UIView *view =[[ UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 180)];
    {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 150, 100)];
        label.text =  [CustomAccount sharedCustomAccount].user.stationName;
        label.numberOfLines = 3;
        label.font = [UIFont boldSystemFontOfSize:17];
        [view addSubview:label];
    }
    {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 110, 150, 40)];
        label.text =  [CustomAccount sharedCustomAccount].user.userName;
        [view addSubview:label];
    }
    
//    UIImageView *imageVeiw = [[UIImageView alloc]initWithFrame:view.bounds];
//    imageVeiw.image = [UIImage imageNamed:@"1024x748"];
//    [view addSubview:imageVeiw];
    
    return view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self ;
    _tableView.dataSource = self ;
    _tableView.tableHeaderView = [self headView];
    [self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *array = [self titlesArray];
    NSArray *items = [array objectAtIndex:section];
    return items.count ;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell className]];
    if(cell ==nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[UITableViewCell className]];
    }
    NSArray *array = [self titlesArray];
    NSArray *items = [array objectAtIndex:indexPath.section];
    cell.textLabel.text =[items objectAtIndex:indexPath.row];
    NSArray *images = [[self imageArray] objectAtIndex:indexPath.section];
    cell.imageView.image = [UIImage imageNamed:[images objectAtIndex:indexPath.row]];
    return cell ;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if(indexPath != currentIndexPath){
         UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        currentIndexPath = indexPath ;
        if(indexPath.section ==0){
//            MainViewController *main = [story instantiateViewControllerWithIdentifier:@"MainViewController"];
//            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:main];
//            nav.navigationBar.translucent =NO;
//            [[AppDelegate sharedInstance].drawerVC setCenterViewController:nav];
            
            MainTypeTowViewController *main = [story instantiateViewControllerWithIdentifier:@"MainTypeTowViewController"];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:main];
            nav.navigationBar.translucent =NO;
            [[AppDelegate sharedInstance].drawerVC setCenterViewController:nav];
        
        }else if(indexPath.section ==1){
            TaskViewController *taskVC = [[TaskViewController alloc]init];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:taskVC];
            nav.navigationBar.translucent =NO;
            [[AppDelegate sharedInstance].drawerVC setCenterViewController:nav];
      
        }else if(indexPath.section ==2){
            if (indexPath.row ==0) {
                //跳转－搜索结果
                CommonListViewController *targetVC = [story instantiateViewControllerWithIdentifier:@"CommonListViewController"];
                targetVC.listType = @"Pollution";
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:targetVC];
                nav.navigationBar.translucent =NO;
                [[AppDelegate sharedInstance].drawerVC setCenterViewController:nav];
            
            }
            else if(indexPath.row ==1){
              
                CommonListViewController *targetVC = [story instantiateViewControllerWithIdentifier:@"CommonListViewController"];
                targetVC.listType = @"Chemical";
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:targetVC];
                nav.navigationBar.translucent =NO;
                [[AppDelegate sharedInstance].drawerVC setCenterViewController:nav];
                
            }
            else if(indexPath.row ==2){
            
                EquipmentListViewController *searchVC = [story instantiateViewControllerWithIdentifier:@"EquipmentListViewController"];
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:searchVC];
                nav.navigationBar.translucent =NO;
                [[AppDelegate sharedInstance].drawerVC setCenterViewController:nav];
            }
            else if(indexPath.row ==3){
                //成功案例
                SuccessfulCasesListViewController *casesListVC =[[SuccessfulCasesListViewController alloc]init];
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:casesListVC];
                nav.navigationBar.translucent =NO;
                [[AppDelegate sharedInstance].drawerVC setCenterViewController:nav];
            }
            else if (indexPath.row ==4){
                EmergencyPlanListViewController *casesListVC =[[EmergencyPlanListViewController alloc]init];
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:casesListVC];
                nav.navigationBar.translucent =NO;
                [[AppDelegate sharedInstance].drawerVC setCenterViewController:nav];                
            }
            else if (indexPath.row ==5){
                MonitoringMethodViewController *casesListVC =[[MonitoringMethodViewController alloc]init];
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:casesListVC];
                nav.navigationBar.translucent =NO;
                [[AppDelegate sharedInstance].drawerVC setCenterViewController:nav];
            }
            else if (indexPath.row ==6){
                EnvironmentalStandardsViewController *casesListVC =[[EnvironmentalStandardsViewController alloc]init];
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:casesListVC];
                nav.navigationBar.translucent =NO;
                [[AppDelegate sharedInstance].drawerVC setCenterViewController:nav];
            }
            
//            else if(indexPath.row ==3){
//                
//                StandardListViewController *standardVC = [[StandardListViewController alloc]init];
//                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:standardVC];
//                nav.navigationBar.translucent =NO;
//                [[AppDelegate sharedInstance].drawerVC setCenterViewController:nav];
//            }
            
        }else{
            if(indexPath.row==0){
                SettingsTableViewController *settingVC = [story instantiateViewControllerWithIdentifier:@"SettingsTableViewController"];
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:settingVC];
                nav.navigationBar.translucent =NO;
                [[AppDelegate sharedInstance].drawerVC setCenterViewController:nav];
            }else{
                QRCodeReaderViewController *qrVC =[[QRCodeReaderViewController alloc]init];
                qrVC.isMenu =YES;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:qrVC];
                [[AppDelegate sharedInstance].drawerVC setCenterViewController:nav];
            }
        }
    }
   [[AppDelegate sharedInstance].drawerVC toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}


//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    NSArray *titles = @[@"采样",@"应急",@"基础数据库",@"设置"] ;
//    return [titles objectAtIndex:section];
//}
@end
