//
//  CustomUtil.h
//  edrs
//
//  Created by 余文君, July on 15/8/18.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "CommonDefinition.h"
#import "Common.h"
#import "XLabel.h"
@interface CustomUtil : NSObject

+(CGSize)getAttributeStringSize:(NSMutableAttributedString *)attrStr;

+(NSString *)getFormatedDateString:(NSString *)datestr;

+(UITextView *)setTextInLabel:(NSString *)str labelW:(CGFloat)w labelPadding:(CGFloat)p;
+(UILabel *)setTextInLabel:(NSString *)str labelW:(CGFloat)w labelPadding:(CGFloat)p textAlign:(NSTextAlignment)ta textFont:(UIFont *)font;

+(MBProgressHUD *)showMBProgressHUD:(NSString *)text view:(UIView *)v animated:(BOOL)a;

+(NSString *)UIImageToBase64:(UIImage *)image;
+(UIImage *)Base64ToUIImage:(NSString *)code;
+(NSData *)base64NSStringToNsData:(NSString *)str;

+(void)showMessage:(NSString *)message;
+(NSString *)getWindType:(NSString *)du;
+(NSString *)getFilePath:(NSString *)filename;
+(void)deleteFileAtPath:(NSString *)filepath;

+(UIImage *)scaleImage:(UIImage *)oriImg toScale:(float)scalesize;
+(UIImage *)fixOrientation:(UIImage *)aImage;
@end
