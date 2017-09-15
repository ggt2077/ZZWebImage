//
//  UIView+WebCacheOperation.h
//  ZZWebImage
//
//  Created by Tony on 17/9/13.
//  Copyright © 2017年 58. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZWebImageManager.h"

@interface UIView (WebCacheOperation)

/**
 Set the image load operation (storage in a UIView based dictionary)

 @param operation the operation
 @param key       key for storing the operation
 */
- (void)zz_setImageLoadOperation:(nullable id)operation forKey:(nullable NSString *)key;

/**
 Cancel all operations for the current UIView and key

 @param key key for identifying the operations
 */
- (void)zz_cancelImageLoadOperationWithKey:(nullable NSString *)key;

/**
 Just remove the operations corresponding to the current UIView and key without cancelling them

 @param key key for identifying the operations
 */
- (void)zz_removeImageLoadOperationWithKey:(nullable NSString *)key;

@end
