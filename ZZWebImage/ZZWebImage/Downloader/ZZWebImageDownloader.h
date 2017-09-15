//
//  ZZWebImageDownloader.h
//  ZZWebImage
//
//  Created by Tony on 17/9/13.
//  Copyright © 2017年 58. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ZZWebImageDownloaderProgressBlock)(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL);

@interface ZZWebImageDownloader : NSObject

+ (nonnull instancetype)sharedDownloader;

- (nonnull instancetype)initWithSessionConfiguration:(nonnull NSURLSessionConfiguration *)sessionConfiguration;

@end
