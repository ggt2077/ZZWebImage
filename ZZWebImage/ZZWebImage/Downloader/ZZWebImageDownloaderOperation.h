//
//  ZZWebImageDownloaderOperation.h
//  ZZWebImage
//
//  Created by Tony on 17/9/15.
//  Copyright © 2017年 58. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZWebImageDownloader.h"

FOUNDATION_EXPORT NSString * _Nonnull const ZZWebImageDownloadStartNotification;
FOUNDATION_EXPORT NSString * _Nonnull const ZZWebImageDownloadReceiveResponseNotification;
FOUNDATION_EXPORT NSString * _Nonnull const ZZWebImageDownloadStopNotification;
FOUNDATION_EXPORT NSString * _Nonnull const ZZWebImageDownloadFinishNotification;

@interface ZZWebImageDownloaderOperation : NSOperation<NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

/**
 * The request used by the operation's task.
 */
@property (nonatomic, strong, readonly, nullable) NSURLRequest *request;

/**
 * The response returned by the operation's connection.
 */
@property (strong, nonatomic, nullable) NSURLResponse *response;

/**
 * The expected size of data.
 */
@property (assign, nonatomic) NSInteger expectedSize;

/**
 * The operation's task
 */
@property (nonatomic, strong, readonly, nullable) NSURLSessionTask *dataTask;

@property (nonatomic, assign) BOOL shouldDecompressImages;

/**
 * The ZZWebImageDownloaderOptions for the receiver.
 */
@property (assign, nonatomic, readonly) ZZWebImageDownloaderOptions options;

@end
