//
//  CustomHttp.h
//  edrs
//
//  Created by 余文君, July on 15/8/17.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomAccount.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "CustomUtil.h"

#define TIMEOUTSTR @"The request timed out."

@interface CustomHttp : NSObject

+(AFHTTPRequestOperationManager *)sharedManager;
+(AFHTTPRequestOperationManager *)sharedFileManager;

+(void)httpGet:(NSString *)url params:(NSDictionary *)dict success:(void(^)(id responseObj))success failure:(void(^)(NSError *err))failure;
+(void)httpPost:(NSString *)url params:(NSDictionary *)dict success:(void(^)(id responseObj))success failure:(void(^)(NSError *err))failure;
+(void)httpGetImage:(NSString *)url params:(NSDictionary *)dict success:(void (^)(id))success failure:(void (^)(NSError *))failure;
+(void)cancelAllRequest;
+(void)cancelFileRequest;

+(void)loginWithHttpRequest:(NSString *)url param:(NSDictionary *)dict success:(void(^)(id responseObj))success failure:(void(^)(NSError *err))failure type:(NSString *)rtype;

+(id)getDataFromFile:(NSString *)filename;

@end
