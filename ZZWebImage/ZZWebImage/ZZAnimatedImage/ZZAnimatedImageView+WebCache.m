//
//  ZZAnimatedImageView+WebCache.m
//  ZZWebImage
//
//  Created by Tony on 17/9/12.
//  Copyright © 2017年 58. All rights reserved.
//

#import "ZZAnimatedImageView+WebCache.h"

@implementation ZZAnimatedImageView (WebCache)

- (void)zz_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(ZZWebImageOptions)options{
    
}

- (void)zz_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(ZZWebImageOptions)options
                  progress:(nullable ZZWebImageDownloaderProgressBlock)progressBlock
                 completed:(nullable ZZExternalCompletionBlock)completedBlock {
//    @weakify(self);
}

@end
