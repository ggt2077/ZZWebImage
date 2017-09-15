//
//  ZZImageCacheConfig.m
//  ZZWebImage
//
//  Created by Tony on 17/9/14.
//  Copyright © 2017年 58. All rights reserved.
//

#import "ZZImageCacheConfig.h"

static const NSInteger kDefaultCacheMaxCacheAge = 60 * 60 * 24 * 7; // 1 week

@implementation ZZImageCacheConfig

- (instancetype)init {
    if (self = [super init]) {
        _maxCacheAge = kDefaultCacheMaxCacheAge;
        _maxCacheSize = 0;
    }
    return self;
}

@end
