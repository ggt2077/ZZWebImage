//
//  ZZImageCacheConfig.h
//  ZZWebImage
//
//  Created by Tony on 17/9/14.
//  Copyright © 2017年 58. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZZImageCacheConfig : NSObject

/**
 * Decompressing images that are downloaded and cached can improve performance but can consume lot of memory.
 * Defaults to YES. Set this to NO if you are experiencing a crash due to excessive memory consumption.
   是否解压缩图片，默认为YES
 */
@property (assign, nonatomic) BOOL shouldDecompressImages;

/**
 *  disable iCloud backup [defaults to YES]
    是否禁用iCloud备份， 默认为YES
 */
@property (assign, nonatomic) BOOL shouldDisableiCloud;

/**
 * use memory cache [defaults to YES]
   是否缓存到内存中，默认为YES
 */
@property (assign, nonatomic) BOOL shouldCacheImagesInMemory;

/**
 * The maximum length of time to keep an image in the cache, in seconds
   最大的缓存不过期时间， 单位为秒，默认为一周的时间
 */
@property (nonatomic, assign) NSInteger maxCacheAge;

/**
 * The maximum size of the cache, in bytes.
   最大的缓存尺寸，单位为字节
 */
@property (assign, nonatomic) NSUInteger maxCacheSize;

@end
