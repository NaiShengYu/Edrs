//
//  UploadDataViewController.h
//  edrs
//
//  Created by 余文君, July on 15/8/20.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EquipmentSelectViewController.h"
#import "SelectionTableViewController.h"
#import "CustomUtil.h"
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
@protocol UploadDataDelegate <NSObject>
-(void)SetData:(NSMutableDictionary *)dict;
@end

@interface UploadDataViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate,EquipmentSelectDelegate,SelectionDelegate>{
    
    NSMutableArray *mNatureList;
    NSMutableArray *mTestChemicalList;
    NSArray *mTestMethodList;
    NSMutableArray *mEquipmentList;
    NSMutableArray *mTestEquipmentItemList;
    
    UITextField *mTestResultTextField;
    NSMutableDictionary *mSelectedEquipment;
    
   
//    NSMutableArray *mChemicalUnitList;
    
    NSString *mCurrentUnitValue;
    NSString *mCurrentUnit;
    NSString *mCurrentUnitID;
    NSInteger mSelectedNatureIndex;
    NSInteger mSelectedChemicalIndex;
    NSInteger mSelectedTestMethodIndex;
    NSInteger mSelectedTestEquipmentItemIndex;
    
    BOOL mShowNatureSelect;
    BOOL mShowEquipmentSelect;
    BOOL mShowEquipmentTestItems;
    BOOL mShowTestResult;
    BMKLocationService *mLocationService;
}
@property (strong, nonatomic)  NSMutableArray *mUnitList;
@property (weak, nonatomic) IBOutlet UITableView *uploadDataTableView;
@property (weak, nonatomic) id<UploadDataDelegate> delegate;
@property (weak, nonatomic) NSString *did;
@property (unsafe_unretained,nonatomic)  CLLocationCoordinate2D mLocation;
-(void)registerKeyboardNotification;
-(void)keyboardWasShown:(NSNotification *)noti;
-(void)keyboardWasHidden:(NSNotification *)noti;
-(void)hideKeyboard;

-(void)submitData;

@end
