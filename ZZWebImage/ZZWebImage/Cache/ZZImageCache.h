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

/**
 * The maximum "total cost" of the in-memory image cache. The cost function is the number of pixels held in memory.
 内存最大缓存
 
 可以通过maxMemoryCost来设置内存的最大缓存是多少，这个是以像素为单位的。
 */
@property (assign, nonatomic) NSUInteger maxMemoryCost;

/**
 * The maximum number of objects the cache should hold.
 最大内存缓存数量
 
 可以通过maxMemoryCountLimit来设置内存的最大缓存数量是多少。
 */
@property (assign, nonatomic) NSUInteger maxMemoryCountLimit;

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
