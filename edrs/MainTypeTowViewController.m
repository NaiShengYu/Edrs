//
//  MainViewController.m
//  edrs
//
//  Created by 余文君, July on 15/8/13.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "MainTypeTowViewController.h"
#import "AppDelegate.h"
#import "MMDrawerBarButtonItem.h"
#import "DisasterAddViewController.h"
@interface MainTypeTowViewController (){
    NSArray *idList ;
}
@property (nonatomic,assign)BOOL haseMore;
@property (nonatomic,assign)NSInteger pageIndex;

@end

@implementation MainTypeTowViewController
-(UITableView *)mainTableView{
    if(_mainTableView == nil){
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT-64-44)];
        _mainTableView.delegate = self ;
        _mainTableView.dataSource = self ;
        
        //    //设置下拉刷新
        MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
        [header.lastUpdatedTimeLabel setHidden:YES];
        _mainTableView.header = header;
        
        MJRefreshBackGifFooter *footer = [MJRefreshBackGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(getMainData)];
        _mainTableView.footer = footer;
        
    }
    
    return _mainTableView;
}

-(void)showAddView{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    DisasterAddViewController *addVC = [story instantiateViewControllerWithIdentifier:@"DisasterAddViewController"];
    [self.navigationController pushViewController:addVC animated:YES];
}

-(void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [leftDrawerButton setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

-(void)configuerNavigationRightItem{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    [button setImage:[UIImage imageNamed:@"add_white"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showAddView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
}
-(void)leftDrawerButtonPress:(id)sender{
    [[AppDelegate sharedInstance].drawerVC toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _haseMore = YES;
    _pageIndex =0;
    mProgressingEventsArray=[[NSMutableArray alloc]init];
    self.view.backgroundColor = [UIColor whiteColor];
    [self configuerNavigationRightItem];
    [self.view addSubview:self.mainTableView];
    [self setupLeftMenuButton];
    [[AppDelegate sharedInstance] addObserver:self forKeyPath:@"list" options:NSKeyValueObservingOptionNew context:nil];
 
    timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkIsUpload) userInfo:nil repeats:YES];
    [timer fire];
    //获取数据
    
    [self performSelector:@selector(refreshData) withObject:nil afterDelay:0.2];
    
    //请获取当前用户的值班表
    //[self registerLocalNotificationForDuty];
    
    //tap
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyboardHide)];
    recognizer.delegate = self;
    [self.mainTableView addGestureRecognizer:recognizer];
    
    //预留空白清除
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    
    //title设置
    [self setTitle:@"应急"];
    
  
    
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [self refreshData];
}

-(void)dealloc{
    NSLog(@"dealloc");
    [[AppDelegate sharedInstance] removeObserver:self forKeyPath:@"list"];
}




-(void)uploadDisasterLoc:(NSArray *)list{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:list forKey:@"disasters"];
    [params setValue:[CustomAccount sharedCustomAccount].user.userId forKey:@"userid"];
    [params setValue: [NSNumber numberWithFloat:[AppDelegate sharedInstance].location2D.longitude] forKey:@"lng"];
    [params setValue:[NSNumber numberWithFloat:[AppDelegate sharedInstance].location2D.latitude] forKey:@"lat"];
    
    __weak MainTypeTowViewController *weakSelf = self ;
    [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@", EDRSHTTP, EDRSHTTP_GETDISASTER_UPLOAD_DISASTERLOC] params:params success:^(id responseObj) {
        NSLog(@"消息%@",[responseObj description]);
    } failure:^(NSError *err) {
        NSLog(@"fail to get disaster current list , error = %@", err);
    }];
}

-(void)checkIsUpload{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:[CustomAccount sharedCustomAccount].user.userId forKey:@"userid"];
    __weak MainTypeTowViewController *weakSelf = self ;
    [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@", EDRSHTTP, EDRSHTTP_GETDISASTER_UPLOAD] params:params success:^(id responseObj) {
        NSLog(@"消息mainViewcontroller%@",[responseObj description]);
        NSString *dataStr = [responseObj valueForKey:@"disaster"];
        if(dataStr.length>0){
            NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *list = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            [self uploadDisasterLoc:list];
        }
    } failure:^(NSError *err) {
        NSLog(@"fail to get disaster current list , error = %@", err);
    }];
}

-(void)showLocalNotification:(NSDictionary *)dic{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"注意！有新事故发生";
    notification.alertTitle = @"消息提示";
    notification.alertAction = nil;
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
}


