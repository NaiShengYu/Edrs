//
//  MainViewController.m
//  edrs
//
//  Created by 余文君, July on 15/8/13.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "MMDrawerBarButtonItem.h"
#import "DisasterAddViewController.h"
@interface MainViewController (){
    NSArray *idList ;
    NSArray *mDisasterAllList;
}

@end

@implementation MainViewController
-(UITableView *)mainTableView{
    if(_mainTableView == nil){
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT-64-44)];
        _mainTableView.delegate = self ;
        _mainTableView.dataSource = self ;
        
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
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self configuerNavigationRightItem];
    [self.view addSubview:self.mainTableView];
    [self setupLeftMenuButton];
    [[AppDelegate sharedInstance] addObserver:self forKeyPath:@"list" options:NSKeyValueObservingOptionNew context:nil];
//    NSData *cookieData = [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionCookies"];
//    if ([cookieData length]) {
//        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookieData];
//        NSHTTPCookie *cookie;
//        for (cookie in cookies) {
//            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
//        }
//    }
    timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkIsUpload) userInfo:nil repeats:YES];
    [timer fire];
    //获取数据
  
    [self performSelector:@selector(getMainData) withObject:nil afterDelay:0.2];
    
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
    
//    //设置下拉刷新
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(getMainData)];
    [header.lastUpdatedTimeLabel setHidden:YES];
    self.mainTableView.header = header;
}

-(void)viewWillAppear:(BOOL)animated{
    [self getMainData];
} 

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    __weak MainViewController *weakSelf = self ;
    [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@", EDRSHTTP, EDRSHTTP_GETDISASTER_UPLOAD_DISASTERLOC] params:params success:^(id responseObj) {
        NSLog(@"消息%@",[responseObj description]);
    } failure:^(NSError *err) {
        NSLog(@"fail to get disaster current list , error = %@", err);
    }];
}

-(void)checkIsUpload{
     NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
     [params setValue:[CustomAccount sharedCustomAccount].user.userId forKey:@"userid"];
    __weak MainViewController *weakSelf = self ;
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

-(void)getHistoryData{
    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@", EDRSHTTP, EDRSHTTP_GETDISASTER_ALL] params:@{@"stationid":[CustomAccount sharedCustomAccount].user.stationId} success:^(id responseObj) {
        NSLog(@"get disaster all list successfully, response = %@", responseObj);
        //获取历史事故
        mDisasterAllList = responseObj;
        NSMutableArray *tmparr = [[NSMutableArray alloc]init];
        for (int i = 0; i < mDisasterAllList.count; i++) {
            [tmparr addObject:mDisasterAllList[i][@"id"]];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:tmparr forKey:[NSString stringWithFormat:@"%@%@",EDRS_UD_DISASTERS,[CustomAccount sharedCustomAccount].user.userId]];
        
        [self.mainTableView reloadData];
        [self.mainTableView.header endRefreshing];
    } failure:^(NSError *err) {
        NSLog(@"fail to get disaster all list , error = %@", err);
    }];
}

-(void)getMainData{
    
    [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@", EDRSHTTP, EDRSHTTP_INDEX] params:@{} success:^(id responseObj) {
        
        //NSString *str = [[NSString alloc]initWithData:responseObj encoding:NSUTF8StringEncoding];
        
        NSLog(@"get main information successfully , response = %@", responseObj);
        mProgressingEventsArray=nil;
        mProgressingEventsArray = [[NSMutableArray alloc]initWithArray:responseObj[@"CurrentDisasters"]];
//        NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:responseObj[@"DataCounts"]];
        
        /*
        mDatasCateArray = [[NSMutableArray alloc]initWithObjects:@"化学品",@"污染源",@"设备",@"突发事件", nil];
        mDatasCountArray =[[NSMutableArray alloc]init];
        if(dict[@"Chemical"]){
             [mDatasCountArray addObject:dict[@"Chemical"]];
        }else{
             [mDatasCountArray addObject:@"0"];
        }
        if(dict[@"Pollution"]){
           [mDatasCountArray addObject:dict[@"Pollution"]];
        }else{
            [mDatasCountArray addObject:@"0"];
        }
        if(dict[@"Equipment"]){
            [mDatasCountArray addObject:dict[@"Equipment"]];
        }else{
            [mDatasCountArray addObject:@"0"];
        }
        if(dict[@"Disaster"]){
             [mDatasCountArray addObject:dict[@"Disaster"]];
        }else{
            [mDatasCountArray addObject:@"0"];
        }*/
       
        
        //添加到用户信息缓存中
        NSMutableArray *curDisasterIds = [[NSMutableArray alloc]init];
        for (int i = 0; i < mProgressingEventsArray.count; i++) {
            [curDisasterIds addObject:mProgressingEventsArray[i][@"id"]];
        }
        
        
        [[NSUserDefaults standardUserDefaults] setObject:curDisasterIds forKey:[NSString stringWithFormat:@"%@%@",EDRS_UD_CURRENTDISASTERS,[CustomAccount sharedCustomAccount].user.userId]];
        
        //刷新页面
        [self.mainTableView reloadData];
        [self.mainTableView.header endRefreshing];
    } failure:^(NSError *err) {
        NSLog(@"fail to get main info , error = %@", err);
    }];
    
    [self getHistoryData];
    
}

