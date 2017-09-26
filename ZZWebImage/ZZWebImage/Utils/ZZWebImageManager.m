//
//  ZZWebImageManager.m
//  ZZWebImage
//
//  Created by Tony on 17/9/12.
//  Copyright © 2017年 58. All rights reserved.
//

#import "ZZWebImageManager.h"

@interface ZZWebImageCombinedOperation : NSObject<ZZWebImageOperation>

@property (assign, nonatomic, getter = isCancelled) BOOL cancelled;
@property (copy, nonatomic, nullable) ZZWebImageNoParamsBlock cancelBlock;
@property (strong, nonatomic, nullable) NSOperation *cacheOperation;

@end

/**********************************************************************************/

@interface ZZWebImageManager ()

@property (strong, nonatomic, readwrite, nonnull) ZZImageCache *imageCache;
@property (strong, nonatomic, readwrite, nonnull) ZZWebImageDownloader *imageDownloader;
@property (strong, nonatomic, nullable) NSMutableSet<NSURL *> *failedURLs;
@property (strong, nonatomic, nullable) NSMutableArray<ZZWebImageCombinedOperation *> *runningOperations;

@end

@implementation ZZWebImageManager

+ (nonnull instancetype)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (nonnull instancetype)init {
    // 单例初始化ZZImageCache
    ZZImageCache *cache = [ZZImageCache sharedImageCache];
    ZZWebImageDownloader *downloader = [ZZWebImageDownloader sharedDownloader];
    return [self initWithCache:cache downloader:downloader];
}

- (nonnull instancetype)initWithCache:(nonnull ZZImageCache *)cache downloader:(nonnull ZZWebImageDownloader *)downloader {
    if ((self = [super init])) {
        _imageCache = cache;
        _imageDownloader = downloader;
        _failedURLs = [NSMutableSet new];
        _runningOperations = [NSMutableArray new];
    }
    return self;
}

- (nullable NSString *)cacheKeyForURL:(nullable NSURL *)url {
    if (!url) {
        return @"";
    }
    
    if (self.cacheKeyFilter) {
        return self.cacheKeyFilter(url);
    } else {
        return url.absoluteString;
    }
}

@end

/**********************************************************************************/

@implementation ZZWebImageCombinedOperation



@end





