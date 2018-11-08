//
//  DataPickerViewController.m
//  MarketingAssistant
//
//  Created by 林鹏, Leon on 2017/4/12.
//  Copyright © 2017年 林鹏, Leon. All rights reserved.
//

#import "DataPickerView.h"

@interface DataPickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>

@property(nonatomic,strong) UIPickerView *picker;
@property (nonatomic, assign)   UIWindow *previousKeyWindow;
@end

static DataPickerView *pickerView = nil;
static Dissmiss _dissmiss;
@implementation DataPickerView

-(UIPickerView *)picker{
    if(_picker == nil){
        _picker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-216, SCREEN_WIDTH, 216)];
        _picker.backgroundColor = [UIColor whiteColor];
        _picker.delegate = self ;
        _picker.dataSource = self ;
        [_picker selectRow:_selectedIndex inComponent:0 animated:NO];
    }
    
    return _picker;
}

+ (DataPickerView*)pickerView {
    
    if(pickerView == nil)
        pickerView = [[DataPickerView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        pickerView.backgroundColor = [UIColor whiteColor];

    return pickerView;
}

+ (void)showWithTitleArray:(NSArray *)array selectIndex:(NSInteger)selectIndex dissMiss:(Dissmiss)dissMiss{
    [DataPickerView pickerView].selectedIndex = selectIndex ;
    _dissmiss = dissMiss;
    [DataPickerView pickerView].titleArray = array ;
    [[DataPickerView pickerView] show];
}


-(void)tapAction:(id)sender{
    _dissmiss(_selectedIndex);
    [self dissmissDataPicker];
}

-(void)show{
    self.backgroundColor = RGBACOLOR(213, 213, 213, 0.8);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tap];
    [self addSubview:self.picker];
    
//    if(![self isKeyWindow]) {
//        [[UIApplication sharedApplication].windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            UIWindow *window = (UIWindow*)obj;
//            if(window.windowLevel == UIWindowLevelNormal && ![[window class] isEqual:[DataPickerView class]]) {
//                self.previousKeyWindow = window;
//                *stop = YES;
//            }
//        }];
//        
//       
//    }
    [self makeKeyAndVisible];
    [self setNeedsDisplay];
}


-(void)dissmissDataPicker{
//    if(self.previousKeyWindow){
//         [self.previousKeyWindow makeKeyWindow];
//    }

    pickerView = nil;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return  1 ;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _titleArray.count ;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return [_titleArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    _selectedIndex = row ;
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
