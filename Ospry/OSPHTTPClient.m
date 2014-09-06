// Copyright 2014 Ospry. All Rights Reserved.

#import "OSPHTTPClient.h"

#define STREAM_BUFFER_SIZE 4096

@interface OSPHTTPClient ()

@property (nonatomic) NSString *key;
@property (nonatomic, copy) OSPHTTPResponseBlock responseBlock;
@property (nonatomic, copy) OSPHTTPCompleteBlock completeBlock;
@property (nonatomic) NSOutputStream *output;
@property (nonatomic) NSMutableData *buffer;
@property (nonatomic, assign) BOOL streamIsWaiting;
@property (nonatomic) NSURLConnection *conn;

@end

@implementation OSPHTTPClient

-(id)initWithKey:(NSString *)key
{
    if (self = [super init])
    {
        _key = key;
    }
    return self;
}

-(void)roundTripWithMethod:(NSString *)method
                       url:(NSString *)url
                      body:(NSInputStream *)body
               contentType:(NSString *)contentType
              outputStream:(NSOutputStream *)outputStream
                  response:(OSPHTTPResponseBlock)response
                  complete:(OSPHTTPCompleteBlock)complete
{
    if (response == NULL) {
        [NSException raise:@"missing-response" format:@"Ospry: response block is NULL"];
    }
    self.responseBlock = response;
    self.completeBlock = complete;
    self.output = outputStream;
    NSLog(@"%@ %@ %@", method, url, contentType);
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [req setHTTPMethod:method];
    [req setHTTPBodyStream:body];
    if (contentType != nil && ![contentType isEqualToString:@""]) {
        [req setValue:contentType forHTTPHeaderField:@"Content-Type"];
    }
    NSString *token = [NSString stringWithFormat:@"%@:", self.key];;
    NSString *token64 = base64Encode([token dataUsingEncoding:NSUTF8StringEncoding]);
    [req setValue:[NSString stringWithFormat:@"Basic %@", token64] forHTTPHeaderField:@"Authorization"];
    self.conn = [NSURLConnection connectionWithRequest:req delegate:self];
    // Keep this object alive during the length round trip.
    CFRetain((__bridge CFTypeRef)(self));
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"connection:didReceiveResponse:");
    self.buffer = [NSMutableData data];
    self.streamIsWaiting = NO;
    [self.output setDelegate:self];
    [self.output scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.output open];
    self.responseBlock((NSHTTPURLResponse*)response, nil);
    self.responseBlock = NULL;
}

-(void)closeOutput
{
    [self.output close];
    [self.output removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.output = nil;
    if (self.completeBlock != NULL) {
        self.completeBlock();
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"connection:didReceiveData: %d bytes", (int)[data length]);
    // Add it to the buffer so we can write it to the stream when
    // there is space available.
    [self.buffer appendData:data];
    // If the stream is waiting for data, we need to write it in
    // order for the stream to continue sending events.
    if (self.streamIsWaiting) {
        NSLog(@"write while stream is waiting");
        const uint8_t *buf = [self.buffer bytes];
        int len = (int)[self.buffer length];
        int n = (int)[self.output write:buf maxLength:len];
        if (n <= 0) {
            NSLog(@"zero-size write!");
        } else {
            NSLog(@"wrote %d bytes to output stream", n);
        }
        self.buffer = [NSMutableData dataWithBytes:(buf + n) length:(len - n)];
        self.streamIsWaiting = NO;
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connectionDidFinishLoading:");
    // We've received all of the response data, but some of it may
    // still be sitting in the buffer.
    self.conn = nil;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"connection:didFailWithError: %@", error);
    // Call the callback if we haven't called it already.
    if (self.responseBlock != NULL) {
        self.responseBlock(nil, error);
        self.responseBlock = NULL;
        return;
    }
    // Close the stream if it is open.
    if (self.output != nil) {
        [self closeOutput];
    }
    // Allow this object to die.
    CFRelease((__bridge CFTypeRef)(self));
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
            // Copy over as much as we can from the buffer.
            int len = (int)[self.buffer length];
            if (len == 0) {
                if (self.conn == nil) {
                    [self closeOutput];
                    CFRelease((__bridge CFTypeRef)(self));
                }
                self.streamIsWaiting = YES;
                break;
            }
            const uint8_t *buf = [self.buffer bytes];
            int n = (int)[self.output write:buf maxLength:len];
            if (n <= 0) {
                NSLog(@"zero-size write!");
            } else {
                NSLog(@"wrote %d bytes to output stream", n);
            }
            self.buffer = [NSMutableData dataWithBytes:(buf + n) length:(len - n)];
            // Close the stream if there is no more data.
            if (self.conn == nil && [self.buffer length] == 0) {
                [self closeOutput];
                CFRelease((__bridge CFTypeRef)(self));
            }
            break;
        }
        case NSStreamEventErrorOccurred:
        {
            NSLog(@"output stream error: %@", [stream streamError]);
            [self.conn cancel];
            self.conn = nil;
            [self closeOutput];
            CFRelease((__bridge CFTypeRef)(self));
            break;
        }
        case NSStreamEventEndEncountered:
            NSLog(@"output stream end");
            break;
        default:
            break;
    }
}

