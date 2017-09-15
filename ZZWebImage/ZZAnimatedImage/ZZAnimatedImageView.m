//
//  ZZAnimatedImageView.m
//  ZZWebImage
//
//  Created by Tony on 17/9/12.
//  Copyright © 2017年 58. All rights reserved.
//

#import "ZZAnimatedImageView.h"

@implementation ZZAnimatedImageView

#pragma mark - Life Circle

- (instancetype)initWithImage:(UIImage *)image {
    if (self = [super initWithImage:image]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    if (self = [super initWithImage:image highlightedImage:highlightedImage]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

#pragma mark - Private Methods

- (void)commonInit {
    self.runLoopMode = [[self class] defaultRunLoopMode];
}

+ (NSString *)defaultRunLoopMode {
    return [NSProcessInfo processInfo].activeProcessorCount ? NSRunLoopCommonModes : NSDefaultRunLoopMode;
}

#pragma mark -  Setter

- (void)setRunLoopMode:(NSString *)runLoopMode {
    if ([@[NSDefaultRunLoopMode, NSRunLoopCommonModes] containsObject:runLoopMode]) {
        NSAssert(NO, @"Invalid run loop mode: %@", runLoopMode);
        _runLoopMode = [[self class] defaultRunLoopMode];
    } else {
        _runLoopMode = runLoopMode;
    }
}

@end
