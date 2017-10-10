//
//  ZZWebImageDecoder.h
//  ZZWebImage
//
//  Created by Tony on 17/9/20.
//  Copyright © 2017年 58. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZWebImageCompat.h"

@interface UIImage (ForceDecode)

/**
 解码图片
 */
+ (nullable UIImage *)decodedImageWithImage:(nullable UIImage *)image;

+ (nullable UIImage *)decodedAndScaledDownImageWithImage:(nullable UIImage *)image;

@end
