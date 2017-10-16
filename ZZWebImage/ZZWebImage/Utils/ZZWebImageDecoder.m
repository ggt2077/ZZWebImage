//
//  ZZWebImageDecoder.m
//  ZZWebImage
//
//  Created by Tony on 17/9/20.
//  Copyright © 2017年 58. All rights reserved.
//

#import "ZZWebImageDecoder.h"

@implementation UIImage (ForceDecode)

#if SD_UIKIT || SD_WATCH
// 用来说明每个像素占用内存多少个字节，在这里是占用4个字节。（图像在iOS设备上是以像素为单位显示的）
static const size_t kBytesPerPixel = 4;
// 每个颜色的比特数，例如在rgba-32模式下为8;这个不太好理解，我们先举个例子，比方说RGBA，其中R（红色）G（绿色）B（蓝色）A（透明度）是4个颜色组件，每个像素由这4个颜色组件组成，那么我们就用8位来表示着每一个颜色组件，所以这个RGBA就是8*4 = 32位。
static const size_t kBitsPerComponent = 8;

#pragma mark - Public Methods

+ (nullable UIImage *)decodedImageWithImage:(nullable UIImage *)image {
    if (![UIImage shouldDecodeImage:image]) {
        return image;
    }
    // 自动释放位图上下文和所有vars，以帮助系统在存在内存警告时释放内存。
    // 在iOS7上，别忘了调用[[SDImageCache sharedImageCache] clearMemory];
    @autoreleasepool {
        // 获取位图
        CGImageRef imageRef = image.CGImage;
        // 颜色空间
        CGColorSpaceRef colorspaceRef = [UIImage colorSpaceForImageRef:imageRef];
        // 宽
        size_t width = CGImageGetWidth(imageRef);
        // 高
        size_t height = CGImageGetHeight(imageRef);
        // 计算出每行的像素数
        size_t bytesPerRow = kBytesPerPixel * width;
        
        /*
         创建没有透明因素的bitmap graphics contexts
         
         * 注意：这里创建的contexts是没有透明因素的。在UI渲染的时候，实际上是把多个图层按像素叠加计算的过程，需要对每一个像素进行 RGBA 的叠加计算。当某个 layer 的是不透明的，也就是 opaque 为 YES 时，GPU 可以直接忽略掉其下方的图层，这就减少了很多工作量。这也是调用 CGBitmapContextCreate 时 bitmapInfo 参数设置为忽略掉 alpha 通道的原因。
         */
        CGContextRef context = CGBitmapContextCreate(NULL, width, height, kBitsPerComponent, bytesPerRow, colorspaceRef, kCGBitmapByteOrderDefault|kCGImageAlphaNoneSkipLast);
        
        if (context == NULL) {
            return image;
        }
        
        // 绘制图像
        // Draw the image into the context and retrieve the new bitmap image without alpha
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        CGImageRef imageRefWithoutAlpha = CGBitmapContextCreateImage(context);
        UIImage *imageWithoutAlpha = [UIImage imageWithCGImage:imageRefWithoutAlpha
                                                         scale:image.scale
                                                   orientation:image.imageOrientation];
        
        CGContextRelease(context);
        CGImageRelease(imageRefWithoutAlpha);
        
        return imageWithoutAlpha;
    }
}

/*
 最大支持压缩图像源的大小
 * Defines the maximum size in MB of the decoded image when the flag `SDWebImageScaleDownLargeImages` is set
 * Suggested value for iPad1 and iPhone 3GS: 60.
 * Suggested value for iPad2 and iPhone 4: 120.
 * Suggested value for iPhone 3G and iPod 2 and earlier devices: 30.
 */
static const CGFloat kDestImageSizeMB = 60.0f;

/*
 这个方块将会被用来分割原图，默认设置为20M。
 * Defines the maximum size in MB of a tile used to decode image when the flag `SDWebImageScaleDownLargeImages` is set
 * Suggested value for iPad1 and iPhone 3GS: 20.
 * Suggested value for iPad2 and iPhone 4: 40.
 * Suggested value for iPhone 3G and iPod 2 and earlier devices: 10.
 */
static const CGFloat kSourceImageTileSizeMB = 20.0f;

// 1M有多少字节
static const CGFloat kBytesPerMB = 1024.0f * 1024.0f;
// 1M有多少像素
static const CGFloat kPixelsPerMB = kBytesPerMB / kBytesPerPixel;
// 目标总像素
static const CGFloat kDestTotalPixels = kDestImageSizeMB * kPixelsPerMB;
// 原图放款总像素
static const CGFloat kTileTotalPixels = kSourceImageTileSizeMB * kPixelsPerMB;
// 重叠像素大小
static const CGFloat kDestSeemOverlap = 2.0f;   // the numbers of pixels to overlap the seems where tiles meet.

