//
//  CustomHttp.m
//  edrs
//
//  Created by 余文君, July on 15/8/17.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "CustomHttp.h"

@implementation CustomHttp


+(AFHTTPRequestOperationManager *)sharedManager{
    static AFHTTPRequestOperationManager *managerInstance = nil;
    
    static dispatch_once_t predicte;
    dispatch_once(&predicte, ^{
        managerInstance = [AFHTTPRequestOperationManager manager];
    });
    return managerInstance;
}
+(AFHTTPRequestOperationManager *)sharedFileManager{
    static AFHTTPRequestOperationManager *managerInstance = nil;
    
    static dispatch_once_t predicte;
    dispatch_once(&predicte, ^{
        managerInstance = [AFHTTPRequestOperationManager manager];
    });
    return managerInstance;
}
+(void)cancelAllRequest{
    AFHTTPRequestOperationManager *manager1 = [self sharedManager];;
    [[manager1 operationQueue] cancelAllOperations];
    AFHTTPRequestOperationManager *manager2 = [self sharedFileManager];;
    [[manager2 operationQueue] cancelAllOperations];
}
+(void)cancelFileRequest{
    AFHTTPRequestOperationManager *manager = [self sharedFileManager];;
    [[manager operationQueue] cancelAllOperations];
}


+(void)httpGet:(NSString *)url params:(NSDictionary *)dict success:(void (^)(id))success failure:(void (^)(NSError *))failure{
    
    AFHTTPRequestOperationManager *manager = [self sharedManager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10.0f;
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERTOKEN"];
    
    if(token){
       [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    }else{
       [manager.requestSerializer setValue:[CustomAccount sharedCustomAccount].user.token forHTTPHeaderField:@"Authorization"];
    }
    
    
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.securityPolicy.validatesDomainName = NO;
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    NSLog(@"%@%@",[CustomAccount sharedCustomAccount].stationUrl, url);
    [manager GET:[NSString stringWithFormat:@"https://%@%@", [CustomAccount sharedCustomAccount].stationUrl, url]
      parameters:dict
         success:^(AFHTTPRequestOperation *operation, id responseObject){
             //NSLog(@"success");
             if (success) {
                 NSString *tmpStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                 NSLog(@"tmpStr===%@",tmpStr);
                 if (![tmpStr isEqual:@"null"]) {
                     
                         NSMutableDictionary *tmpDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                         if(tmpDict ==nil){
                             tmpDict = [NSMutableDictionary dictionaryWithObject:tmpStr forKey:@"data"];
                         }
                         [[CustomAccount sharedCustomAccount].user setLoginTime:0];
                         success(tmpDict);
                     
                 }
                 else{
                     NSLog(@"get 返回值是null");
                     if([CustomAccount sharedCustomAccount].user.loginTime < 1){
                         [self loginWithHttpRequest:url param:dict success:success failure:failure type:@"GET"];
                     }
                     else{
                         [[NSNotificationCenter defaultCenter] postNotificationName:LOGINFAILURE object:nil];
                     }
                 }
             } else {
                 NSLog(@"get not successful");
                 
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *err){
             NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
             NSString *receiveStr = [[NSString alloc]initWithData:operation.responseData encoding:enc];
             NSLog(@"%@",receiveStr);
             if([receiveStr containsString:@"Authorization has been denied for this request."]){
    
                 [[NSNotificationCenter defaultCenter] postNotificationName:LOGINFAILURE object:nil];
             }else{
                 if (failure) {
                     failure(err);
                     
                     if ([[err localizedDescription] isEqualToString:TIMEOUTSTR]) {
                         [SVProgressHUD showErrorWithStatus:@"网络连接超时，请重试"];
                     }
                     
                 }
             }
            
         }];
}

+(void)httpPost:(NSString *)url params:(NSDictionary *)dict success:(void (^)(id))success failure:(void (^)(NSError *))failure{
    //AFHTTPRequestOperationManager *manager = [self sharedManager];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:@"USERTOKEN"];
    
    NSLog(@"token===%@",token);
    NSLog(@"token======%@",[CustomAccount sharedCustomAccount].user.token);
    
    if(token){
        [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    }else{
        [manager.requestSerializer setValue:[CustomAccount sharedCustomAccount].user.token forHTTPHeaderField:@"Authorization"];
    }
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.securityPolicy.validatesDomainName = NO;
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    NSString *utf8url = [[NSString stringWithFormat:@"https://%@%@", [CustomAccount sharedCustomAccount].stationUrl, url] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"request url = %@", utf8url);
    [manager POST:utf8url
       parameters:dict
          success:^(AFHTTPRequestOperation *operation, id responseObject){
              if (success) {
                  NSString *tmpStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                  tmpStr =[tmpStr stringByReplacingOccurrencesOfString:@"'\'" withString:@" "];

                  if (![tmpStr isEqualToString:@"null"]) {
                      
                      NSMutableDictionary *tmpDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                      [[CustomAccount sharedCustomAccount].user setLoginTime:0];
                      if(tmpDict == nil){
                          success(tmpStr);
                      }else{
                         success(tmpDict);
                      }
                      
                  }
                  else{
                      NSLog(@"post 返回值是null");
                      if([CustomAccount sharedCustomAccount].user.loginTime < 1){
                          [self loginWithHttpRequest:url param:dict success:success failure:failure type:@"POST"];
                      }
                      else{
                          [[NSNotificationCenter defaultCenter] postNotificationName:LOGINFAILURE object:nil];
                      }
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *err){
              NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
              NSString *receiveStr = [[NSString alloc]initWithData:operation.responseData encoding:enc];
              if([receiveStr containsString:@"Authorization has been denied for this request."]){
                 
                  [[NSNotificationCenter defaultCenter] postNotificationName:LOGINFAILURE object:nil];
              }else{
                  if (failure) {
                      failure(err);
                      
                      if ([[err localizedDescription] isEqualToString:TIMEOUTSTR]) {
                          [SVProgressHUD showErrorWithStatus:@"网络连接超时，请重试"];
                      }
                      
                  }
              }
          }];
}

+(void)httpGetImage:(NSString *)url params:(NSDictionary *)dict success:(void (^)(id))success failure:(void (^)(NSError *))failure{
    AFHTTPRequestOperationManager *manager = [self sharedFileManager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[CustomAccount sharedCustomAccount].user.token forHTTPHeaderField:@"Authorization"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.securityPolicy.validatesDomainName = NO;
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    [manager POST:[NSString stringWithFormat:@"https://%@%@", [CustomAccount sharedCustomAccount].stationUrl, url]
       parameters:dict
          success:^(AFHTTPRequestOperation *opr, id responseObj) {
        if (success) {
            success(responseObj);
        }
    }
          failure:^(AFHTTPRequestOperation *opr, NSError *err) {
        //
              NSLog(@"fail to get image");
              if ([[err localizedDescription] isEqualToString:TIMEOUTSTR]) {
                  [CustomUtil showMessage:@"网络连接超时，请重试"];
              }
    }];
}

+(void)loginWithHttpRequest:(NSString *)url param:(NSDictionary *)dict success:(void (^)(id))success failure:(void (^)(NSError *))failure type:(NSString *)rtype{
    NSUserDefaults  *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud objectForKey:USERNAME];
    NSString *password = [ud objectForKey:PASSWORD];
    NSString *stationid = [ud objectForKey:STATIONID];
    NSString *station = [ud objectForKey:STATION];
    BOOL rememberpwd = [ud boolForKey:REMEMBERPWD];
    
    if (rememberpwd) {
        NSLog(@"re login url = %@",[NSString stringWithFormat:@"%@%@", [CustomAccount sharedCustomAccount].stationUrl,EDRSHTTP_LOGIN]);
        [CustomHttp httpPost:[NSString stringWithFormat:@"%@%@", EDRSHTTP,EDRSHTTP_LOGIN] params:@{@"UserName":username,@"Password":password,@"rememberStatus":@"true",@"sid":stationid,@"sname":station}
                     success:^(id responseObj) {
                         if([responseObj[@"success"] intValue] == 1){
                             //登录成功后存储用户信息
                             NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
                             [userdefaults setObject:username forKey:USERNAME];
                             [userdefaults setObject:password forKey:PASSWORD];
                             [userdefaults setObject:station forKey:STATION];
                             [userdefaults setObject:stationid forKey:STATIONID];
                             [userdefaults setBool:YES forKey:REMEMBERPWD];
                             [userdefaults setObject:responseObj[@"userid"] forKey:USERID];
                             [userdefaults synchronize];
                             
                             //更新全局变量
                             AccountModel *tmpAccountModel = [[AccountModel alloc]init];
                             [tmpAccountModel setStationId:stationid];
                             [tmpAccountModel setStationName:station];
                             [tmpAccountModel setUserName:username];
                             [tmpAccountModel setPassword:password];
                             [tmpAccountModel setUserId:responseObj[@"userid"]];
                             [tmpAccountModel setToken:[NSString stringWithFormat:@"Basic %@",responseObj[@"userauth"]]];
                             [CustomAccount sharedCustomAccount].user = tmpAccountModel;
                             
                             [[CustomAccount sharedCustomAccount].user setLoginTime:1];
                             
                             if ([rtype isEqualToString:@"GET"]) {
                                 [self httpGet:url params:dict success:success failure:failure];
                             }
                             else{
                                 [self httpPost:url params:dict success:success failure:failure];
                             }
                         }
                         else{
                             NSLog(@"后台登录失败。。");
                         }
                     } failure:^(NSError *err) {
                         NSLog(@"后台登录失败,fail to request login, error = %@",err);
                     }];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:LOGOUT object:nil];
    }
}


+(id)getDataFromFile:(NSString *)filename{
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"txt"];
    NSData *tmpdata = [[NSData alloc]initWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:tmpdata options:kNilOptions error:nil];
}

@end
