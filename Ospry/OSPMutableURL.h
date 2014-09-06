// Copyright 2014 Ospry. All Rights Reserved.

#import <Foundation/Foundation.h>

@interface OSPMutableURL : NSObject

@property (nonatomic) NSString *scheme;
@property (nonatomic) NSString *host;
@property (nonatomic) NSString *path;

-(id)initWithString:(NSString *)s;

-(void)setQueryWithKey:(NSString *)key value:(NSString *)value;
-(void)addQueryWithKey:(NSString *)key value:(NSString *)value;
-(void)removeQueryWithKey:(NSString *)key;

-(NSString *)string;

+(OSPMutableURL *)urlWithString:(NSString *)s;

@end

NSString* OSPQueryEncode(NSString *s);
NSString* OSPQueryDecode(NSString *s);