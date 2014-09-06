// Copyright 2014 Ospry. All Rights Reserved.

#import "OSPClient.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "OSPHTTPClient.h"
#import "OSPMutableURL.h"
#import "OSPStreamer.h"
#import "OspryErrors.h"

@implementation OSPClient

-(id)init
{
    if (self = [super init])
    {
        _serverURL = @"https://api.ospry.io/v1";
    }
    return self;
}

-(void)uploadAssetWithURL:(NSURL *)assetURL
                isPrivate:(BOOL)isPrivate
                 complete:(OSPMetadataBlock)complete
{
    NSLog(@"assetURL = %@", assetURL);
    ALAssetsLibrary *lib = [ALAssetsLibrary new];
    [lib assetForURL:assetURL resultBlock:^(ALAsset *asset) {

        [self uploadInputStream:[OSPStreamer inputStreamWithAsset:asset library:lib]
                       filename:[[asset defaultRepresentation] filename]
                      isPrivate:isPrivate
                       complete:complete];
        
    } failureBlock:^(NSError *error) {
        
        if (complete != NULL) {
            complete(nil, error);
        }
        
    }];
}

-(void)uploadFileAtPath:(NSString *)path
              isPrivate:(BOOL)isPrivate
               complete:(OSPMetadataBlock)complete
{
    [self uploadInputStream:[OSPStreamer inputStreamWithFileAtPath:path]
                   filename:path
                  isPrivate:isPrivate
                   complete:complete];
}

-(void)uploadUIImage:(UIImage *)image
              format:(OSPUploadFormat)format
            filename:(NSString *)filename
           isPrivate:(BOOL)isPrivate
            complete:(OSPMetadataBlock)complete
{
    [self uploadInputStream:[OSPStreamer inputStreamWithUIImage:image format:format]
                   filename:filename
                  isPrivate:isPrivate
                   complete:complete];
}

-(void)uploadCGImage:(CGImageRef)image
              format:(OSPUploadFormat)format
            filename:(NSString *)filename
           isPrivate:(BOOL)isPrivate
            complete:(OSPMetadataBlock)complete
{
    [self uploadInputStream:[OSPStreamer inputStreamWithCGImage:image format:format]
                   filename:filename
                  isPrivate:isPrivate
                   complete:complete];
}

-(void)uploadData:(NSData *)data
         filename:(NSString *)filename
        isPrivate:(BOOL)isPrivate
         complete:(OSPMetadataBlock)complete
{
    [self uploadInputStream:[OSPStreamer inputStreamWithData:data]
                   filename:filename
                  isPrivate:isPrivate
                   complete:complete];
}

-(void)uploadInputStream:(NSInputStream *)input
                filename:(NSString *)filename
               isPrivate:(BOOL)isPrivate
                complete:(OSPMetadataBlock)complete
{
    NSLog(@"filename: %@ => %@", filename, OSPQueryEncode(filename));
    NSString *url = [NSString stringWithFormat:@"%@/images?filename=%@&isPrivate=%@",
                     self.serverURL, OSPQueryEncode(filename), (isPrivate ? @"true" : @"false")];
    NSOutputStream *output = [NSOutputStream outputStreamToMemory];
    __block long statusCode = 0;
    __block OSPMetadataBlock completeBlock = complete;
    [OSPHTTPClient postWithURL:url key:self.key body:input contentType:@"image/jpeg" outputStream:output response:^(NSHTTPURLResponse *res, NSError *error) {
        
        if (completeBlock == NULL) {
            return;
        }
        if (error != nil) {
            completeBlock(nil, error);
            completeBlock = NULL;
            return;
        }
        statusCode = res.statusCode;
        
    } complete:^() {
        
        if (completeBlock == NULL) {
            return;
        }
        NSData *data = [output propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error != nil) {
            completeBlock(nil, error);
            return;
        }
        if (statusCode != 200) {
            completeBlock(nil, OSPErrorWithJSON(json[@"error"]));
            return;
        }
        completeBlock([OSPMetadata metadataWithJSON:json[@"metadata"]], nil);
        
    }];
}

