// Copyright 2014 Ospry. All Rights Reserved.

#import "OSPStreamer.h"

#define CHUNK_SIZE 4096

@interface OSPAssetStreamer : NSObject <NSStreamDelegate>

@property (nonatomic) ALAssetsLibrary *library;
@property (nonatomic) ALAssetRepresentation *rep;
@property (nonatomic) NSOutputStream *output;
@property (nonatomic) NSMutableData *buffer;
@property (nonatomic, assign) int64_t cursor;

-(id)initWithAsset:(ALAsset *)asset library:(ALAssetsLibrary *)library;
-(NSInputStream*)start;

@end

@implementation OSPAssetStreamer

-(id)initWithAsset:(ALAsset *)asset library:(ALAssetsLibrary *)library
{
    if (self = [super init])
    {
        _library = library;
        _rep = [asset defaultRepresentation];
    }
    return self;
}

-(NSInputStream*)start
{
    CFReadStreamRef read;
    CFWriteStreamRef write;
    CFStreamCreateBoundPair(NULL, &read, &write, CHUNK_SIZE);
    NSInputStream *input = CFBridgingRelease(read);
    self.output = CFBridgingRelease(write);
    self.buffer = [NSMutableData data];
    self.cursor = 0;
    [self.output setDelegate:self];
    [self.output scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.output open];
    CFRetain((__bridge CFTypeRef)(self));
    return input;
}

-(void)closeOutput
{
    [self.output close];
    [self.output removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.output = nil;
}

-(void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)event
{
    switch (event) {
        case NSStreamEventNone:
            break;
        case NSStreamEventOpenCompleted:
            break;
        case NSStreamEventHasBytesAvailable:
            break;
        case NSStreamEventHasSpaceAvailable:
        {
            int left = (int)[self.buffer length];
            if (left > 0) {
                // Copy from buffer.
                const uint8_t *buf = [self.buffer bytes];
                int n = (int)[self.output write:buf maxLength:left];
                self.buffer = [NSMutableData dataWithBytes:(buf + n) length:(left - n)];
                return;
            }
            if (self.cursor == [self.rep size]) {
                [self closeOutput];
                CFRelease((__bridge CFTypeRef)(self));
                return;
            }
            // Read from the asset.
            uint8_t buf[CHUNK_SIZE];
            NSError *error = nil;
            int n = (int)[self.rep getBytes:buf fromOffset:self.cursor length:CHUNK_SIZE error:&error];
            if (error != nil) {
                NSLog(@"error reading asset: %@", error);
                [self closeOutput];
                CFRelease((__bridge CFTypeRef)(self));
            }
            self.cursor += n;
            int w = (int)[self.output write:buf maxLength:n];
            // Save anything left over.
            self.buffer = [NSMutableData dataWithBytes:(buf + w) length:(n - w)];
            break;
        }
        case NSStreamEventErrorOccurred:
        {
            NSLog(@"asset output stream error: %@", [stream streamError]);
            [self closeOutput];
            CFRelease((__bridge CFTypeRef)(self));
            break;
        }
        case NSStreamEventEndEncountered:
            break;
        default:
            break;
    }
}


@end

@implementation OSPStreamer

+(NSInputStream*)inputStreamWithAsset:(ALAsset *)asset library:(ALAssetsLibrary*)library
{
    OSPAssetStreamer *as = [[OSPAssetStreamer alloc] initWithAsset:asset library:library];
    return [as start];
}

+(NSInputStream*)inputStreamWithFileAtPath:(NSString *)path
{
    return [NSInputStream inputStreamWithFileAtPath:path];
}

+(NSInputStream*)inputStreamWithUIImage:(UIImage *)image format:(OSPUploadFormat)format
{
    NSData *data;
    switch (format) {
        case kOSPUploadFormatJPEG:
            data = UIImageJPEGRepresentation(image, 0.9);
            break;
        case kOSPUploadFormatPNG:
            data = UIImagePNGRepresentation(image);
            break;
        default:
            [NSException raise:@"unrecognized-format" format:@"Ospry: unrecognized upload format %d", (int)format];
            break;
    }
    
    return [OSPStreamer inputStreamWithData:data];
}

+(NSInputStream*)inputStreamWithCGImage:(CGImageRef)image format:(OSPUploadFormat)format
{
    return [OSPStreamer inputStreamWithUIImage:[UIImage imageWithCGImage:image] format:format];
}

+(NSInputStream*)inputStreamWithData:(NSData *)data
{
    return [NSInputStream inputStreamWithData:data];
}

@end
