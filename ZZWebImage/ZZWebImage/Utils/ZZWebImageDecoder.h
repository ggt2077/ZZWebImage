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

+ (nullable UIImage *)decodedImageWithImage:(nullable UIImage *)image;

@end
