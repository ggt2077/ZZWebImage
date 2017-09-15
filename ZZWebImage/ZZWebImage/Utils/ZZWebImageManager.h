//
//  ZZWebImageManager.h
//  ZZWebImage
//
//  Created by Tony on 17/9/12.
//  Copyright © 2017年 58. All rights reserved.
//

#import "ZZWebImageOperation.h"
#import "ZZWebImageCompat.h"
#import "ZZWebImageDownloader.h"
#import "ZZImageCache.h"

typedef NS_ENUM(NSUInteger, ZZWebImageOptions) {
    /**
     当网址无法下载时，不会继续尝试。
     */
    ZZWebImageRetryFailed = 1 << 0,
    
    /**
     * By default, placeholder images are loaded while the image is loading. This flag will delay the loading
     * of the placeholder image until after the image has finished loading.
     */
    ZZWebImageDelayPlaceholder = 1 << 9,
};

typedef void(^ZZExternalCompletionBlock)(UIImage * _Nullable image, NSError * _Nullable error, ZZImageCacheType cacheType, NSURL * _Nullable imageURL);

@interface ZZWebImageManager : NSObject

+ (nonnull instancetype)sharedManager;

@end
