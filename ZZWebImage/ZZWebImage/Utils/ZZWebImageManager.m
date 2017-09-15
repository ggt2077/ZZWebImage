//
//  ZZWebImageManager.m
//  ZZWebImage
//
//  Created by Tony on 17/9/12.
//  Copyright © 2017年 58. All rights reserved.
//

#import "ZZWebImageManager.h"

@implementation ZZWebImageManager

+ (nonnull instancetype)sharedManager {
    static dispatch_once_t once;
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (nonnull instancetype)init {
    // 单例初始化ZZImageCache
    ZZImageCache *cache = [ZZImageCache sharedImageCache];
}
@end
