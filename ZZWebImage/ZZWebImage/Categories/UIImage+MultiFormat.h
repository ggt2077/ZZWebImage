//
//  UIImage+MultiFormat.h
//  ZZWebImage
//
//  Created by Tony on 2017/10/17.
//  Copyright © 2017年 58. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSData+ImageContentType.h"

@interface UIImage (MultiFormat)

+ (nullable UIImage *)zz_imageWithData:(nullable NSData *)data;
- (nullable NSData *)zz_imageData;
- (nullable NSData *)zz_imageDataAsFormat:(ZZImageFormat)imageFormat;

@end
