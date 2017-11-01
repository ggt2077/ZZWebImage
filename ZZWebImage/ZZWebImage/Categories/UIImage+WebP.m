//
//  UIImage+WebP.m
//  ZZWebImage
//
//  Created by Tony on 2017/10/17.
//  Copyright © 2017年 58. All rights reserved.
//

#import "UIImage+WebP.h"
#import "decode.h"
#import "mux_types.h"
#import "demux.h"

#import "objc/runtime.h"

// Callback for CGDataProviderRelease
static void FreeImageData(void *info, const void *data, size_t size) {
    free((void *)data);
}

@implementation UIImage (WebP)

- (NSInteger)zz_webpLoopCount {
    NSNumber *value = objc_getAssociatedObject(self, @selector(zz_webpLoopCount));
    return value.integerValue;
}

+ (nullable UIImage *)zz_imageWithWebPData:(nullable NSData *)data {
    if (!data) {
        return nil;
    }
    
    WebPData webpData;
    WebPDataInit(&webpData);
    webpData.bytes = data.bytes;
    webpData.size = data.length;
    WebPDemuxer *demuxer = WebPDemux(&webpData);
    if (!demuxer) {
        return nil;
    }
    
    uint32_t flags = WebPDemuxGetI(demuxer, WEBP_FF_FORMAT_FLAGS);
    if (!(flags & ANIMATION_FLAG)) {
        // for static single webp image
        UIImage *staticImage = [self zz_rawWebpImageWithData:webpData];
        WebPDemuxDelete(demuxer);
        return staticImage;
    }
    
    WebPIterator iter;
    if (!WebPDemuxGetFrame(demuxer, 1, &iter)) {
        WebPDemuxReleaseIterator(&iter);
        WebPDemuxDelete(demuxer);
        return nil;
    }
    
    int loopCount = WebPDemuxGetI(demuxer, WEBP_FF_LOOP_COUNT);
    int frameCount = WebPDemuxGetI(demuxer, WEBP_FF_FRAME_COUNT);
    
    int canvasWidth = WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_WIDTH);
    int canvasHeight = WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_HEIGHT);
    CGBitmapInfo bitmapInfo;
    if (!(flags & ALPHA_FLAG)) {
        bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipLast;
    } else {
        bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
    }
    CGContextRef canvas = CGBitmapContextCreate(NULL, canvasWidth, canvasHeight, 8, 0, SDCGColorSpaceGetDeviceRGB(), bitmapInfo);
    if (!canvas) {
        WebPDemuxReleaseIterator(&iter);
        WebPDemuxDelete(demuxer);
        return nil;
    }
    
    NSMutableArray<UIImage *> *images = [NSMutableArray array];
    NSTimeInterval totalDuration = 0;
    int durations[frameCount];
    
    do {
        UIImage *image;
        if (iter.blend_method == WEBP_MUX_BLEND) {
            image = [self zz_blendWebpImageWithCanvas:canvas iterator:iter];
        } else {
            image = [self zz_nonblendWebpImageWithCanvas:canvas iterator:iter];
        }
        
        if (!image) {
            continue;
        }
        
        [images addObject:image];
        
        int duration = iter.duration;
        if (duration <= 10) {
            // WebP standard says 0 duration is used for canvas updating but not showing image, but actually Chrome and other implementations set it to 100ms if duration is lower or equal than 10ms
            // Some animated WebP images also created without duration, we should keep compatibility
            duration = 100;
        }
        totalDuration += duration;
        size_t count = images.count;
        durations[count - 1] = duration;
    } while (WebPDemuxNextFrame(&iter));
    
    WebPDemuxReleaseIterator(&iter);
    WebPDemuxDelete(demuxer);
    CGContextRelease(canvas);
    
    UIImage *finalImage = nil;
    
    NSArray<UIImage *> *animatedImages = [self zz_animatedImagesWithImages:images durations:durations totalDuration:totalDuration];
    finalImage = [UIImage animatedImageWithImages:animatedImages duration:totalDuration / 1000.0];
    if (finalImage) {
        objc_setAssociatedObject(finalImage, @selector(zz_webpLoopCount), @(loopCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return finalImage;
}

+ (nullable UIImage *)zz_blendWebpImageWithCanvas:(CGContextRef)canvas iterator:(WebPIterator)iter {
    UIImage *image = [self zz_rawWebpImageWithData:iter.fragment];
    if (!image) {
        return nil;
    }
    
    size_t canvasWidth = CGBitmapContextGetWidth(canvas);
    size_t canvasHeight = CGBitmapContextGetHeight(canvas);
    CGSize size = CGSizeMake(canvasWidth, canvasHeight);
    CGFloat tmpX = iter.x_offset;
    CGFloat tmpY = size.height - iter.height - iter.y_offset;
    CGRect imageRect = CGRectMake(tmpX, tmpY, iter.width, iter.height);
    
    CGContextDrawImage(canvas, imageRect, image.CGImage);
    CGImageRef newImageRef = CGBitmapContextCreateImage(canvas);

    image = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    
    if (iter.dispose_method == WEBP_MUX_DISPOSE_BACKGROUND) {
        CGContextClearRect(canvas, imageRect);
    }
    
    return image;
}

+ (nullable UIImage *)zz_nonblendWebpImageWithCanvas:(CGContextRef)canvas iterator:(WebPIterator)iter {
    UIImage *image = [self zz_rawWebpImageWithData:iter.fragment];
    if (!image) {
        return nil;
    }
    
    size_t canvasWidth = CGBitmapContextGetWidth(canvas);
    size_t canvasHeight = CGBitmapContextGetHeight(canvas);
    CGSize size = CGSizeMake(canvasWidth, canvasHeight);
    CGFloat tmpX = iter.x_offset;
    CGFloat tmpY = size.height - iter.height - iter.y_offset;
    CGRect imageRect = CGRectMake(tmpX, tmpY, iter.width, iter.height);
    
    CGContextClearRect(canvas, imageRect);
    CGContextDrawImage(canvas, imageRect, image.CGImage);
    CGImageRef newImageRef = CGBitmapContextCreateImage(canvas);
    
    image = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    
    if (iter.dispose_method == WEBP_MUX_DISPOSE_BACKGROUND) {
        CGContextClearRect(canvas, imageRect);
    }
    
    return image;
}

+ (nullable UIImage *)zz_rawWebpImageWithData:(WebPData)webpData {
    WebPDecoderConfig config;
    // 初始化解码器结构体(WebPDecoderConfig类型)变量config
    if (!WebPInitDecoderConfig(&config)) {
        return nil;
    }
    // 将WebP图片的二进制数据传递给config
    if (WebPGetFeatures(webpData.bytes, webpData.size, &config.input) != VP8_STATUS_OK) {
        return nil;
    }
    
    config.output.colorspace = config.input.has_alpha ? MODE_rgbA : MODE_RGB;
    config.options.use_threads = 1;
    
    // Decode the WebP image data into a RGBA value array
    // 将WebP图片数据解码为RGBA值数组，保存在config中
    if (WebPDecode(webpData.bytes, webpData.size, &config) != VP8_STATUS_OK) {
        return nil;
    }
    // 从config中读取出图片的宽高信息
    int width = config.input.width;
    int height = config.input.height;
    if (config.options.use_scaling) {
        width = config.options.scaled_width;
        height = config.options.scaled_height;
    }
    
    // Construct a UIImage from the decoded RGBA value array
    // 根据解码后的RGBA值数组创建UIImage.
    
    // 1.创建数据提供者，参数指定了RGBA值数组的开始地址`config.output.u.RGBA.rgba`和长度`config.output.u.RGBA.size`，用于释放数据的回调`FreeImageData`
    CGDataProviderRef provider =
    CGDataProviderCreateWithData(NULL, config.output.u.RGBA.rgba, config.output.u.RGBA.size, FreeImageData);
    CGColorSpaceRef colorSpaceRef = SDCGColorSpaceGetDeviceRGB();
    CGBitmapInfo bitmapInfo = config.input.has_alpha ? kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast : kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipLast;
    size_t components = config.input.has_alpha ? 4 : 3;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    // 2.使用数据提供者和其他信息创建CGImageRef
    CGImageRef imageRef = CGImageCreate(width, height, 8, components * 8, components * width, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    CGDataProviderRelease(provider);

    // 3.将CGImageRef转为UIImage
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];

    CGImageRelease(imageRef);
    
    return image;
}

+ (NSArray<UIImage *> *)zz_animatedImagesWithImages:(NSArray<UIImage *> *)images durations:(int const * const)durations totalDuration:(NSTimeInterval)totalDuration
{
    // [UIImage animatedImageWithImages:duration:] only use the average duration for per frame
    // divide the total duration to implement per frame duration for animated WebP
    NSUInteger count = images.count;
    if (!count) {
        return nil;
    }
    if (count == 1) {
        return images;
    }
    
    int const gcd = gcdArray(count, durations);
    NSMutableArray<UIImage *> *animatedImages = [NSMutableArray arrayWithCapacity:count];
    [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
        int duration = durations[idx];
        int repeatCount;
        if (gcd) {
            repeatCount = duration / gcd;
        } else {
            repeatCount = 1;
        }
        for (int i = 0; i < repeatCount; ++i) {
            [animatedImages addObject:image];
        }
    }];
    
    return animatedImages;
}

static CGColorSpaceRef SDCGColorSpaceGetDeviceRGB() {
    static CGColorSpaceRef space;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        space = CGColorSpaceCreateDeviceRGB();
    });
    return space;
}

static int gcdArray(size_t const count, int const * const values) {
    int result = values[0];
    for (size_t i = 1; i < count; ++i) {
        result = gcd(values[i], result);
    }
    return result;
}

static int gcd(int a,int b) {
    int c;
    while (a != 0) {
        c = a;
        a = b % a;
        b = c;
    }
    return b;
}

@end
