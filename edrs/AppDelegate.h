//
//  AppDelegate.h
//  edrs
//
//  Created by 余文君, July on 15/8/11.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AFNetworkReachabilityManager.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import "CustomUtil.h"
#import "HttpTaskManager.h"
#import "MMDrawerController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,BMKLocationServiceDelegate,CLLocationManagerDelegate>{
    BMKMapManager *_mapManager;
    BMKLocationService *_locService;
    
    
    NSInteger _count;
    NSTimer *_backTimer;
    BOOL isShow;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSArray *list;
@property (strong ,nonatomic) NSTimer *timer;
@property (strong, nonatomic) MMDrawerController *drawerVC;
@property (strong, nonatomic) HttpTaskManager *httpTaskManager;
@property (unsafe_unretained ,nonatomic) CLLocationCoordinate2D location2D;
+(AppDelegate*)sharedInstance;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

-(void)setRootForMenu;
-(void)closeMenu;
-(void)openMenu;
@end

