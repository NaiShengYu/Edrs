//
//  HttpTaskManager.m
//  Plane
//
//  Created by auxiphone on 16/1/27.
//  Copyright © 2016年 linPeng. All rights reserved.
//

#import "HttpTaskManager.h"
#import "SVProgressHUD.h"
#import "Define.h"
#import "CustomAccount.h"
@implementation HttpTaskManager

-(NSString *)getURL:(NSString *)portPath{
    NSString *urlStr ;
    
   NSString *baseURL = [NSString stringWithFormat:@"https://%@", [CustomAccount sharedCustomAccount].stationUrl];
    if([portPath hasPrefix:@"http"]){
        return portPath;
    }else{
        if([portPath hasPrefix:@"/"]){
           urlStr= [NSString stringWithFormat:@"%@%@",baseURL,portPath];
        }else{
           urlStr = [NSString stringWithFormat:@"%@/%@",baseURL,portPath];
        }
    }
    return urlStr ;
}



- (NSURLSessionDataTask * )postWithPortPath:(NSString *)portPath parameters: (NSMutableDictionary *)parameters  onSucceeded:(DictronaryBlock) succeededBlock onError:(ErrorBlock) errorBlock{
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json",@"text/json",@"text/html",nil];
    NSString *token =[[NSUserDefaults standardUserDefaults] valueForKey:@"USERTOKEN"];
//    [NSString stringWithFormat:@"Bearer %@",[ModelLocator sharedInstance].token];
    if(token){
        
        [self.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    }

 
    self.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];

    self.securityPolicy.validatesDomainName = NO;
    self.securityPolicy.allowInvalidCertificates = YES;
   
    [self POST:[self getURL:portPath] parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"%@ === %@",task.currentRequest ,[parameters modelToJSONString]);
        NSLog(@"%@",[responseObject modelToJSONString]);
        
        if([responseObject isKindOfClass:[NSDictionary class]]){
            succeededBlock(responseObject);
        }else if([responseObject isKindOfClass:[NSArray class]]){
            NSMutableDictionary *resposeDic = [[NSMutableDictionary alloc]initWithObjects:@[responseObject,[NSNumber numberWithInt:1]] forKeys:@[@"list",@"ret"]];
            succeededBlock(resposeDic);
        }
 
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *receiveStr = [[NSString alloc]initWithData:[error.userInfo valueForKey:@"com.alamofire.serialization.response.error.data"] encoding:enc];
        NSLog(@"%@",receiveStr);
//        if(error.code == -1011){
//
//            [[NSNotificationCenter defaultCenter] postNotificationName:LOGINFAILURE object:nil];
//        }else{
        
            [CustomUtil showMessage:@"网络连接超时，请重试"];
            
//        }
    }];
    return nil;
}

- (NSURLSessionDataTask * )getWithPortPath:(NSString *)portPath parameters: (NSMutableDictionary *)parameters  onSucceeded:(DictronaryBlock) succeededBlock onError:(ErrorBlock) errorBlock{
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json",@"text/json",@"text/html",nil];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    self.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    self.securityPolicy.validatesDomainName = NO;
    self.securityPolicy.allowInvalidCertificates = YES;
    
    NSString *token =[[NSUserDefaults standardUserDefaults] valueForKey:@"USERTOKEN"];
//    [NSString stringWithFormat:@"Bearer %@",[ModelLocator sharedInstance].token];
    if(token){
        
        [self.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    }
    [self GET:[self getURL:portPath] parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"%@ === %@",task.currentRequest ,[parameters modelToJSONString]);
        NSLog(@"%@",[responseObject modelToJSONString]);
        if([responseObject isKindOfClass:[NSDictionary class]]){
            succeededBlock(responseObject);
        }else if([responseObject isKindOfClass:[NSArray class]]){
            NSMutableDictionary *resposeDic = [[NSMutableDictionary alloc]initWithObjects:@[responseObject,[NSNumber numberWithInt:1]] forKeys:@[@"list",@"ret"]];
            succeededBlock(resposeDic);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",[error description]);
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *receiveStr = [[NSString alloc]initWithData:[error.userInfo valueForKey:@"com.alamofire.serialization.response.error.data"] encoding:enc];
        NSLog(@"%@",receiveStr);
//        if(error.code == -1011){
//
//            [[NSNotificationCenter defaultCenter] postNotificationName:LOGINFAILURE object:nil];
//        }else{
//
//            [CustomUtil showMessage:@"网络连接超时，请重试"];
//
//        }
       
    }];

    
    return nil;
}

/*
- (NSURLSessionDownloadTask *)downLoadMonitorWithURL:(NSString *)downloadURL progress:(NSProgress *)progress  onSucceeded:(DictronaryBlock) succeededBlock onError:(ErrorBlock) errorBlock{
     NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadURL]];
    
    NSURLSessionDownloadTask *downTask = [self downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
       NSLog(@"%@",filePath.absoluteString);
    }];
    [progress addObserver:self forKeyPath:@"completedUnitCount" options:NSKeyValueObservingOptionNew context:nil];
    [downTask resume];
    
     return downTask;
}


-uploadDataWithURL:(NSString *)uploadURL parameters: (NSMutableDictionary *)parameters fileData:(NSData *)fileData onSucceeded:(DictronaryBlock) succeededBlock onError:(ErrorBlock) errorBlock{
    [self POST:[self getURL:uploadURL] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
 
        //        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
        
        [formData appendPartWithFileData:fileData name:@"file" fileName:@"file" mimeType:@"gcode"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        succeededBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorBlock(error);
    }];
    
    return nil;
}*/


@end
