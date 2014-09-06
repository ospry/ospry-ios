// Copyright 2014 Ospry. All Rights Reserved.

#import <Foundation/Foundation.h>

@interface OSPMetadata : NSObject

@property (nonatomic) NSString *identifier;
@property (nonatomic) NSString *url;
@property (nonatomic) NSString *httpsURL;
@property (nonatomic) NSDate   *timeCreated;
@property (nonatomic) BOOL     isClaimed;
@property (nonatomic) BOOL     isPrivate;
@property (nonatomic) NSString *filename;
@property (nonatomic) int64_t  size;
@property (nonatomic) int      height;
@property (nonatomic) int      width;

-(NSDictionary *)json;

+(OSPMetadata *)metadataWithJSON:(NSDictionary *)json;

@end
