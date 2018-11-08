//
//  SelectDataModel.h
//  VOC
//
//  Created by 林鹏, Leon on 2017/3/23.
//  Copyright © 2017年 林鹏, Leon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SelectDataModel : NSObject


@property(nonatomic,strong) NSString *id;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *type;
@property(nonatomic,unsafe_unretained) BOOL state;


@end
