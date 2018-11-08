//
//  CustomUtil.m
//  edrs
//
//  Created by 余文君, July on 15/8/18.
//  Copyright (c) 2015年 julyyu. All rights reserved.
//

#import "CustomUtil.h"

@implementation CustomUtil


+(CGSize)getAttributeStringSize:(NSMutableAttributedString *)attrStr{
    NSRange range = NSMakeRange(0, attrStr.length);
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:range];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:range];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 20)];
    CGSize size = [attrStr boundingRectWithSize:label.bounds.size options:NSStringDrawingTruncatesLastVisibleLine context:nil].size;
    return size;
}

+(NSString *)getFormatedDateString:(NSString *)datestr{
    NSString *tmptime;
    NSString *ydm = [datestr substringToIndex:10];
    NSString *hms = [datestr substringWithRange:NSMakeRange(11, 5)];
    tmptime = [NSString stringWithFormat:@"%@ %@", ydm, hms];
    return tmptime;
}

+(UITextView *)setTextInLabel:(NSString *)str labelW:(CGFloat)w labelPadding:(CGFloat)p{
    UITextView *label = [[UITextView alloc]initWithFrame:CGRectMake(p, 0, w, 100)];
//    [label setNumberOfLines:0];
//   [label setLineBreakMode:NSLineBreakByWordWrapping];
    label.selectable = YES ;
    label.editable = NO;
    label.scrollEnabled = NO;
    label.backgroundColor = [UIColor clearColor];
    [label setTextAlignment:NSTextAlignmentRight];
    [label setFont:[UIFont systemFontOfSize:14.0f]];
    [label setText:str];
    
    CGSize size = CGSizeMake(w,MAXFLOAT);
    CGSize strsize;
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:14.0f] forKey:NSFontAttributeName];
        strsize = [str sizeWithAttributes:attributes];
    }else{
        NSStringDrawingOptions option = NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine;
        NSDictionary *attr = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:14.0f] forKey:NSFontAttributeName];
        CGRect rect = [str boundingRectWithSize:size options:option attributes:attr context:nil];
        strsize = rect.size;
    }
    
    [label setFrame:CGRectMake(p, 0, w-p*2, strsize.height+20)];
    
    return label;
}

+(UILabel *)setTextInLabel:(NSString *)str labelW:(CGFloat)w labelPadding:(CGFloat)p textAlign:(NSTextAlignment)ta textFont:(UIFont *)font{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
    [label setNumberOfLines:0];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    [label setTextAlignment:ta];
    [label setFont:font];
    [label setText:str];
    
    CGSize size = CGSizeMake(w,MAXFLOAT);
    CGSize strsize;
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        strsize = [str sizeWithAttributes:attributes];
    }else{
        NSStringDrawingOptions option = NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine;
        NSDictionary *attr = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        CGRect rect = [str boundingRectWithSize:size options:option attributes:attr context:nil];
        strsize = rect.size;
    }
    
    [label setFrame:CGRectMake(p, 0, w-p*2, strsize.height)];
    
    return label;
}

+(MBProgressHUD *)showMBProgressHUD:(NSString *)text view:(UIView *)v animated:(BOOL)a{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:v animated:YES];
    [hud setLabelText:text];
    [hud setMode:MBProgressHUDModeText];
    [hud hide:YES afterDelay:1.5f];
    return hud;
}

+(NSString *)UIImageToBase64:(UIImage *)image{
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
//    NSLog(@"+ data length = %lu", data.length);
    
//    NSData *base64data = [data base64EncodedDataWithOptions:0];
//    NSLog(@"+ base64data length = %lu", base64data.length);
//
//    NSData *decodebase64 = [base64data initWithBase64EncodedData:base64data options:0];
//    NSLog(@"+ decodebase64 length = %lu", decodebase64.length);
//    
    NSString *str = [data base64EncodedStringWithOptions:0];
//    NSLog(@"+ str length = %lu", str.length);
//
//    NSData *strdata = [[NSData alloc]initWithBase64EncodedString:str options:0];
//    NSLog(@"+ strdata length = %lu", strdata.length);
//    
    return str;
}
+(UIImage *)Base64ToUIImage:(NSString *)code{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:code options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}
+(NSData *)base64NSStringToNsData:(NSString *)str{
    NSData *strdata = [[NSData alloc]initWithBase64EncodedString:str options:0];
    return strdata;
}

