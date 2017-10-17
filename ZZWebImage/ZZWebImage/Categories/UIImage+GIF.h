//
//  UIImage+GIF.h
//  ZZWebImage
//
//  Created by Tony on 2017/10/17.
//  Copyright © 2017年 58. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (GIF)

/**
 *  Compatibility method - creates an animated UIImage from an NSData, it will only contain the 1st frame image
    兼容性方法 - 从NSData创建一个动画UIImage，它只包含第一帧图像
 */
+ (UIImage *)zz_animatedGIFWithData:(NSData *)data;

/**
 *  Checks if an UIImage instance is a GIF. Will use the `images` array
 */
- (BOOL)isGIF;

@end