-(void)downloadToFileAtPath:(NSString *)path
                        url:(NSString *)url
                       opts:(NSDictionary *)opts
                   complete:(OSPCompleteBlock)complete
{
    if (complete == NULL) {
        [NSException raise:@"missing-complete"
                    format:@"Ospry: complete block is NULL"];
    }
    NSOutputStream *output = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    __block OSPCompleteBlock completeBlock = complete;
    [OSPHTTPClient getWithURL:[self formatURL:url opts:opts] key:self.key outputStream:output response:^(NSHTTPURLResponse *res, NSError *error) {

        if (error != nil) {
            completeBlock(error);
            completeBlock = NULL;
            return;
        }
        if (res.statusCode != 200) {
            completeBlock(OSPErrorWithStatusCode((int)res.statusCode));
        }
        
    } complete:^() {
        
        if (completeBlock == NULL) {
            return;
        }
        completeBlock(nil);
        
    }];
}

-(void)downloadUIImageWithURL:(NSString *)url
                         opts:(NSDictionary *)opts
                     complete:(OSPUIImageBlock)complete
{
    if (complete == NULL) {
        [NSException raise:@"missing-complete"
                    format:@"Ospry: complete block is NULL"];
    }
    [self downloadDataWithURL:url opts:opts complete:^(NSData *data, NSString *contentType, NSError *error) {
        if (error != nil) {
            complete(nil, error);
            return;
        }
        complete([UIImage imageWithData:data], nil);
    }];
}

-(void)downloadCGImageWithURL:(NSString *)url
                         opts:(NSDictionary *)opts
                     complete:(OSPCGImageBlock)complete
{
    if (complete == NULL) {
        [NSException raise:@"missing-complete"
                    format:@"Ospry: complete block is NULL"];
    }
    [self downloadUIImageWithURL:url opts:opts complete:^(UIImage *image, NSError *error) {
        if (error != nil) {
            complete(nil, error);
            return;
        }
        complete(image.CGImage, nil);
    }];
}

-(void)downloadDataWithURL:(NSString *)url
                      opts:(NSDictionary *)opts
                  complete:(OSPNSDataBlock)complete
{
    if (complete == NULL) {
        [NSException raise:@"missing-complete"
                    format:@"Ospry: complete block is NULL"];
    }
    NSOutputStream *output = [NSOutputStream outputStreamToMemory];
    __block OSPNSDataBlock completeBlock = complete;
    __block NSString *cType = @"";
    [OSPHTTPClient getWithURL:[self formatURL:url opts:opts] key:self.key outputStream:output response:^(NSHTTPURLResponse *res, NSError *error) {

        if (error != nil) {
            completeBlock(nil, @"", error);
            completeBlock = NULL;
            return;
        }
        cType = contentType(res);
        
    } complete:^() {
        
        if (completeBlock == NULL) {
            return;
        }
        NSData *data = [output propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
        completeBlock(data, cType, nil);
        
    }];
}

-(NSString *)formatURL:(NSString *)url opts:(NSDictionary *)opts
{
    if (opts == nil) {
        return url;
    }
    NSString *format = opts[@"format"];
    NSNumber *maxHeight = opts[@"maxHeight"];
    NSNumber *maxWidth = opts[@"maxWidth"];
    if (format == nil && maxHeight == nil && maxWidth == nil) {
        return url;
    }
    OSPMutableURL *u = [OSPMutableURL urlWithString:url];
    if (format != nil) {
        if (![format isEqualToString:@""]) {
            if ([format isEqualToString:@"jpg"]) {
                format = @"jpeg";
            }
            if (![[self formats] containsObject:format]) {
                [NSException raise:@"invalid-format" format:@"%@ is not a valid format", format];
            }
            [u setQueryWithKey:@"format" value:format];
        } else {
            [u removeQueryWithKey:@"format"];
        }
    }
    if (maxHeight != nil) {
        int mh = (int)[maxHeight integerValue];
        if (mh > 0) {
            [u setQueryWithKey:@"maxHeight" value:[NSString stringWithFormat:@"%d", mh]];
        } else {
            [u removeQueryWithKey:@"maxHeight"];
        }
    }
    if (maxWidth != nil) {
        int mw = (int)[maxWidth integerValue];
        if (mw > 0) {
            [u setQueryWithKey:@"maxWidth" value:[NSString stringWithFormat:@"%d", mw]];
        } else {
            [u removeQueryWithKey:@"maxWidth"];
        }
    }
    return [u string];
}

static NSArray *fmts;

-(NSArray *)formats
{
    if (fmts == nil) {
        fmts = @[@"jpeg", @"png", @"gif"];
    }
    return fmts;
}

static NSString* contentType(NSHTTPURLResponse *res) {
    NSDictionary *h = [res allHeaderFields];
    for (NSString *key in h) {
        if ([[key lowercaseString] isEqualToString:@"content-type"]) {
            return h[key];
        }
    }
    return @"";
}

@end
