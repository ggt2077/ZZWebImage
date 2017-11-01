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
#import "UIImage+WebP.h"

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
    else if (imageFormat == ZZImageFormatWebP) {
        image = [UIImage zz_imageWithWebPData:data];
    }
#endif
    else {
        image = [[UIImage alloc] initWithData:data];
        
        UIImageOrientation orientation = [self zz_imageOrientationFromImageData:data];
        if (orientation != UIImageOrientationUp) {
            image = [UIImage imageWithCGImage:image.CGImage
                                        scale:image.scale
                                  orientation:orientation];
        }
    }
    return image;
}

+ (UIImageOrientation)zz_imageOrientationFromImageData:(nonnull NSData *)imageData {
    UIImageOrientation result = UIImageOrientationUp;
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    if (imageSource) {
        CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
        if (properties) {
            CFTypeRef val;
            int exifOrientation;
            val = CFDictionaryGetValue(properties, kCGImagePropertyOrientation);
            if (val) {
                CFNumberGetValue(val, kCFNumberIntType, &exifOrientation);
                result = [self zz_exifOrientationToiOSOrientation:exifOrientation];
            } // else - if it's not set it remains at up
            CFRelease((CFTypeRef) properties);
        } else {
            //NSLog(@"NO PROPERTIES, FAIL");
        }
        CFRelease(imageSource);
    }
    return result;
}

#pragma mark EXIF orientation tag converter

// Convert an EXIF image orientation to an iOS one.
// reference see here: http://sylvana.net/jpegcrop/exif_orientation.html
+ (UIImageOrientation)zz_exifOrientationToiOSOrientation:(int)exifOrientation {
    UIImageOrientation orientation = UIImageOrientationUp;
    switch (exifOrientation) {
        case 1:
            orientation = UIImageOrientationUp;
            break;
            
        case 3:
            orientation = UIImageOrientationDown;
            break;
            
        case 8:
            orientation = UIImageOrientationLeft;
            break;
            
        case 6:
            orientation = UIImageOrientationRight;
            break;
            
        case 2:
            orientation = UIImageOrientationUpMirrored;
            break;
            
        case 4:
            orientation = UIImageOrientationDownMirrored;
            break;
            
        case 5:
            orientation = UIImageOrientationLeftMirrored;
            break;
            
        case 7:
            orientation = UIImageOrientationRightMirrored;
            break;
        default:
            break;
    }
    return orientation;
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
