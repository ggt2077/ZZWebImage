//
//  UIImage+MultiFormat.m
//  ZZWebImage
//
//  Created by Tony on 2017/10/17.
//  Copyright © 2017年 58. All rights reserved.
//

#import "UIImage+MultiFormat.h"
#import <ImageIO/ImageIO.h>
#import "UIImage+GIF.h"

@implementation UIImage (MultiFormat)

+ (nullable UIImage *)zz_imageWithData:(nullable NSData *)data {
    if (!data) {
        return nil;
    }
    
    UIImage *image;
    ZZImageFormat imageFormat = [NSData zz_imageFormatForImageData:data];
    if (imageFormat == ZZImageFormatGIF) {
        image = [UIImage zz_animatedGIFWithData:data];
    }
#ifdef SD_WEBP
#endif
}

- (nullable NSData *)zz_imageData {
    return [self zz_imageDataAsFormat:ZZImageFormatUndefined];
}

- (nullable NSData *)zz_imageDataAsFormat:(ZZImageFormat)imageFormat {
    NSData *imageData = nil;
    if (self) {
        int alphaInfo = CGImageGetAlphaInfo(self.CGImage);
        BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                          alphaInfo == kCGImageAlphaNoneSkipFirst ||
                          alphaInfo == kCGImageAlphaNoneSkipLast);
        
        BOOL usePNG = hasAlpha;
        
        // the imageFormat param has priority here. But if the format is undefined, we relly on the alpha channel
        if (imageFormat != ZZImageFormatUndefined) {
            usePNG = (imageFormat == ZZImageFormatPNG);
        }
        
        if (usePNG) {
            imageData = UIImagePNGRepresentation(self);
        } else {
            imageData = UIImageJPEGRepresentation(self, (CGFloat)1.0);
        }
    }
    return imageData;
}

@end
