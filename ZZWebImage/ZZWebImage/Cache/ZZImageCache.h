//
//  ZZImageCache.h
//  ZZWebImage
//
//  Created by Tony on 17/9/13.
//  Copyright © 2017年 58. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZWebImageCompat.h"
#import "ZZImageCacheConfig.h"

typedef NS_ENUM(NSUInteger, ZZImageCacheType) {
    /**
     不使用缓存，直接从网络下载
     */
    ZZImageCacheTypeNone,
};

@interface ZZImageCache : NSObject

#pragma mark - Properties

/**
 缓存配置实体--存储各种设置信息
 */
@property (nonatomic, nonnull, readonly) ZZImageCacheConfig *config;

#pragma mark - Singleton and initialization

+ (nonnull instancetype)sharedImageCache;

- (nonnull instancetype)initWithNamespace:(nonnull NSString *)ns;

- (nonnull instancetype)initWithNamespace:(nonnull NSString *)ns
                       diskCacheDirectory:(nonnull NSString *)directory;

#pragma mark - Cache clean Ops

/**
 * Clear all memory cached images
 */
- (void)clearMemory;

/**
 * Async remove all expired cached image from disk. Non-blocking method - returns immediately.
 * @param completionBlock A block that should be executed after cache expiration completes (optional)
 */
- (void)deleteOldFilesWithCompletionBlock:(nullable ZZWebImageNoParamsBlock)completionBlock;

#pragma mark - Cache paths

- (nonnull NSString *)makeDiskCachePath:(nonnull NSString *)fullNameSpace;

@end
