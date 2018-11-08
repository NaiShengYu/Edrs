//
//  LocalChemicalsManager.m
//  edrs
//
//  Created by 林鹏, Leon on 2017/6/7.
//  Copyright © 2017年 julyyu. All rights reserved.
//

#import "LocalChemicalsManager.h"

@implementation LocalChemicalsManager
+(NSString *)getModelFilePath{
    NSString *userId = @"11";
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);NSString * documentDirectory = [paths objectAtIndex:0];
    
    NSString * file = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/chemicalLit_%@.plist",userId]];
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

+(NSDictionary *)getChemicalDictionary{
    NSData *data = [NSData dataWithContentsOfFile:[self getModelFilePath]];
    if(data ==nil){
        return nil;
    }
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return jsonDic;
}



+(BOOL)checkTheChemical:(NSString *)chemical withListStr:(NSString *)list{
    BOOL added = NO ;
    NSArray *items = [list componentsSeparatedByString:@"  "];
    for (NSString *sunItem in items) {
        if([sunItem isEqualToString:chemical]){
            added = YES;
            return added;
        }
    }
    
    return added;
}

+(NSString *)getChemicalsWithID:(NSString *)disasterId{
     NSString *list = [[self getChemicalDictionary] valueForKey:disasterId];
    
    return list;
}
+(void)saveChemical:(NSString *)chemical   withDisasterId:(NSString *)disasterId{
  
    if(disasterId ==nil){
        return;
    }
    NSString *list = [[self getChemicalDictionary] valueForKey:disasterId];
    if(![self checkTheChemical:chemical withListStr:list]){
        NSMutableDictionary *newDic = [[NSMutableDictionary alloc]initWithDictionary:[self getChemicalDictionary]];
        if(list){
            [newDic setValue:[NSString stringWithFormat:@"%@  %@",list,chemical] forKey:disasterId];
        }else{
             [newDic setValue:chemical forKey:disasterId];
        }
        [self saveJsonArrayToFile:newDic];
    }
}
@end