- (void)refreshData{
    self.pageIndex =0;
    [self getMainData];
}
-(void)getMainData{
    
    NSString *page = [NSString stringWithFormat:@"%ld",(long)self.pageIndex];
    [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@",EDRSHTTP,EDRSHTTP_mainTypeTow] params:@{@"pageIndex":page} success:^(id responseObj) {
        NSLog(@"get main information successfully , response = %@", responseObj);
        if (self.pageIndex ==0) {
            [mProgressingEventsArray removeAllObjects];
        }
        for (NSDictionary *item in responseObj[@"Items"]) {
            [mProgressingEventsArray addObject:item];
        }
        
        //添加到用户信息缓存中
        NSMutableArray *curDisasterIds = [[NSMutableArray alloc]init];
        for (int i = 0; i < mProgressingEventsArray.count; i++) {
            [curDisasterIds addObject:mProgressingEventsArray[i][@"id"]];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:curDisasterIds forKey:[NSString stringWithFormat:@"%@%@",EDRS_UD_CURRENTDISASTERS,[CustomAccount sharedCustomAccount].user.userId]];
        
        //刷新页面
        [self.mainTableView reloadData];
        [self.mainTableView.header endRefreshing];
        if (mProgressingEventsArray.count >= [responseObj[@"Totals"] integerValue]) {
            [self.mainTableView.footer endRefreshingWithNoMoreData];
        }else{
              [self.mainTableView.footer endRefreshing];
            self.pageIndex +=1;
        }
    } failure:^(NSError *err) {

    }];

}

#pragma mark - 主页面tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
        return [mProgressingEventsArray count];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0;

}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
 
    return nil;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    //    if (indexPath.section == 0) {
    NSString *cellIdentifier_1 = @"mainDisasterTableViewCell";
    UITableViewCell *cell_1 = [tableView dequeueReusableCellWithIdentifier:cellIdentifier_1];
    if (cell_1 == nil) {
        cell_1 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier_1];
    }
        [cell_1.detailTextLabel setText:[CustomUtil getFormatedDateString:mProgressingEventsArray[indexPath.row][@"starttime"]]];
        [cell_1.textLabel setText:mProgressingEventsArray[indexPath.row][@"name"]];
        [cell_1.textLabel setTextColor:BLUE_COLOR];
        [cell_1.detailTextLabel setTextColor:BLUE_COLOR];
   
    
    [cell_1 setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell_1 setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell_1;
   
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        //突发事故
        NSDictionary *dict = @{@"id":mProgressingEventsArray[indexPath.row][@"id"], @"starttime":mProgressingEventsArray[indexPath.row][@"starttime"],@"address":mProgressingEventsArray[indexPath.row][@"address"],@"name":mProgressingEventsArray[indexPath.row][@"name"]};
        [self performSegueWithIdentifier:@"DisasterDetailSegue" sender:dict];
 
}


#pragma mark - 键盘
-(void)keyboardHide{
    [self.view endEditing:YES];
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    else{
        return YES;
    }
}



#pragma mark - searchbar
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    //获取keyword 搜索后跳转页面
    mSearchKeyword = [searchBar text];
    if (mSearchKeyword.length > 0) {
        [self performSegueWithIdentifier:@"MainSearchResultSegue" sender:self];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"MainSearchResultSegue"]) {
        //跳转－搜索结果
        MainSearchResultViewController *targetVC = [segue destinationViewController];
        [targetVC setValue:mSearchKeyword forKey:@"keyword"];
    }
    else if([segue.identifier isEqualToString:@"ChemicalListSegue"]){
        CommonListViewController *targetVC = [segue destinationViewController];
        targetVC.listType = @"Chemical";
        
    }
    else if([segue.identifier isEqualToString:@"PollutionListSegue"]){
        CommonListViewController *targetVC = [segue destinationViewController];
        targetVC.listType = @"Pollution";
    }
    else if([segue.identifier isEqualToString:@"DisasterDetailSegue"]){
        DisasterDetailViewController *targetVC = [segue destinationViewController];
        targetVC.did = sender[@"id"];
        targetVC.starttime = sender[@"starttime"];
        targetVC.address = sender[@"address"];
        targetVC.title =sender[@"name"];
    }
}

#pragma mark - LocalNotification & PushNotificaition
-(void)registerLocalNotificationForDuty{
    UILocalNotification *noti = [[UILocalNotification alloc]init];
    if (noti!=nil) {
        NSMutableDictionary *userinfo = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"scheduleLocal.EDRS", @"id", nil];
        noti.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
        noti.timeZone = [NSTimeZone defaultTimeZone];
        noti.alertBody = @"这是一条本地通知~~~";
        noti.alertAction= @"这是一条本地通知";
        noti.soundName = UILocalNotificationDefaultSoundName;
        noti.userInfo = userinfo;
        NSLog(@"通知呢！");
        
        UIUserNotificationType type = UIUserNotificationTypeAlert| UIUserNotificationTypeBadge| UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] scheduleLocalNotification:noti];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if(object == [AppDelegate sharedInstance]){
        if([keyPath isEqualToString:@"list"]){
            [self showLocalNotification:nil];
        }
    }
    
}


@end
