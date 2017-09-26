//
//  ZZWebImageCompat.m
//  ZZWebImage
//
//  Created by Tony on 17/9/13.
//  Copyright © 2017年 58. All rights reserved.
//

#import "ZZWebImageCompat.h"

#import "objc/runtime.h"

#if !__has_feature(objc_arc)
#error ZZWebImage is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

inline UIImage *ZZScaledImageForKey(NSString * _Nullable key, UIImage * _Nullable image) {
    if (!image) {
        return nil;
    }
    
#if SD_MAC
    return image;
#elif SD_UIKIT || SD_WATCH
    if ((image.images).count > 0) {
        NSMutableArray<UIImage *> *scaledImages = [NSMutableArray array];
        
        for (UIImage *tempImage in image.images) {
            [scaledImages addObject:ZZScaledImageForKey(key, tempImage)];
        }
        
        UIImage *animatedImage = [UIImage animatedImageWithImages:scaledImages duration:image.duration];
#ifdef SD_WEBP
        if (animatedImage) {
            SEL zz_webpLoopCount = NSSelectorFromString(@"zz_webpLoopCount");
            NSNumber *value = objc_getAssociatedObject(image, zz_webpLoopCount);
            NSInteger loopCount = value.integerValue;
            if (loopCount) {
                objc_setAssociatedObject(animatedImage, zz_webpLoopCount, @(loopCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
#endif
        return animatedImage;
    } else {
#if SD_WATCH
        if ([[WKInterfaceDevice currentDevice] respondsToSelector:@selector(screenScale)]) {
#elif SD_UIKIT
            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
#endif
                CGFloat scale = 1;
                if (key.length >= 8) {
                    NSRange range = [key rangeOfString:@"@2x."];
                    if (range.location != NSNotFound) {
                        scale = 2.0;
                    }
                    
                    range = [key rangeOfString:@"@3x."];
                    if (range.location != NSNotFound) {
                        scale = 3.0;
                    }
                }
                
                UIImage *scaledImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];
                image = scaledImage;
            }
            return image;
        }
#endif
    }
    
    NSString *const ZZWebImageErrorDomain = @"ZZWebImageErrorDomain";
