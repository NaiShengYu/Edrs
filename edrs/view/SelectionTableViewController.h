//
//  SelectionTableViewController.h
//  edrs
//
//  Created by 余文君, July on 15/8/21.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectionDelegate <NSObject>

-(void)setSelectedValue:(NSString *)sid content:(NSString *)cont;
//-(void)setSelectedNature:(NSMutableDictionary *)dict;

@end

@interface SelectionTableViewController : UITableViewController{
    NSMutableArray *mSelectionArray;
    NSInteger mSelectionIndex;
}

@property (weak, nonatomic) id<SelectionDelegate> delegate;
@property (retain, nonatomic) NSArray *selectionArray;
@property (weak, nonatomic) NSString *isSpecial;

- (IBAction)actionSubmitSelection:(id)sender;
@end