+(void)showMessage:(NSString *)message{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    UIView *showview =  [[UIView alloc]init];
    showview.backgroundColor = [UIColor blackColor];
    showview.frame = CGRectMake(1, 1, 1, 1);
    showview.alpha = 1.0f;
    showview.layer.cornerRadius = 5.0f;
    showview.layer.masksToBounds = YES;
    [window addSubview:showview];
    
    UILabel *label = [[UILabel alloc]init];
    CGSize LabelSize = [message sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(290, 9000)];
    label.frame = CGRectMake(10, 5, LabelSize.width, LabelSize.height);
    label.text = message;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = 1;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:15];
    [showview addSubview:label];
    showview.frame = CGRectMake((SCREEN_WIDTH - LabelSize.width - 20)/2, SCREEN_HEIGHT - 100, LabelSize.width+20, LabelSize.height+10);
    [UIView animateWithDuration:3 animations:^{
        showview.alpha = 0;
    } completion:^(BOOL finished) {
        [showview removeFromSuperview];
    }];
}



+(NSString *)getFilePath:(NSString *)filename{
    NSString *sandboxpath = NSHomeDirectory();
    NSString *filepath = [sandboxpath stringByAppendingPathComponent:[NSString stringWithFormat:@"/Documents/edrsCache/%@",filename]];
    NSString *folderpath = [sandboxpath stringByAppendingPathComponent:@"/Documents/edrsCache"];
    BOOL isdir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderpath isDirectory:&isdir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:folderpath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return filepath;
}
+(void)deleteFileAtPath:(NSString *)filepath{
    NSString *sandboxpath = NSHomeDirectory();
    NSString *folderpath = [sandboxpath stringByAppendingPathComponent:@"/Documents/edrsCache"];
    [[NSFileManager defaultManager] removeItemAtPath:folderpath error:nil];
    //[[NSFileManager defaultManager] removeItemAtPath:filepath error:nil];
}

+(NSString *)getWindType:(NSString *)du{
    NSInteger wwind =[du integerValue];
    NSString *WindValues = @"";
    if (wwind == 0) {
        WindValues = @"北风";
    } else if (0 < wwind && wwind < 45) {
        WindValues =  @"东北风偏北";
    } else if (wwind == 45) {
        WindValues =  @"东北风";
    } else if (45 < wwind && wwind < 90) {
        WindValues =  @"东北风偏东";
    } else if (wwind == 90) {
        WindValues =  @"东风";
    } else if (90 < wwind && wwind < 135) {
        WindValues =  @"东南风偏东";
    } else if (wwind == 135) {
        WindValues =  @"东南风";
    } else if (135 < wwind && wwind < 180) {
        WindValues =  @"东南风偏南";
    } else if (wwind == 180) {
        WindValues =  @"南风";
    } else if (180 < wwind && wwind < 225) {
        WindValues =  @"西南风偏南";
    } else if (wwind == 225) {
        WindValues =  @"西南风";
    } else if (225 < wwind && wwind < 270) {
        WindValues =  @"西南风偏西";
    } else if (wwind == 270) {
        WindValues =  @"西风";
    } else if (270 < wwind && wwind < 315) {
        WindValues =  @"西北风偏西";
    } else if (wwind == 315) {
        WindValues =  @"西北风";
    } else if (315 < wwind && wwind < 360) {
        WindValues =  @"西北风偏北";
    } else if (wwind == 360) {
        WindValues =  @"北风";
    }
    return WindValues ;
}

+(UIImage *)scaleImage:(UIImage *)oriImg toScale:(float)scalesize{
    
    UIGraphicsBeginImageContext(CGSizeMake(oriImg.size.width * scalesize, oriImg.size.height * scalesize));
    [oriImg drawInRect:CGRectMake(0, 0, oriImg.size.width * scalesize, oriImg.size.height * scalesize)];
    UIImage *scaleimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaleimg;
}

+(UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
@end
