// Copyright 2014 Ospry. All Rights Reserved.

#import <Foundation/Foundation.h>

#import "OSPClient.h"
#import "OspryErrors.h"

@interface Ospry : NSObject

+(OSPClient *)defaultClient;

// Changes the key used by the default client.
+(void)setKey:(NSString *)key;

// These methods are forwarded to the default client. See OSPClient.h
// for documentation.

+(void)uploadAssetWithURL:(NSURL *)url
                isPrivate:(BOOL)isPrivate
                 complete:(OSPMetadataBlock)complete;

+(void)uploadFileAtPath:(NSString *)path
              isPrivate:(BOOL)isPrivate
               complete:(OSPMetadataBlock)complete;

+(void)uploadUIImage:(UIImage *)image
              format:(OSPUploadFormat)format
            filename:(NSString *)filename
           isPrivate:(BOOL)isPrivate
            complete:(OSPMetadataBlock)complete;

+(void)uploadCGImage:(CGImageRef)image
              format:(OSPUploadFormat)format
            filename:(NSString *)filename
           isPrivate:(BOOL)isPrivate
            complete:(OSPMetadataBlock)complete;

+(void)uploadData:(NSData *)data
         filename:(NSString *)filename
        isPrivate:(BOOL)isPrivate
         complete:(OSPMetadataBlock)complete;

+(void)downloadToFileAtPath:(NSString *)path
                        url:(NSString *)url
                       opts:(NSDictionary *)opts
                   complete:(OSPCompleteBlock)complete;

+(void)downloadUIImageWithURL:(NSString *)url
                         opts:(NSDictionary *)opts
                     complete:(OSPUIImageBlock)complete;

+(void)downloadCGImageWithURL:(NSString *)url
                         opts:(NSDictionary *)opts
                     complete:(OSPCGImageBlock)complete;

+(void)downloadDataWithURL:(NSString *)url
                      opts:(NSDictionary *)opts
                  complete:(OSPNSDataBlock)complete;

+(NSString *)formatURL:(NSString *)url opts:(NSDictionary *)opts;

@end