static const char *charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static NSString* base64Encode(NSData *data)
{
    const uint8_t *p = [data bytes];
    int n = (int)[data length];
    // Every 3 bytes becomes 4 bytes in base64 (and the end is padded to a multiple of 4).
    NSMutableData *b64 = [NSMutableData dataWithCapacity:(4 * (n+2)/3)];
    for (int i = 0; i+2 < n; i += 3) {
        [b64 appendBytes:&charset[p[i]>>2] length:1];
        [b64 appendBytes:&charset[((p[i]<<4) | (p[i+1]>>4)) & 0x3F] length:1];
        [b64 appendBytes:&charset[((p[i+1]<<2) | (p[i+2]>>6)) & 0x3F] length:1];
        [b64 appendBytes:&charset[p[i+2] & 0x3F] length:1];
    }
    int left = n % 3;
    uint8_t pad = '=';
    if (left == 1) {
        // Make two base64 bytes (using 0x00 as the missing input byte).
        [b64 appendBytes:&charset[p[n-left]>>2] length:1];
        [b64 appendBytes:&charset[(p[n-left]<<4) & 0x3F] length:1];
        // Pad to multiple of 4.
        [b64 appendBytes:&pad length:1];
        [b64 appendBytes:&pad length:1];
    } else if (left == 2) {
        // Make three base64 bytes (using 0x00 as the missing input byte).
        [b64 appendBytes:&charset[p[n-left]>>2] length:1];
        [b64 appendBytes:&charset[((p[n-left]<<4) | (p[n-left+1]>>4)) & 0x3F] length:1];
        [b64 appendBytes:&charset[(p[n-left+1]<<2) & 0x3F] length:1];
        // Pad to multiple of 4.
        [b64 appendBytes:&pad length:1];
    }
    return [[NSString alloc] initWithData:b64 encoding:NSASCIIStringEncoding];
}

+(void)roundTripWithMethod:(NSString *)method
                       url:(NSString *)url
                       key:(NSString *)key
                      body:(NSInputStream *)body
               contentType:(NSString *)contentType
              outputStream:(NSOutputStream *)outputStream
                  response:(OSPHTTPResponseBlock)response
                  complete:(OSPHTTPCompleteBlock)complete
{
    OSPHTTPClient *c = [[OSPHTTPClient alloc] initWithKey:key];
    [c roundTripWithMethod:method
                       url:url
                      body:body
               contentType:contentType
              outputStream:outputStream
                  response:response
                  complete:complete];
}

+(void)postWithURL:(NSString *)url
               key:(NSString *)key
              body:(NSInputStream *)body
       contentType:(NSString *)contentType
      outputStream:(NSOutputStream *)outputStream
          response:(OSPHTTPResponseBlock)response
          complete:(OSPHTTPCompleteBlock)complete
{
    [OSPHTTPClient roundTripWithMethod:@"POST"
                                   url:url
                                   key:key
                                  body:body
                           contentType:contentType
                          outputStream:outputStream
                              response:response
                              complete:complete];
}

+(void)getWithURL:(NSString *)url
              key:(NSString *)key
     outputStream:(NSOutputStream *)outputStream
         response:(OSPHTTPResponseBlock)response
         complete:(OSPHTTPCompleteBlock)complete
{
    [OSPHTTPClient roundTripWithMethod:@"GET"
                                   url:url
                                   key:key
                                  body:nil
                           contentType:nil
                          outputStream:outputStream
                              response:response
                              complete:complete];
}

@end
