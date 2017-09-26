//
//  ZZWebImageDownloader.h
//  ZZWebImage
//
//  Created by Tony on 17/9/13.
//  Copyright © 2017年 58. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZWebImageCompat.h"

typedef NS_OPTIONS(NSUInteger, ZZWebImageDownloaderOptions) {
    ZZWebImageDownloaderLowPriority = 1 << 0,
    ZZWebImageDownloaderProgressiveDownload = 1 << 1,
    
    /**
     * By default, request prevent the use of NSURLCache. With this flag, NSURLCache
     * is used with default policies.
     */
    ZZWebImageDownloaderUseNSURLCache = 1 << 2,
};

typedef NS_ENUM(NSInteger, ZZWebImageDownloaderExecutionOrder) {
    /**
     * Default value. All download operations will execute in queue style (first-in-first-out).
     */
    ZZWebImageDownloaderFIFOExecutionOrder,
    
    /**
     * All download operations will execute in stack style (last-in-first-out).
     */
    ZZWebImageDownloaderLIFOExecutionOrder
};

typedef void(^ZZWebImageDownloaderProgressBlock)(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL);

typedef void(^ZZWebImageDownloaderCompletedBlock)(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished);

typedef NSDictionary<NSString *, NSString *> ZZHTTPHeadersDictionary;
typedef NSMutableDictionary<NSString *, NSString *> ZZHTTPHeadersMutableDictionary;

@interface ZZWebImageDownloader : NSObject

/**
 * Decompressing images that are downloaded and cached can improve performance but can consume lot of memory.
 * Defaults to YES. Set this to NO if you are experiencing a crash due to excessive memory consumption.
 */
@property (nonatomic, assign) BOOL shouldDecompressImages;

/**
 *  The timeout value (in seconds) for the download operation. Default: 15.0.
 */
@property (nonatomic, assign) NSTimeInterval downloadTimeout;

/**
 * Changes download operations execution order. Default value is `SDWebImageDownloaderFIFOExecutionOrder`.
 */
@property (assign, nonatomic) ZZWebImageDownloaderExecutionOrder executionOrder;

/**
 * Decompressing images that are downloaded and cached can improve performance but can consume lot of memory.
 * Defaults to YES. Set this to NO if you are experiencing a crash due to excessive memory consumption.
 */
+ (nonnull instancetype)sharedDownloader;

/**
 * Creates an instance of a downloader with specified session configuration.
 * *Note*: `timeoutIntervalForRequest` is going to be overwritten.
 * @return new instance of downloader class
 */
- (nonnull instancetype)initWithSessionConfiguration:(nonnull NSURLSessionConfiguration *)sessionConfiguration;

/**
 * Cancels all download operations in the queue
 */
- (void)cancelAllDownloads;

/**
 * Forces ZZWebImageDownloader to create and use a new NSURLSession that is
 * initialized with the given configuration.
 * *Note*: All existing download operations in the queue will be cancelled.
 * *Note*: `timeoutIntervalForRequest` is going to be overwritten.
 *
 * @param sessionConfiguration The configuration to use for the new NSURLSession
 */
- (void)createNewSessionWithConfiguration:(nonnull NSURLSessionConfiguration *)sessionConfiguration;

@end
