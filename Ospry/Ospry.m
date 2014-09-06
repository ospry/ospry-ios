// Copyright 2014 Ospry. All Rights Reserved.

#import "Ospry.h"

@implementation Ospry

static OSPClient *client = nil;

+(OSPClient *)defaultClient
{
    if (client == nil) {
        client = [OSPClient new];
    }
    return client;
}

+(void)setKey:(NSString *)key
{
    [Ospry defaultClient].key = key;
}

+(void)uploadAssetWithURL:(NSURL *)url
                isPrivate:(BOOL)isPrivate
                 complete:(OSPMetadataBlock)complete
{
    [[Ospry defaultClient] uploadAssetWithURL:url
                                    isPrivate:isPrivate
                                     complete:complete];
}

+(void)uploadFileAtPath:(NSString *)path
              isPrivate:(BOOL)isPrivate
               complete:(OSPMetadataBlock)complete
{
    [[Ospry defaultClient] uploadFileAtPath:path
                                  isPrivate:isPrivate
                                   complete:complete];
}

+(void)uploadUIImage:(UIImage *)image
              format:(OSPUploadFormat)format
            filename:(NSString *)filename
           isPrivate:(BOOL)isPrivate
            complete:(OSPMetadataBlock)complete
{
    [[Ospry defaultClient] uploadUIImage:image
                                  format:format
                                filename:filename
                               isPrivate:isPrivate
                                complete:complete];
}

+(void)uploadCGImage:(CGImageRef)image
              format:(OSPUploadFormat)format
            filename:(NSString *)filename
           isPrivate:(BOOL)isPrivate
            complete:(OSPMetadataBlock)complete
{
    [[Ospry defaultClient] uploadCGImage:image
                                  format:format
                                filename:filename
                               isPrivate:isPrivate
                                complete:complete];
}

+(void)uploadData:(NSData *)data
         filename:(NSString *)filename
        isPrivate:(BOOL)isPrivate
         complete:(OSPMetadataBlock)complete
{
    [[Ospry defaultClient] uploadData:data
                             filename:filename
                            isPrivate:isPrivate
                             complete:complete];
}

+(void)downloadToFileAtPath:(NSString *)path
                        url:(NSString *)url
                       opts:(NSDictionary *)opts
                   complete:(OSPCompleteBlock)complete
{
    [[Ospry defaultClient] downloadToFileAtPath:path
                                            url:url
                                           opts:opts
                                       complete:complete];
}

+(void)downloadUIImageWithURL:(NSString *)url
                         opts:(NSDictionary *)opts
                     complete:(OSPUIImageBlock)complete
{
    [[Ospry defaultClient] downloadUIImageWithURL:url
                                             opts:opts
                                         complete:complete];
}

+(void)downloadCGImageWithURL:(NSString *)url
                         opts:(NSDictionary *)opts
                     complete:(OSPCGImageBlock)complete
{
    [[Ospry defaultClient] downloadCGImageWithURL:url
                                             opts:opts
                                         complete:complete];
}

+(void)downloadDataWithURL:(NSString *)url
                      opts:(NSDictionary *)opts
                  complete:(OSPNSDataBlock)complete
{
    [[Ospry defaultClient] downloadDataWithURL:url
                                          opts:opts
                                      complete:complete];
}

+(NSString *)formatURL:(NSString *)url opts:(NSDictionary *)opts
{
    return [[Ospry defaultClient] formatURL:url opts:opts];
}

@end
