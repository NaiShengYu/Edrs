//
//  AppDelegate.m
//  edrs
//
//  Created by 余文君, July on 15/8/11.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "CustomHttp.h"
#import <AVFoundation/AVFoundation.h>
#import "YYKit.h"
#import "UIAlertView+Blocks.h"
#import "LeftMenuViewController.h"
#import "TaskViewController.h"
#import "LoginViewController.h"
#import "JZLocationConverter.h"
#import "MainViewController.h"
#import "MainTypeTowViewController.h"
@interface AppDelegate (){
    BOOL islogout;
}

@end
static AppDelegate *sharedInstance = nil ;
@implementation AppDelegate

+(AppDelegate*)sharedInstance{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

-(HttpTaskManager *)httpTaskManager{
    if(_httpTaskManager ==nil){
        _httpTaskManager = [HttpTaskManager manager];
        
    }
    return _httpTaskManager ;
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

-(void)setRootForMenu{
    islogout = NO;
    if(_drawerVC ==nil){
        NSLog(@"%@",[_drawerVC description]);
        LeftMenuViewController *leftVC = [[LeftMenuViewController alloc]init];
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
       // MainViewController *main = [story instantiateViewControllerWithIdentifier:@"MainViewController"];
        MainTypeTowViewController *main = [story instantiateViewControllerWithIdentifier:@"MainTypeTowViewController"];
    
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:main];
        nav.navigationBar.translucent = NO;
        _drawerVC = [[MMDrawerController alloc]initWithCenterViewController:nav leftDrawerViewController:leftVC];
        _drawerVC.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
        _drawerVC.closeDrawerGestureModeMask =MMCloseDrawerGestureModeAll;
        //5、设置左右两边抽屉显示的多少
        _drawerVC.maximumLeftDrawerWidth = 200.0;

    
    }
    
    self.window.rootViewController = _drawerVC;
    
}

-(void)closeMenu{
    [self.drawerVC setMaximumLeftDrawerWidth:0];
}
-(void)openMenu{
    [self.drawerVC setMaximumLeftDrawerWidth:200];
}
-(void)updataFromService{
    //获取当前正在发生的事故
//  SystemSoundID soundID = 1000;
//        
    __weak AppDelegate *weakSelf = self ;
    NSLog(@"%@",[CustomAccount sharedCustomAccount].user.userId);
    if([CustomAccount sharedCustomAccount].user.userId !=nil){
        [CustomHttp httpGet:[NSString stringWithFormat:@"%@%@", EDRSHTTP, EDRSHTTP_GETDISASTER_NEWDISASTER] params:@{@"userid":[CustomAccount sharedCustomAccount].user.userId} success:^(id responseObj) {
            NSLog(@"消息3333%@",[responseObj description]);
            if([[responseObj valueForKey:@"success"] intValue]==1){
                [weakSelf showLocalNotification:nil];
            }
            
         
        } failure:^(NSError *err) {
            NSLog(@"fail to get disaster current list , error = %@", err);
        }];
    }
}

-(void)checkNetworkStatus{
    //检测网络状态
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        NSLog(@"reachability:%@", AFStringFromNetworkReachabilityStatus(status));
        if (status == AFNetworkReachabilityStatusNotReachable) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AFNETWORKINGREACH" object:nil];
            return;
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotReachableNotification) name:@"AFNETWORKINGREACH" object:nil];
    
}

-(void)intialBaidu{
    _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:@"aafRciIU52zyqUUinpZlNwTGjF5IhQw0" generalDelegate:nil];
    if (!ret) {
        NSLog(@"manage start failed!");
    }
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    //启动LocationService
    [_locService startUserLocationService];
}

- (void)configuerNavigationBar{
    UINavigationBar * appearance = [UINavigationBar appearance];
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
    UIGraphicsBeginImageContext(lineImage.frame.size);
    [lineImage.image drawInRect:CGRectMake(0, 0, lineImage.frame.size.width, lineImage.frame.size.height)];
    CGMutablePathRef path = CGPathCreateMutable();

    CGRect rectangle = CGRectMake(0.0f, 0.0f,320.0f, 64.0f);
    CGPathAddRect(path,NULL, rectangle);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextAddPath(currentContext, path);

    [LIGHT_BLUE setFill];
    [LIGHT_BLUE setStroke];
   
    CGContextSetLineWidth(currentContext,0.1f);
   
    CGContextDrawPath(currentContext, kCGPathFillStroke);
    lineImage.image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *navBackgroundImg = lineImage.image;
    [appearance setBackgroundImage:navBackgroundImg forBarMetrics:UIBarMetricsDefault];
    [appearance setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kHelveticaBold size:20],
                                         NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    NSError *setCategoryErr = nil ;
//    NSError *activationErr = nil ;
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&setCategoryErr];
//    [[AVAudioSession sharedInstance] setActive:YES error:&activationErr];
//    _backTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startLister) userInfo:nil repeats:YES];
//    [_backTimer setFireDate:[NSDate distantFuture]];
  
    [self configuerNavigationBar];
    [self checkNetworkStatus];
    [self intialBaidu];
    
    //监控注册
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionLogOut:) name:LOGOUT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionLoginFailure:) name:LOGINFAILURE object:nil];
    
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(updataFromService) userInfo:nil repeats:YES];
//    [self.timer fire];
  
    //[self registerLocalNotificationForDuty];
    
    return YES;
}

