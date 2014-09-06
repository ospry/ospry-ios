// Copyright 2014 Ospry. All Rights Reserved.

#import <Foundation/Foundation.h>

NSString *const OspryErrorDomain;

// Additional userInfo keys.
NSString *const OSPErrorKeyHTTPStatusCode;
NSString *const OSPErrorKeyCause;
NSString *const OSPErrorKeyMessage;
NSString *const OSPErrorKeyDocsURL;

// Codes.
typedef enum {
    OSPErrorCodeUnknown = 0,
    
    OSPErrorCodeForbidden          = 403,
    OSPErrorCodeNotFound           = 404,
    OSPErrorCodeMethodNotAllowed   = 405,
    OSPErrorCodeInternalError      = 500,
    OSPErrorCodeServiceUnavailable = 503,
    
    OSPErrorCodeInvalidJSON      = 1000,
    OSPErrorCodeInvalidMultipart = 1001,
    
    OSPErrorCodeMissingFilename    = 2000,
    OSPErrorCodeInvalidFilename    = 2001,
    OSPErrorCodeMissingIsPrivate   = 2010,
    OSPErrorCodeInvalidIsPrivate   = 2011,
    OSPErrorCodeInvalidFormat      = 2020,
    OSPErrorCodeInvalidMaxHeight   = 2030,
    OSPErrorCodeInvalidMaxWidth    = 2040,
    OSPErrorCodeInvalidTimeExpired = 2050,

    OSPErrorCodeSubdomainNotSet    = 3000,
    OSPErrorCodeTooManyParts       = 3010,
    OSPErrorCodeNoFileParts        = 3011,
    OSPErrorCodeImageTooLarge      = 3020,
    OSPErrorCodeInvalidImageFormat = 3021,
    
} OSPErrorCode;

NSError* OSPErrorWithJSON(NSDictionary *json);
NSError* OSPErrorWithStatusCode(int statusCode);
