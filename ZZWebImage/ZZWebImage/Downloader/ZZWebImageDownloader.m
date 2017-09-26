//
//  ZZWebImageDownloader.m
//  ZZWebImage
//
//  Created by Tony on 17/9/13.
//  Copyright © 2017年 58. All rights reserved.
//

#import "ZZWebImageDownloader.h"
#import "ZZWebImageDownloaderOperation.h"

@interface ZZWebImageDownloader ()<NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong, nonnull) NSOperationQueue *downloadQueue;
@property (assign, nonatomic, nullable) Class operationClass;
@property (nonatomic, strong, nullable) ZZHTTPHeadersMutableDictionary *HTTPHeaders;
// This queue is used to serialize the handling of the network responses of all the download operation in a single queue
@property (ZZDispatchQueueSetterSementics, nonatomic, nullable) dispatch_queue_t barrierQueue;

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation ZZWebImageDownloader

+ (void)initialize {
    // Bind ZZNetworkActivityIndicator if available (download it here: http://github.com/rs/SDNetworkActivityIndicator )
    // To use it, just add #import "ZZNetworkActivityIndicator.h" in addition to the ZZWebImage import
    
    if (NSClassFromString(@"ZZNetworkActivityIndicator")) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id activityIndicator = [NSClassFromString(@"ZZNetworkActivityIndicator") performSelector:NSSelectorFromString(@"sharedActivityIndicator")];
#pragma clang diagnostic pop
        
        //
        [[NSNotificationCenter defaultCenter] removeObserver:activityIndicator name:ZZWebImageDownloadStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:activityIndicator name:ZZWebImageDownloadStopNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:activityIndicator selector:NSSelectorFromString(@"startActivity") name:ZZWebImageDownloadStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:activityIndicator selector:NSSelectorFromString(@"stopActivity") name:ZZWebImageDownloadStopNotification object:nil];
    }
}

+ (nonnull instancetype)sharedDownloader {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (nonnull instancetype)init {
    return [self initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
}

- (nonnull instancetype)initWithSessionConfiguration:(nonnull NSURLSessionConfiguration *)sessionConfiguration {
    if (self = [super init]) {
        _operationClass = [ZZWebImageDownloaderOperation class];
        _shouldDecompressImages = YES;
        _executionOrder = ZZWebImageDownloaderFIFOExecutionOrder;
        _downloadQueue = [NSOperationQueue new];
        _downloadQueue.maxConcurrentOperationCount = 6;
        _downloadQueue.name = @"com.zhuanzhuan.ZZWebImageDownloader";
#ifdef SD_WEBP
        _HTTPHeaders = [@{@"Accept": @"image/webp,image/*;q=0.8"} mutableCopy];
#else
        _HTTPHeaders = [@{@"Accept": @"image/*;q=0.8"} mutableCopy];
#endif
        _barrierQueue = dispatch_queue_create("com.zhuanzhuan.ZZWebImageDownloaderBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
        _downloadTimeout = 15.0;
        [self createNewSessionWithConfiguration:sessionConfiguration];
    }
    return self;
}

- (void)createNewSessionWithConfiguration:(NSURLSessionConfiguration *)sessionConfiguration {
    [self cancelAllDownloads];
    
    if (self.session) [self.session invalidateAndCancel];
    
    sessionConfiguration.timeoutIntervalForRequest = self.downloadTimeout;
    
    self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
}

- (void)cancelAllDownloads {
    [self.downloadQueue cancelAllOperations];
}

#pragma mark Helper methods

- (ZZWebImageDownloaderOperation *)operationWithTask:(NSURLSessionTask *)task {
    ZZWebImageDownloaderOperation *returnOperation = nil;
    for (ZZWebImageDownloaderOperation *operation in self.downloadQueue.operations) {
        if (operation.dataTask.taskIdentifier == task.taskIdentifier) {
            returnOperation = operation;
            break;
        }
    }
    return returnOperation;
}

#pragma mark NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    ZZWebImageDownloaderOperation *dataOperation = [self operationWithTask:dataTask];
    // Identify the operation that runs this task and pass it the delegate method
    
    [dataOperation URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    
    // Identify the operation that runs this task and pass it the delegate method
    ZZWebImageDownloaderOperation *dataOperation = [self operationWithTask:dataTask];
    
    [dataOperation URLSession:session dataTask:dataTask didReceiveData:data];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler {
    
    // Identify the operation that runs this task and pass it the delegate method
    ZZWebImageDownloaderOperation *dataOperation = [self operationWithTask:dataTask];
    
    [dataOperation URLSession:session dataTask:dataTask willCacheResponse:proposedResponse completionHandler:completionHandler];
}

#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    // Identify the operation that runs this task and pass it the delegate method
    ZZWebImageDownloaderOperation *dataOperation = [self operationWithTask:task];
    
    [dataOperation URLSession:session task:task didCompleteWithError:error];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    
    completionHandler(request);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    
    // Identify the operation that runs this task and pass it the delegate method
    ZZWebImageDownloaderOperation *dataOperation = [self operationWithTask:task];
    
    [dataOperation URLSession:session task:task didReceiveChallenge:challenge completionHandler:completionHandler];
}

@end