-(void)setLoginForRoot{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    LoginViewController *loginVC = [story instantiateViewControllerWithIdentifier:@"LoginVC"];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:loginVC];
    self.window.rootViewController = nav;
}

-(void)actionLogOut:(NSNotification *)notification{
    [self setLoginForRoot];
}

-(void)actionLoginFailure:(NSNotification *)notification{
    if(!islogout){
        islogout = YES ;
        [SVProgressHUD showErrorWithStatus:@"登录失效，请重新登陆" afterDelay:2];
        [self setLoginForRoot];
    }
}
//-(void)startLister{
//    NSLog(@"在后台执行");
//    _count++;
//}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    UIApplication *app =[UIApplication sharedApplication];
//    __block UIBackgroundTaskIdentifier bgTask;
//    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if(bgTask != UIBackgroundTaskInvalid){
//                bgTask = UIBackgroundTaskInvalid;
//            }
//        });
//    }];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        if(bgTask != UIBackgroundTaskInvalid){
//            bgTask = UIBackgroundTaskInvalid;
//        }
//    });
//    [_backTimer setFireDate:[NSDate distantPast]];
//    _count =0 ;
    [_locService stopUserLocationService];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];    //清空提醒数字
   [_locService startUserLocationService];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
       [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [self getVersion];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)showUpdataAlerViewWith:(NSDictionary*)versionInfo{
    NSString *message = [versionInfo valueForKey:@"description"];
    [UIAlertView showAlertViewWithTitle:@"版本更新" message:message cancelButtonTitle:@"暂不更新" otherButtonTitles:@[@"确认更新"] onDismiss:^(int buttonIndex) {
        isShow = NO ;
        NSURL *url  = [NSURL URLWithString:@"https://itunes.apple.com/cn/app/id1054633745"];
        [[UIApplication sharedApplication] openURL:url];
    } onCancel:^{
        isShow = NO ;
    }];
    
}

- (void)getVersionSuccess:(NSDictionary *)responseDic{
    NSArray *array = [responseDic valueForKey:@"results"];
    NSDictionary *sub = nil;
    if(array.count==0){
        return ;
    }
    
    sub = [array objectAtIndex:0];
    NSString *newVersion = [sub valueForKey:@"version"];
    NSString *currentVersion = [UIApplication sharedApplication].appVersion;
    currentVersion = [currentVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    newVersion = [newVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if([newVersion intValue]>[currentVersion intValue]){
        if(!isShow){
            isShow = YES ;
            [self showUpdataAlerViewWith:sub];
        }
    }
}


- (void)getVersion{
  
    NSURL *url=[[NSURL alloc]initWithString:@"https://itunes.apple.com/cn/lookup?id=1249174916"];
    
    
    NSMutableData *postBody=[NSMutableData data];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:url
                                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                         timeoutInterval:20.0f];
    
    [request setHTTPMethod: @"GET"];
   
    [request setHTTPBody:postBody];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      // ...
                                      
                                      if(data !=nil){
                                          NSDictionary * responseDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                       
                                          [self getVersionSuccess:responseDic];
                                      }
                                      
                                      
                                  }];
    
    [task resume];
}
#pragma mark -   Local Notification & Push Notification
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"Recieve DiviceToken:%@", deviceToken);
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"fail to recieve devicetoken, error:%@",error);
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    //收到了本地通知
    NSLog(@"收到了本地通知");
    if(application.applicationState == UIApplicationStateActive){
        //如果想要模拟banner通知，请在此实现-。-
    }
}

-(void)receiveNotReachableNotification{
    [CustomUtil showMessage:@"网络无法连接，请重试"];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AFNETWORKINGREACH" object:nil];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "cn.net.luzern.edrs" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"edrs" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"edrs.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)didStopLocatingUser{
    
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation{
    
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
//    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    self.location2D = userLocation.location.coordinate;
}

@end
