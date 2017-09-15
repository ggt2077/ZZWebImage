//
//  UIView+WebCache.m
//  ZZWebImage
//
//  Created by Tony on 17/9/13.
//  Copyright © 2017年 58. All rights reserved.
//

#import "UIView+WebCache.h"
#import "UIView+WebCacheOperation.h"
#import "objc/runtime.h"

static char imageURLKey;

static char TAG_ACTIVITY_INDICATOR;
static char TAG_ACTIVITY_STYLE;
static char TAG_ACTIVITY_SHOW;

@implementation UIView (WebCache)

#pragma mark - Public Methods

- (void)zz_internalSetImageWithURL:(nullable NSURL *)url
                  placeholderImage:(nullable UIImage *)placeholder
                           options:(ZZWebImageOptions)options
                      operationKey:(nullable NSString *)operationKey
                     setImageBlock:(nullable ZZSetImageBlock)setImageBlock
                          progress:(nullable ZZWebImageDownloaderProgressBlock)progressBlock
                         completed:(nullable ZZExternalCompletionBlock)completedBlock{
    NSString *validOperationKey = operationKey ?: NSStringFromClass([self class]);
    [self zz_cancelImageLoadOperationWithKey:validOperationKey];
    objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!(options & ZZWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            [self zz_setImage:placeholder imageData:nil basedOnClassOrViaCustomSetImageBlock:setImageBlock];
        })
    }
    // TODO: 这里还没弄好
    if (url) {
        // check if activityView is enabled or not
        if ([self zz_showActivityIndicatorView]) {
            [self zz_addActivityIndicator];
        }
        
        @weakify(self);
        id<ZZWebImageOperation> operation = [];
    }
}

- (BOOL)zz_showActivityIndicatorView {
    return [objc_getAssociatedObject(self, &TAG_ACTIVITY_SHOW) boolValue];
}

- (void)zz_addActivityIndicator {
    dispatch_main_async_safe(^{
        if (!self.activityIndicator) {
            self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:[self zz_getIndicatorStyle]];
            self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
            
            [self addSubview:self.activityIndicator];
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1.0
                                                              constant:0.0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.0
                                                              constant:0.0]];
            
        }
        [self.activityIndicator startAnimating];
    });
}

- (void)zz_removeActivityIndicator {
    dispatch_main_async_safe(^{
        if (self.activityIndicator) {
            [self.activityIndicator removeFromSuperview];
            self.activityIndicator = nil;
        }
    });
}

#pragma mark - Private Methods

- (void)zz_setImage:(UIImage *)image imageData:(NSData *)imageData basedOnClassOrViaCustomSetImageBlock:(ZZSetImageBlock)setImageBlock {
    if (setImageBlock) {
        setImageBlock(image, imageData);
        return;
    }
    
    if ([self isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)self;
        imageView.image = image;
    } else if ([self isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)self;
        [button setImage:image forState:UIControlStateNormal];
    }
}

#pragma mark -  Activity indicator

- (void)setActivityIndicator:(UIActivityIndicatorView *)activityIndicator {
    objc_setAssociatedObject(self, &TAG_ACTIVITY_INDICATOR, activityIndicator, OBJC_ASSOCIATION_RETAIN);
}

- (UIActivityIndicatorView *)activityIndicator {
    return (UIActivityIndicatorView *)objc_getAssociatedObject(self, &TAG_ACTIVITY_INDICATOR);
}

- (void)zz_setIndicatorStyle:(UIActivityIndicatorViewStyle)style {
    objc_setAssociatedObject(self, &TAG_ACTIVITY_STYLE, [NSNumber numberWithInt:style], OBJC_ASSOCIATION_RETAIN);
}

- (int)zz_getIndicatorStyle {
    return [objc_getAssociatedObject(self, &TAG_ACTIVITY_STYLE) intValue];
}

@end
