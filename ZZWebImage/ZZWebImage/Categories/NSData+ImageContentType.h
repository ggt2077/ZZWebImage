//
//  NSData+ImageContentType.h
//  ZZWebImage
//
//  Created by Tony on 2017/10/17.
//  Copyright © 2017年 58. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ZZImageFormat) {
    ZZImageFormatUndefined = -1,
    ZZImageFormatJPEG = 0,
    ZZImageFormatPNG,
    ZZImageFormatGIF,
    ZZImageFormatTIFF,
    ZZImageFormatWebP
};

@interface NSData (ImageContentType)

/**
 *  Return image format
 *
 *  @param data the input image data
 *
 *  @return the image format as `ZZImageFormat` (enum)
 */
+ (ZZImageFormat)zz_imageFormatForImageData:(nullable NSData *)data;

@end
