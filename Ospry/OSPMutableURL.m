// Copyright 2014 Ospry. All Rights Reserved.

#import "OSPMutableURL.h"

@interface OSPMutableURL ()

@property (nonatomic) NSMutableDictionary *query;

@end

@implementation OSPMutableURL

-(id)initWithString:(NSString *)s
{
    if (self = [super init])
    {
        _query = [NSMutableDictionary new];
        int i = indexOf(s, @":", 0);
        if (i == -1) {
            [NSException raise:@"no-scheme" format:@"The URL doesn't contain a scheme."];
        }
        _scheme = slice(s, 0, i);
        i += [@"://" length];
        int j = indexOf(s, @"/", i);
        if (j == -1) {
            _host = slice(s, i, (int)[s length]);
            _path = @"/";
            return self;
        }
        _host = slice(s, i, j);
        int k = indexOf(s, @"?", j);
        if (k == -1) {
            k = (int)[s length];
        }
        _path = slice(s, j, k);
        if (k != [s length]) {
            NSArray *items = [slice(s, k+1, (int)[s length]) componentsSeparatedByString:@"&"];
            for (NSString *item in items) {
                NSArray *parts = [item componentsSeparatedByString:@"="];
                if ([parts count] != 2) {
                    [NSException raise:@"malformed-query" format:@"query string was malformed"];
                }
                [self addQueryWithKey:OSPQueryDecode(parts[0]) value:OSPQueryDecode(parts[1])];
            }
        }
    }
    return self;
}

-(void)setQueryWithKey:(NSString *)key value:(NSString *)value
{
    self.query[key] = [NSMutableArray arrayWithObject:value];
}

-(void)addQueryWithKey:(NSString *)key value:(NSString *)value
{
    NSMutableArray *a = self.query[key];
    if (a == nil) {
        a = [NSMutableArray new];
        self.query[key] = a;
    }
    [a addObject:value];
}

-(void)removeQueryWithKey:(NSString *)key
{
    [self.query removeObjectForKey:key];
}

-(NSString *)string
{
    NSMutableString *s = [NSMutableString string];
    if (self.scheme != nil) {
        [s appendFormat:@"%@://", self.scheme];
    }
    if (self.host != nil) {
        [s appendString:self.host];
    }
    if (self.path != nil) {
        [s appendString:self.path];
    }
    NSArray *keys = [[self.query allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *a = obj1;
        NSString *b = obj2;
        return [a compare:b];
    }];
    BOOL first = YES;
    for (NSString *key in keys) {
        NSArray *items = self.query[key];
        for (NSString *item in items) {
            if (first) {
                [s appendFormat:@"?%@=%@", OSPQueryEncode(key), OSPQueryEncode(item)];
                first = NO;
            } else {
                [s appendFormat:@"&%@=%@", OSPQueryEncode(key), OSPQueryEncode(item)];
            }
        }
    }
    return s;
}

+(OSPMutableURL *)urlWithString:(NSString *)s
{
    return [[OSPMutableURL alloc] initWithString:s];
}

static const char *hex = "0123456789ABCDEF";

NSString* OSPQueryEncode(NSString *s) {
    NSData *data = [s dataUsingEncoding:NSUTF8StringEncoding];
    const uint8_t *p = [data bytes];
    int n = (int)[data length];
    NSMutableData *t = [NSMutableData data];
    uint8_t buf[3];
    for (int i = 0; i < n; i++) {
        uint8_t c = p[i];
        if (shouldEscape(c)) {
            if (c == ' ') {
                // Spaces become '+'.
                buf[0] = '+';
                [t appendBytes:&buf length:1];
            } else {
                // Non-spaces are percent-hex encoded.
                buf[0] = '%';
                buf[1] = hex[c >> 4];
                buf[2] = hex[c & 0x0F];
                [t appendBytes:&buf length:3];
            }
        } else {
            [t appendBytes:&c length:1];
        }
    }
    return [[NSString alloc] initWithData:t encoding:NSUTF8StringEncoding];
}

static BOOL shouldEscape(char c) {
    if (isalnum(c)) {
        return NO;
    }
    switch (c) {
        case '-': case '_': case '.': case '~':
            return NO;
        default:
            return YES;
    }
}

NSString* OSPQueryDecode(NSString *s) {
    NSData *data = [s dataUsingEncoding:NSUTF8StringEncoding];
    const uint8_t *p = [data bytes];
    int n = (int)[data length];
    NSMutableData *t = [NSMutableData data];
    char space = ' ';
    for (int i = 0; i < n; i++) {
        uint8_t c = p[i];
        switch (c) {
            case '+':
                [t appendBytes:&space length:1];
                break;
            case '%':
                c = (hexDecode(p[i+1]) << 4) | hexDecode(p[i+2]);
                [t appendBytes:&c length:1];
                break;
            default:
                [t appendBytes:&c length:1];
                break;
        }
    }
    return [[NSString alloc] initWithData:t encoding:NSUTF8StringEncoding];
}

static uint8_t hexDecode(char c)
{
    if ('0' <= c && c <= '9') {
        return c - '0';
    }
    c = tolower(c);
    if ('a' <= c && c <= 'f') {
        return 10 + (c - 'a');
    }
    return 0;
}

static int indexOf(NSString *s, NSString *sub, int start)
{
    NSRange r = [s rangeOfString:sub options:0 range:NSMakeRange(start, [s length] - start)];
    if (r.length == 0) {
        return -1;
    }
    return (int)r.location;
}

static NSString* slice(NSString *s, int start, int end)
{
    return [s substringWithRange:NSMakeRange(start, end - start)];
}

@end
