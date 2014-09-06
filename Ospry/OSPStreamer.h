// Copyright 2014 Ospry. All Rights Reserved.

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "OSPClient.h"

@interface OSPStreamer : NSObject

+(NSInputStream *)inputStreamWithAsset:(ALAsset *)asset library:(ALAssetsLibrary *)library;
+(NSInputStream *)inputStreamWithFileAtPath:(NSString *)path;
+(NSInputStream *)inputStreamWithUIImage:(UIImage *)image format:(OSPUploadFormat)format;
+(NSInputStream *)inputStreamWithCGImage:(CGImageRef)image format:(OSPUploadFormat)format;
+(NSInputStream *)inputStreamWithData:(NSData *)data;

@end
