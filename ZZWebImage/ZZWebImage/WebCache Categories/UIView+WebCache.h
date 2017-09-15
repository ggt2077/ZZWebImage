//
//  UIView+WebCache.h
//  ZZWebImage
//
//  Created by Tony on 17/9/13.
//  Copyright © 2017年 58. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZZWebImageManager.h"

typedef void(^ZZSetImageBlock)(UIImage * _Nullable image, NSData * _Nullable imageData);

@interface UIView (WebCache)

- (void)zz_internalSetImageWithURL:(nullable NSURL *)url
                  placeholderImage:(nullable UIImage *)placeholder
                           options:(ZZWebImageOptions)options
                      operationKey:(nullable NSString *)operationKey
                     setImageBlock:(nullable ZZSetImageBlock)setImageBlock
                          progress:(nullable ZZWebImageDownloaderProgressBlock)progressBlock
                         completed:(nullable ZZExternalCompletionBlock)completedBlock;

- (BOOL)zz_showActivityIndicatorView;
- (void)zz_addActivityIndicator;
- (void)zz_removeActivityIndicator;

@end
