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

/**
 * Add a read-only cache path to search for images pre-cached by SDImageCache
 * Useful if you want to bundle pre-loaded images with your app
 *
 * @param path The path to use for this read-only cache path
 */
- (void)addReadOnlyCachePath:(nonnull NSString *)path;

#pragma mark - Store Ops

/**
 * Asynchronously store an image into memory and disk cache at the given key.
 *
 * @param image           The image to store
 * @param key             The unique image cache key, usually it's image absolute URL
 * @param completionBlock A block executed after the operation is finished
 */
- (void)storeImage:(nullable UIImage *)image
            forKey:(nullable NSString *)key
        completion:(nullable ZZWebImageNoParamsBlock)completionBlock;

/**
 * Asynchronously store an image into memory and disk cache at the given key.
 *
 * @param image           The image to store
 * @param key             The unique image cache key, usually it's image absolute URL
 * @param toDisk          Store the image to disk cache if YES
 * @param completionBlock A block executed after the operation is finished
 */
- (void)storeImage:(nullable UIImage *)image
            forKey:(nullable NSString *)key
            toDisk:(BOOL)toDisk
        completion:(nullable ZZWebImageNoParamsBlock)completionBlock;

/**
 * Asynchronously store an image into memory and disk cache at the given key.
 *
 * @param image           The image to store
 * @param imageData       The image data as returned by the server, this representation will be used for disk storage
 *                        instead of converting the given image object into a storable/compressed image format in order
 *                        to save quality and CPU
 * @param key             The unique image cache key, usually it's image absolute URL
 * @param toDisk          Store the image to disk cache if YES
 * @param completionBlock A block executed after the operation is finished
 */
- (void)storeImage:(nullable UIImage *)image
         imageData:(nullable NSData *)imageData
            forKey:(nullable NSString *)key
            toDisk:(BOOL)toDisk
        completion:(nullable ZZWebImageNoParamsBlock)completionBlock;

/**
 * Synchronously store image NSData into disk cache at the given key.
 *
 * @warning This method is synchronous, make sure to call it from the ioQueue
 *
 * @param imageData  The image data to store
 * @param key        The unique image cache key, usually it's image absolute URL
 */
- (void)storeImageDataToDisk:(nullable NSData *)imageData forKey:(nullable NSString *)key;

@end
