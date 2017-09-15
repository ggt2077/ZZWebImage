//
//  ZZWebImageDownloader.m
//  ZZWebImage
//
//  Created by Tony on 17/9/13.
//  Copyright © 2017年 58. All rights reserved.
//

#import "ZZWebImageDownloader.h"
#import "ZZWebImageDownloaderOperation.h"

@interface ZZWebImageDownloader ()

@property (assign, nonatomic, nullable) Class operationClass;

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
        [[NSNotificationCenter defaultCenter] removeObserver:activityIndicator name:<#(nullable NSNotificationName)#> object:<#(nullable id)#>]
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
    return [self init];
}

- (nonnull instancetype)initWithSessionConfiguration:(nonnull NSURLSessionConfiguration *)sessionConfiguration {
    if (self = [super init]) {
        
    }
}

@end
