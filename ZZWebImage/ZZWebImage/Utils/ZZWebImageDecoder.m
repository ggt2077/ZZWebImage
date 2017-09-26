//
//  ZZWebImageDecoder.m
//  ZZWebImage
//
//  Created by Tony on 17/9/20.
//  Copyright © 2017年 58. All rights reserved.
//

#import "ZZWebImageDecoder.h"

@implementation UIImage (ForceDecode)

+ (nullable UIImage *)decodedImageWithImage:(nullable UIImage *)image {
    if (![UIImage shouldDecodedImage:image]) {
        return image;
    }
}

+ (BOOL)shouldDecodedImage:(nullable UIImage *)image {
    // Prevent "CGBitmapContextCreateImage: invalid context 0x0" error
    if (image == nil) {
        return NO;
    }
    
    // do not decode animated images
    if (image.images != nil) {
        return NO;
    }
    
    CGImageRef imageRef = image.CGImage;
    
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(imageRef);
    BOOL anyAlpha = (alpha == kCGImageAlphaFirst ||
                     alpha == kCGImageAlphaLast ||
                     alpha == kCGImageAlphaPremultipliedFirst ||
                     alpha == kCGImageAlphaPremultipliedLast
                     );
    // do not decode images with alpha
    if (anyAlpha) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)shouldScaleDownImage:(nullable UIImage *)image {
    BOOL shouldScaleDown = YES;
    
    
    
    return shouldScaleDown;
}

@end
