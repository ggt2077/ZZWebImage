//
//  ZZAnimatedImageView+WebCache.h
//  ZZWebImage
//
//  Created by Tony on 17/9/12.
//  Copyright © 2017年 58. All rights reserved.
//

#import "ZZAnimatedImageView.h"
#import "ZZWebImageManager.h"

@interface ZZAnimatedImageView (WebCache)

- (void)zz_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(ZZWebImageOptions)options NS_REFINED_FOR_SWIFT;

- (void)zz_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(ZZWebImageOptions)options
                  progress:(nullable ZZWebImageDownloaderProgressBlock)progressBlock
                 completed:(nullable ZZExternalCompletionBlock)completedBlock;

@end
