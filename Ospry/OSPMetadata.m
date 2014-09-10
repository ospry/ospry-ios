// Copyright 2014 Ospry. All Rights Reserved.

#import "OSPMetadata.h"

#import "ISO8601/ISO8601.h"

@implementation OSPMetadata

-(NSString *)description
{
    NSMutableString *s = [NSMutableString stringWithString:@"OSPMetadata {\n"];
    [s appendFormat:@"  identifier = %@\n", self.identifier];
    [s appendFormat:@"  url = %@\n", self.url];
    [s appendFormat:@"  httpsURL = %@\n", self.httpsURL];
    [s appendFormat:@"  timeCreated = %@\n", [self.timeCreated ISO8601String]];
    [s appendFormat:@"  isClaimed = %@\n", (self.isClaimed ? @"YES" : @"NO")];
    [s appendFormat:@"  isPrivate = %@\n", (self.isPrivate ? @"YES" : @"NO")];
    [s appendFormat:@"  filename = %@\n", self.filename];
    [s appendFormat:@"  format = %@\n", self.format];
    [s appendFormat:@"  size = %lld\n", self.size];
    [s appendFormat:@"  height = %d\n", self.height];
    [s appendFormat:@"  width = %d\n", self.width];
    [s appendString:@"}\n"];
    return s;
}

-(NSDictionary *)json
{
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    d[@"id"] = self.identifier;
    d[@"url"] = self.url;
    d[@"httpsURL"] = self.httpsURL;
    d[@"timeCreated"] = [self.timeCreated ISO8601String];
    d[@"isClaimed"] = @(self.isClaimed);
    d[@"isPrivate"] = @(self.isPrivate);
    d[@"filename"] = self.filename;
    d[@"format"] = self.format;
    d[@"size"] = @(self.size);
    d[@"height"] = @(self.height);
    d[@"width"] = @(self.width);
    return d;
}

+(OSPMetadata *)metadataWithJSON:(NSDictionary *)json
{
    OSPMetadata *m = [OSPMetadata new];
    m.identifier = json[@"id"];
    m.url = json[@"url"];
    m.httpsURL = json[@"httpsURL"];
    m.timeCreated = [NSDate dateWithISO8601String:json[@"timeCreated"]];
    m.isClaimed = [json[@"isClaimed"] boolValue];
    m.isPrivate = [json[@"isPrivate"] boolValue];
    m.filename = json[@"filename"];
    m.format = json[@"format"];
    m.size = [json[@"size"] longLongValue];
    m.height = [json[@"height"] intValue];
    m.width = [json[@"width"] intValue];
    return m;
}

@end