+ (nullable UIImage *)decodedAndScaledDownImageWithImage:(nullable UIImage *)image {
    if (![UIImage shouldDecodeImage:image]) {
        return image;
    }
    
    if (![UIImage shouldScaleDownImage:image]) {
        return [UIImage decodedImageWithImage:image];
    }
    
    CGContextRef destContext;
    
    // autorelease the bitmap context and all vars to help system to free memory when there are memory warning.
    // on iOS7, do not forget to call [[SDImageCache sharedImageCache] clearMemory];
    @autoreleasepool {
        // 拿到数据信息 sourceImageRef
        CGImageRef sourceImageRef = image.CGImage;
        // 计算原图的像素 sourceResolution
        CGSize sourceResolution = CGSizeZero;
        sourceResolution.width = CGImageGetWidth(sourceImageRef);
        sourceResolution.height = CGImageGetHeight(sourceImageRef);
        // 计算原图总像素 sourceTotalPixels
        float sourceTotalPixels = sourceResolution.width * sourceResolution.height;
        /*
         确定应用于输出图像的缩放比，导致定义的大小的输出图像。
         请参阅kDestImageSizeMB，以及它与destTotalPixels的关系。
         */
        float imageScale = kDestTotalPixels / sourceTotalPixels;
        // 计算目标像素 destResolution
        CGSize destResolution = CGSizeZero;
        destResolution.width = (int)(sourceResolution.width * imageScale);
        destResolution.height = (int)(sourceResolution.height * imageScale);
        // 获取当前的颜色空间 colorspaceRef
        CGColorSpaceRef colorspaceRef = [UIImage colorSpaceForImageRef:sourceImageRef];
        
        size_t bytesPerRow = kBytesPerPixel * destResolution.width;
        
        // 创建目标上下文 destContext
        // kCGImageAlphaNone is not supported in CGBitmapContextCreate.
        // Since the original image here has no alpha info, use kCGImageAlphaNoneSkipLast
        // to create bitmap graphics contexts without alpha info.
        destContext = CGBitmapContextCreate(NULL,
                                            destResolution.width,
                                            destResolution.height,
                                            kBitsPerComponent,
                                            bytesPerRow,
                                            colorspaceRef,
                                            kCGBitmapByteOrderDefault|kCGImageAlphaNoneSkipLast);
        
        if (destContext == NULL) {
            return image;
        }
        // 设置压缩质量
        CGContextSetInterpolationQuality(destContext, kCGInterpolationHigh);
        
        // 计算第一个原图方块 sourceTile，这个方块的宽度同原图一样，高度根据方块容量计算
        
        // 现在定义用于从输入图像到输出图像的增量变化的矩形的大小。
        // 由于iOS从磁盘上检索图像数据的方式，我们使用等于源图像宽度的源图块宽度。
        // 即使当前的图形上下文被剪切到该频带内的一个subly，iOS必须从全宽度的“band”中的磁盘中解码图像。 因此，通过将我们的图块大小与输入图像的全部宽度相关联，我们可以充分利用解码操作产生的所有像素数据。
        // Now define the size of the rectangle to be used for the
        // incremental blits from the input image to the output image.
        // we use a source tile width equal to the width of the source
        // image due to the way that iOS retrieves image data from disk.
        // iOS must decode an image from disk in full width 'bands', even
        // if current graphics context is clipped to a subrect within that
        // band. Therefore we fully utilize all of the pixel data that results
        // from a decoding opertion by achnoring our tile size to the full
        // width of the input image.
        CGRect sourceTile = CGRectZero;
        sourceTile.size.width = sourceResolution.width;
        // 源块高度是动态的。 由于我们以MB为单位指定了源图块的大小，因此可以看到可以给出输入图像宽度多少行像素高。
        // The source tile height is dynamic. Since we specified the size
        // of the source tile in MB, see how many rows of pixels high it
        // can be given the input image width.
        sourceTile.size.height = (int)(kTileTotalPixels / sourceTile.size.width );
        sourceTile.origin.x = 0.0f;
        
        // 计算目标图像方块 destTile
        
        // 输出图块与输入图块的比例相同，但缩放到图像尺度。
        // The output tile is the same proportions as the input tile, but
        // scaled to image scale.
        CGRect destTile;
        destTile.size.width = destResolution.width;
        destTile.size.height = sourceTile.size.height * imageScale;
        destTile.origin.x = 0.0f;
        
        // 计算原图像方块与方块重叠的像素大小 sourceSeemOverlap
        
        // The source seem overlap is proportionate to the destination seem overlap.
        // this is the amount of pixels to overlap each tile as we assemble the ouput image.
        float sourceSeemOverlap = (int)((kDestSeemOverlap/destResolution.height)*sourceResolution.height);
        
        // 计算原图像需要被分割成多少个方块 iterations
        
        CGImageRef sourceTileImageRef;
        // calculate the number of read/write operations required to assemble the
        // output image.
        int iterations = (int)( sourceResolution.height / sourceTile.size.height );
        // If tile height doesn't divide the image height evenly, add another iteration
        // to account for the remaining pixels.
        int remainder = (int)sourceResolution.height % (int)sourceTile.size.height;
        if(remainder) {
            iterations++;
        }
        
        // 根据重叠像素计算原图方块的大小后，获取原图中该方块内的数据，把该数据写入到相对应的目标方块中
        
        // Add seem overlaps to the tiles, but save the original tile height for y coordinate calculations.
        float sourceTileHeightMinusOverlap = sourceTile.size.height;
        sourceTile.size.height += sourceSeemOverlap;
        destTile.size.height += kDestSeemOverlap;
        for( int y = 0; y < iterations; ++y ) {
            @autoreleasepool {
                sourceTile.origin.y = y * sourceTileHeightMinusOverlap + sourceSeemOverlap;
                destTile.origin.y = destResolution.height - (( y + 1 ) * sourceTileHeightMinusOverlap * imageScale + kDestSeemOverlap);
                sourceTileImageRef = CGImageCreateWithImageInRect( sourceImageRef, sourceTile );
                if( y == iterations - 1 && remainder ) {
                    float dify = destTile.size.height;
                    destTile.size.height = CGImageGetHeight( sourceTileImageRef ) * imageScale;
                    dify -= destTile.size.height;
                    destTile.origin.y += dify;
                }
                CGContextDrawImage( destContext, destTile, sourceTileImageRef );
                CGImageRelease( sourceTileImageRef );
            }
        }
        
        // 返回目标图像
        
        CGImageRef destImageRef = CGBitmapContextCreateImage(destContext);
        CGContextRelease(destContext);
        if (destImageRef == NULL) {
            return image;
        }
        UIImage *destImage = [UIImage imageWithCGImage:destImageRef scale:image.scale orientation:image.imageOrientation];
        CGImageRelease(destImageRef);
        if (destImage == nil) {
            return image;
        }
        return destImage;
    }
}