#pragma mark - 主页面tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return [mProgressingEventsArray count];
    }else{
        return mDisasterAllList.count;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0 && mProgressingEventsArray.count == 0) {
        return 0;
    }
    else{
        return 25.0f;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 25.0f)];
    [view setBackgroundColor:LIGHT_GRAN];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.f, 0, self.view.frame.size.width, 25.0f)];
    [view addSubview:label];
    if (section == 0) {
        [label setText:@"  处理中的事故"];
    }
    else if(section == 1){
        [label setText:@"  历史事故"];
    }
    else{
        [label setText:nil];
    }
    label.textColor = [UIColor blackColor];
    
//    CAShapeLayer *layer = [CAShapeLayer new];
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    
//    
//    [path moveToPoint:CGPointMake(0, 24)];
//    [path addLineToPoint:CGPointMake(SCREEN_WIDTH, 24)];
//
//    path.lineWidth = 1;
//    layer.path = path.CGPath;
//    layer.strokeColor = RGBACOLOR(213, 213, 213, 1).CGColor;
//    layer.shadowOffset = CGSizeMake(0, -1);
//    [label.layer addSublayer:layer];
    return view;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    
//    if (indexPath.section == 0) {
        NSString *cellIdentifier_1 = @"mainDisasterTableViewCell";
        UITableViewCell *cell_1 = [tableView dequeueReusableCellWithIdentifier:cellIdentifier_1];
        if (cell_1 == nil) {
            cell_1 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier_1];
        }
        if(indexPath.section ==0){
            [cell_1.detailTextLabel setText:[CustomUtil getFormatedDateString:mProgressingEventsArray[indexPath.row][@"starttime"]]];
            [cell_1.textLabel setText:mProgressingEventsArray[indexPath.row][@"name"]];
            [cell_1.textLabel setTextColor:BLUE_COLOR];
            [cell_1.detailTextLabel setTextColor:BLUE_COLOR];
        }else{
            [cell_1.detailTextLabel setText:[CustomUtil getFormatedDateString:mDisasterAllList[indexPath.row][@"starttime"]]];
            [cell_1.textLabel setText:mDisasterAllList[indexPath.row][@"name"]];
            [cell_1.textLabel setTextColor:[UIColor darkGrayColor]];
            [cell_1.detailTextLabel setTextColor:[UIColor darkGrayColor]];
        }
        
        [cell_1 setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell_1 setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        return cell_1;
//    }
//    else{
        /*
        NSString *cellIdentifier_2 = @"mainInfoTableViewCell";
        
        UITableViewCell *cell_2 = [tableView dequeueReusableCellWithIdentifier:cellIdentifier_2];
        
        if (cell_2 == nil) {
            cell_2 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier_2];
        }
        else{
            while ([[cell_2.contentView subviews] lastObject]) {
                [[[cell_2.contentView subviews] lastObject] removeFromSuperview];
            }
        }
        [cell_2.textLabel setText:mDatasCateArray[indexPath.row]];
        [cell_2.textLabel setTextColor:[UIColor blackColor]];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 100, 8, 58, 28)];
        [label setBackgroundColor:BLUE_COLOR];
        [label setTextColor:[UIColor whiteColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        
        [label.layer setMasksToBounds:YES];
        [label.layer setCornerRadius:14];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
        [label setText:[formatter stringFromNumber:mDatasCountArray[indexPath.row]]];
        [cell_2.contentView addSubview:label];
        
        [cell_2 setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell_2 setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
         */
//        return cell_2;
//    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        //突发事故
        NSDictionary *dict = @{@"id":mProgressingEventsArray[indexPath.row][@"id"], @"starttime":mProgressingEventsArray[indexPath.row][@"starttime"],@"address":mProgressingEventsArray[indexPath.row][@"address"],@"name":mProgressingEventsArray[indexPath.row][@"name"]};
        [self performSegueWithIdentifier:@"DisasterDetailSegue" sender:dict];
    }else{
        NSDictionary *dict = @{@"id":mDisasterAllList[indexPath.row][@"id"], @"starttime":mDisasterAllList[indexPath.row][@"starttime"],@"address":mDisasterAllList[indexPath.row][@"address"]};
        [self performSegueWithIdentifier:@"DisasterDetailSegue" sender:dict];
    }
    
    /*
    else{
        if (indexPath.row == 0) {
            //化学品
            [self performSegueWithIdentifier:@"ChemicalListSegue" sender:self];
        }
        else if(indexPath.row == 1){
            //污染源
            [self performSegueWithIdentifier:@"PollutionListSegue" sender:self];
        }
        else if(indexPath.row == 2){
            //设备
            [self performSegueWithIdentifier:@"EquipmentListSegue" sender:self];
        }
        else if(indexPath.row == 3){
            //突发事故
            [self performSegueWithIdentifier:@"DisasterListSegue" sender:self];
        }
        else{
            
        }
    }*/
    
    
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
