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

/**
 *Return the cache key for a given URL
 */
- (nullable NSString *)cacheKeyForURL:(nullable NSURL *)url;

@end
