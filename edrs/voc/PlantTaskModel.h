//
//  PlantTaskModel.h
//  VOC
//
//  Created by 林鹏, Leon on 2017/3/17.
//  Copyright © 2017年 林鹏, Leon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlantTaskModel : NSObject


@property(nonatomic,strong) NSString *plan;
@property(nonatomic,strong) NSString *typeid;
@property(nonatomic,strong) NSString *typename;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *id;
@property(nonatomic,unsafe_unretained) NSInteger index;
@property(nonatomic,unsafe_unretained) NSInteger status;
@property(nonatomic,unsafe_unretained) NSInteger datastatus;

@property(nonatomic,strong) NSArray *anatype;
@end
