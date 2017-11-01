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

/*
 //失败后重试
 SDWebImageRetryFailed = 1 << 0,
 
 //UI交互期间开始下载，导致延迟下载比如UIScrollView减速。
 SDWebImageLowPriority = 1 << 1,
 
 //只进行内存缓存
 SDWebImageCacheMemoryOnly = 1 << 2,
 
 //这个标志可以渐进式下载,显示的图像是逐步在下载
 SDWebImageProgressiveDownload = 1 << 3,
 
 //刷新缓存
 SDWebImageRefreshCached = 1 << 4,
 
 //后台下载
 SDWebImageContinueInBackground = 1 << 5,
 
 //NSMutableURLRequest.HTTPShouldHandleCookies = YES;
 
 SDWebImageHandleCookies = 1 << 6,
 
 //允许使用无效的SSL证书
 //SDWebImageAllowInvalidSSLCertificates = 1 << 7,
 
 //优先下载
 SDWebImageHighPriority = 1 << 8,
 
 //延迟占位符
 SDWebImageDelayPlaceholder = 1 << 9,
 
 //改变动画形象
 SDWebImageTransformAnimatedImage = 1 << 10,
 */

typedef NS_ENUM(NSUInteger, ZZWebImageOptions) {
    /**
     失败后重试
     */
    ZZWebImageRetryFailed = 1 << 0,
    
    /**
     * By default, placeholder images are loaded while the image is loading. This flag will delay the loading
     * of the placeholder image until after the image has finished loading.
     */
    ZZWebImageDelayPlaceholder = 1 << 9,
};

typedef void(^ZZExternalCompletionBlock)(UIImage * _Nullable image, NSError * _Nullable error, ZZImageCacheType cacheType, NSURL * _Nullable imageURL);

typedef void(^ZZInternalCompletionBlock)(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, ZZImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL);

typedef NSString * _Nullable (^ZZWebImageCacheKeyFilterBlock)(NSURL * _Nullable url);

@interface ZZWebImageManager : NSObject

#pragma mark - Properties

@property (nonatomic, strong, readonly, nullable) ZZImageCache *imageCache;
@property (nonatomic, strong, readonly, nullable) ZZWebImageDownloader *imageDownloader;

/**
 * The cache filter is a block used each time SDWebImageManager need to convert an URL into a cache key. This can
 * be used to remove dynamic part of an image URL.
 *
 * The following example sets a filter in the application delegate that will remove any query-string from the
 * URL before to use it as a cache key:
 *
 * @code
 
 [[SDWebImageManager sharedManager] setCacheKeyFilter:^(NSURL *url) {
 url = [[NSURL alloc] initWithScheme:url.scheme host:url.host path:url.path];
 return [url absoluteString];
 }];
 
 * @endcode
 */
@property (nonatomic, copy, nullable) ZZWebImageCacheKeyFilterBlock cacheKeyFilter;

#pragma mark - Methods

+ (nonnull instancetype)sharedManager;

- (nullable id<ZZWebImageOperation>)loadImageWithURL:(nullable NSURL *)url
                                             options:(ZZWebImageOptions)options
                                            progress:(nullable ZZWebImageDownloaderProgressBlock)progress
                                          completion:(nullable ZZInternalCompletionBlock)completionBlock;

/**
 *Return the cache key for a given URL
 */
- (nullable NSString *)cacheKeyForURL:(nullable NSURL *)url;

@end