#pragma mark - Private Methods

/**
 判断要不要解码图片
 
 不适合解码的条件为：
 
 image为nil
 animated images 动图不适合
 带有透明因素的图像不适合
 */
+ (BOOL)shouldDecodeImage:(nullable UIImage *)image {
    // Prevent "CGBitmapContextCreateImage: invalid context 0x0" error
    if (image == nil) {
        return NO;
    }
    
    // do not decode animated images
    if (image.images != nil) {
        return NO;
    }
    
    CGImageRef imageRef = image.CGImage;
    
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(imageRef);
    BOOL anyAlpha = (alpha == kCGImageAlphaFirst ||
                     alpha == kCGImageAlphaLast ||
                     alpha == kCGImageAlphaPremultipliedFirst ||
                     alpha == kCGImageAlphaPremultipliedLast
                     );
    // do not decode images with alpha
    if (anyAlpha) {
        return NO;
    }
    
    return YES;
}

/**
 判断图片是否需要缩小
 */
+ (BOOL)shouldScaleDownImage:(nullable UIImage *)image {
    BOOL shouldScaleDown = YES;
    // 获取图片的真实尺寸
    CGImageRef sourceImageRef = image.CGImage;
    CGSize sourceResolution = CGSizeZero;
    sourceResolution.width = CGImageGetWidth(sourceImageRef);
    sourceResolution.height = CGImageGetHeight(sourceImageRef);
    // 图片像素(宽 X 高)
    float sourceTotalPixels = sourceResolution.width * sourceResolution.height;
    float imageScale = kDestTotalPixels / sourceTotalPixels;
    
    shouldScaleDown = imageScale < 1;
    
    return shouldScaleDown;
}

#elif SD_MAC
+ (nullable UIImage *)decodedImageWithImage:(nullable UIImage *)image {
    return image;
}

+ (nullable UIImage *)decodedAndScaledDownImageWithImage:(nullable UIImage *)image {
    return image;
}
#endif

/**
 获取颜色空间
 */
+ (CGColorSpaceRef)colorSpaceForImageRef:(CGImageRef)imageRef {
    // current
    CGColorSpaceModel imageColorSpaceModel = CGColorSpaceGetModel(CGImageGetColorSpace(imageRef));
    CGColorSpaceRef colorspaceRef = CGImageGetColorSpace(imageRef);
    BOOL unsupportedColorSpace = (imageColorSpaceModel == kCGColorSpaceModelUnknown ||
                                  imageColorSpaceModel == kCGColorSpaceModelMonochrome ||
                                  imageColorSpaceModel == kCGColorSpaceModelCMYK ||
                                  imageColorSpaceModel == kCGColorSpaceModelIndexed);
    if (unsupportedColorSpace) {
        /**
         通用标准创建
         
         // 灰度 色彩
         CGColorSpaceRef graySpaceRef = CGColorSpaceCreateDeviceGray();
         
         // RGBA 色彩 （显示3色）
         CGColorSpaceRef rgbSapceRef = CGColorSpaceCreateDeviceRGB();
         
         // CMYK 色彩 （印刷4色）
         CGColorSpaceRef cmykSpaceRef = CGColorSpaceCreateDeviceCMYK();
         
         **/
        
        // 通用标准创建, RGBA 色彩 （显示3色）
        colorspaceRef = CGColorSpaceCreateDeviceRGB();
        CFAutorelease(colorspaceRef);
    }
    return colorspaceRef;
}

@end
