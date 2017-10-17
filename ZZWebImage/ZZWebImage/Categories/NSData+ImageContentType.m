//
//  NSData+ImageContentType.m
//  ZZWebImage
//
//  Created by Tony on 2017/10/17.
//  Copyright © 2017年 58. All rights reserved.
//

#import "NSData+ImageContentType.h"

@implementation NSData (ImageContentType)

+ (ZZImageFormat)zz_imageFormatForImageData:(nullable NSData *)data {
    if (!data) {
        return ZZImageFormatUndefined;
    }
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return ZZImageFormatJPEG;
        case 0x89:
            return ZZImageFormatPNG;
        case 0x47:
            return ZZImageFormatGIF;
        case 0x49:
        case 0x4D:
            return ZZImageFormatTIFF;
        case 0x52:
            // R as RIFF for WEBP
            if (data.length < 12) {
                return ZZImageFormatUndefined;
            }
            
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return ZZImageFormatWebP;
            }
    }
    return ZZImageFormatUndefined;
}

@end
