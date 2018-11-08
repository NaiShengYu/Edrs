//
//  LocalTypeManager.m
//  edrs
//
//  Created by 林鹏, Leon on 2017/6/7.
//  Copyright © 2017年 julyyu. All rights reserved.
//

#import "LocalTypeManager.h"

@implementation LocalTypeManager
+(NSString *)getModelFilePath{
    NSString *userId = @"11";
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);NSString * documentDirectory = [paths objectAtIndex:0];
    
    NSString * file = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/typeLit_%@.plist",userId]];
    NSLog(@"%@",file);
    return file;
}


+(void)saveJsonArrayToFile:(NSDictionary *)dataDic{
    NSData *data = [[dataDic modelToJSONString] dataUsingEncoding:NSUTF8StringEncoding];
    NSString * filePath= [self getModelFilePath];
    BOOL state = [data writeToFile:filePath atomically:YES];
    if(state){
        NSLog(@"成功");
    }else{
        NSLog(@"失败");
    }
}

+(NSDictionary *)getTypeDictionary{
    NSData *data = [NSData dataWithContentsOfFile:[self getModelFilePath]];
    if(data ==nil){
        return nil;
    }
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return jsonDic;
}



+(BOOL)checkTheType:(NSString *)type withListStr:(NSString *)list{
    BOOL added = NO ;
    NSArray *items = [list componentsSeparatedByString:@","];
    for (NSString *sunItem in items) {
        if([sunItem isEqualToString:type]){
            added = YES;
            return added;
        }
    }
    
    return added;
}

+(NSString *)getTypeStrWith:(NSString *)disasterId{
    return  [[self getTypeDictionary] valueForKey:disasterId];
}
+(void)saveType:(NSString *)type   withDisasterId:(NSString *)disasterId{
    
    NSString *list = [[self getTypeDictionary] valueForKey:disasterId];
    if(![self checkTheType:type withListStr:list]){
        NSMutableDictionary *newDic = [[NSMutableDictionary alloc]initWithDictionary:[self getTypeDictionary]];
        if(list){
            [newDic setValue:[NSString stringWithFormat:@"%@,%@",list,type] forKey:disasterId];
        }else{
            [newDic setValue:type forKey:disasterId];
        }
        [self saveJsonArrayToFile:newDic];
    }
}

@end
