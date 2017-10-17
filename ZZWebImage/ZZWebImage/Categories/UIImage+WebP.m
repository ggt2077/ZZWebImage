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

@implementation UIImage (WebP)

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
    
}

@end
