//
//  UIImage+WebP.h
//  ZZWebImage
//
//  Created by Tony on 2017/10/17.
//  Copyright © 2017年 58. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (WebP)

/**
 * Get the current WebP image loop count, the default value is 0.
 * For static WebP image, the value is 0.
 * For animated WebP image, 0 means repeat the animation indefinitely.
 * Note that because of the limitations of categories this property can get out of sync
 * if you create another instance with CGImage or other methods.
 * @return WebP image loop count
 */
- (NSInteger)zz_webpLoopCount;

// WebP图片的二进制数据转为UIImage的方法,但是想要使用它，还必须先在项目中导入WebP的解析器libwebp,本项目是直接将代码拖进工程的
+ (nullable UIImage *)zz_imageWithWebPData:(nullable NSData *)data;

@end
