//
//  UIImage+GIF.m
//  ZZWebImage
//
//  Created by Tony on 2017/10/17.
//  Copyright © 2017年 58. All rights reserved.
//

#import "UIImage+GIF.h"

@implementation UIImage (GIF)

+ (UIImage *)zz_animatedGIFWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *staticImage;
    
    if (count <= 1) {
        staticImage = [[UIImage alloc] initWithData:data];
    } else {
        // we will only retrieve the 1st frame. the full GIF support is available via the FLAnimatedImageView category.
        // this here is only code to allow drawing animated images as static ones
        // 我们只会检索第一帧。 通过FLAnimatedImageView类别可以获得完整的GIF支持。
        // 这里只是允许将动画图像绘制为静态图像的代码
        
        CGFloat scale = 1;
        scale = [UIScreen mainScreen].scale;
        
        CGImageRef CGImage = CGImageSourceCreateImageAtIndex(source, 0, NULL);
        
        UIImage *frameImage = [UIImage imageWithCGImage:CGImage scale:scale orientation:UIImageOrientationUp];
        staticImage = [UIImage animatedImageWithImages:@[frameImage] duration:0.0f];
        
        CGImageRelease(CGImage);
    }
    
    CFRelease(source);
    
    return staticImage;
}

- (BOOL)isGIF {
    return (self.images != nil);
}

@end
