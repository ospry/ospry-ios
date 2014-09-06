// Copyright 2014 Ospry. All Rights Reserved.

#import <Foundation/Foundation.h>

typedef void (^OSPHTTPResponseBlock)(NSHTTPURLResponse *res, NSError *error);
typedef void (^OSPHTTPCompleteBlock)();

@interface OSPHTTPClient : NSObject <NSURLConnectionDataDelegate, NSStreamDelegate>

+(void)roundTripWithMethod:(NSString *)method
                       url:(NSString *)url
                       key:(NSString *)key
                      body:(NSInputStream *)body
               contentType:(NSString *)contentType
              outputStream:(NSOutputStream *)outputStream
                  response:(OSPHTTPResponseBlock)response
                  complete:(OSPHTTPCompleteBlock)complete;

+(void)postWithURL:(NSString *)url
               key:(NSString *)key
              body:(NSInputStream *)body
       contentType:(NSString *)contentType
      outputStream:(NSOutputStream *)outputStream
          response:(OSPHTTPResponseBlock)response
          complete:(OSPHTTPCompleteBlock)complete;

+(void)getWithURL:(NSString *)url
              key:(NSString *)key
     outputStream:(NSOutputStream *)outputStream
         response:(OSPHTTPResponseBlock)response
         complete:(OSPHTTPCompleteBlock)complete;

@end
