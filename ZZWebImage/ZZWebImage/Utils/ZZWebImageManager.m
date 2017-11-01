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

- (nullable id<ZZWebImageOperation>)loadImageWithURL:(nullable NSURL *)url
                                             options:(ZZWebImageOptions)options
                                            progress:(nullable ZZWebImageDownloaderProgressBlock)progress
                                          completion:(nullable ZZInternalCompletionBlock)completedBlock {
    // Invoking this method without a completedBlock is pointless
    NSAssert(completedBlock != nil, @"If you mean to prefetch the image, use -[ZZWebImagePrefetcher prefetchURLs] instead");
    
    // Very common mistake is to send the URL using NSString object instead of NSURL. For some strange reason, Xcode won't
    // throw any warning for this type mismatch. Here we failsafe this error by allowing URLs to be passed as NSString.
    if ([url isKindOfClass:NSString.class]) {
        url = [NSURL URLWithString:(NSString *)url];
    }
    
    if (![url isKindOfClass:NSURL.class]) {
        url = nil;
    }
    
    __block ZZWebImageCombinedOperation *operation = [ZZWebImageCombinedOperation new];
    __weak ZZWebImageCombinedOperation *weakOperation = operation;
    
    BOOL isFailedUrl = NO;
    if (url) {
        // 加线程锁
        @synchronized (self.failedURLs) {
            isFailedUrl = [self.failedURLs containsObject:url];
        }
    }
    
    if (url.absoluteString.length == 0 || (!(options & ZZWebImageRetryFailed) && isFailedUrl)) {
        [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil] url:url];
        return operation;
    }
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

- (void)callCompletionBlockForOperation:(nullable ZZWebImageCombinedOperation*)operation
                             completion:(nullable ZZInternalCompletionBlock)completionBlock
                                  error:(nullable NSError *)error
                                    url:(nullable NSURL *)url {
    [self callCompletionBlockForOperation:operation completion:completionBlock image:nil data:nil error:error cacheType:ZZImageCacheTypeNone finished:YES url:url];
}

- (void)callCompletionBlockForOperation:(nullable ZZWebImageCombinedOperation*)operation
                             completion:(nullable ZZInternalCompletionBlock)completionBlock
                                  image:(nullable UIImage *)image
                                   data:(nullable NSData *)data
                                  error:(nullable NSError *)error
                              cacheType:(ZZImageCacheType)cacheType
                               finished:(BOOL)finished
                                    url:(nullable NSURL *)url {
    dispatch_main_async_safe(^{
        if (operation && !operation.isCancelled && completionBlock) {
            completionBlock(image, data, error, cacheType, finished, url);
        }
    });
}

@end

/**********************************************************************************/

@implementation ZZWebImageCombinedOperation

- (void)setCancelBlock:(ZZWebImageNoParamsBlock)cancelBlock {
    // check if the operation is already cancelled, then we just call the cancelBlock
    if (self.isCancelled) {
        if (cancelBlock) {
            cancelBlock();
        }
        _cancelBlock = nil;
    } else {
        _cancelBlock = [cancelBlock copy];
    }
}

- (void)cancel {
    self.cancelled = YES;
    if (self.cacheOperation) {
        [_cacheOperation cancel];
        self.cacheOperation = nil;
    }
    if (self.cancelBlock) {
        self.cancelBlock();
        
        // TODO: this is a temporary fix to #809.
        // Until we can figure the exact cause of the crash, going with the ivar instead of the setter
//        self.cancelBlock = nil;
        _cancelBlock = nil;
    }
}

@end





