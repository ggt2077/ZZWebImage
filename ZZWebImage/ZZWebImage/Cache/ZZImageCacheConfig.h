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
 * The maximum length of time to keep an image in the cache, in seconds
 */
@property (nonatomic, assign) NSInteger maxCacheAge;

/**
 * The maximum size of the cache, in bytes.
 */
@property (assign, nonatomic) NSUInteger maxCacheSize;

@end
