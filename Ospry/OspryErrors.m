// Copyright 2014 Ospry. All Rights Reserved.

#import "OspryErrors.h"

NSString *const OspryErrorDomain = @"io.ospry.lib";

NSString *const OSPErrorKeyHTTPStatusCode = @"io.ospry.lib:HTTPStatusCode";
NSString *const OSPErrorKeyCause = @"io.ospry.lib:Cause";
NSString *const OSPErrorKeyMessage = @"io.ospry.lib:Message";
NSString *const OSPErrorKeyDocsURL = @"io.ospry.lib:DocsURL";

static OSPErrorCode OSPErrorCodeWithCause(NSString *cause)
{
    if ([cause isEqualToString:@"forbidden"]) { return OSPErrorCodeForbidden; }
    if ([cause isEqualToString:@"not-found"]) { return OSPErrorCodeNotFound; }
    if ([cause isEqualToString:@"method-not-allowed"]) { return OSPErrorCodeMethodNotAllowed; }
    if ([cause isEqualToString:@"internal-error"]) { return OSPErrorCodeInternalError; }
    if ([cause isEqualToString:@"service-unavailable"]) { return OSPErrorCodeServiceUnavailable; }

    if ([cause isEqualToString:@"invalid-json"]) { return OSPErrorCodeInvalidJSON; }
    if ([cause isEqualToString:@"invalid-multipart"]) { return OSPErrorCodeInvalidMultipart; }
    
    if ([cause isEqualToString:@"missing-filename"]) { return OSPErrorCodeMissingFilename; }
    if ([cause isEqualToString:@"invalid-filename"]) { return OSPErrorCodeInvalidFilename; }
    if ([cause isEqualToString:@"missing-is-private"]) { return OSPErrorCodeMissingIsPrivate; }
    if ([cause isEqualToString:@"invalid-is-private"]) { return OSPErrorCodeInvalidIsPrivate; }
    if ([cause isEqualToString:@"invalid-format"]) { return OSPErrorCodeInvalidFormat; }
    if ([cause isEqualToString:@"invalid-max-height"]) { return OSPErrorCodeInvalidMaxHeight; }
    if ([cause isEqualToString:@"invalid-max-width"]) { return OSPErrorCodeInvalidMaxWidth; }
    if ([cause isEqualToString:@"invalid-time-expired"]) { return OSPErrorCodeInvalidTimeExpired; }
    
    if ([cause isEqualToString:@"subdomain-not-set"]) { return OSPErrorCodeSubdomainNotSet; }
    if ([cause isEqualToString:@"too-many-parts"]) { return OSPErrorCodeTooManyParts; }
    if ([cause isEqualToString:@"no-file-parts"]) { return OSPErrorCodeNoFileParts; }
    if ([cause isEqualToString:@"image-too-large"]) { return OSPErrorCodeImageTooLarge; }
    if ([cause isEqualToString:@"invalid-image-format"]) { return OSPErrorCodeInvalidImageFormat; }
    
    return OSPErrorCodeUnknown;
}

NSError* OSPErrorWithJSON(NSDictionary *json)
{
    NSString *cause = json[@"cause"];
    NSString *message = json[@"message"];
    NSDictionary *userInfo = @{
        OSPErrorKeyHTTPStatusCode: json[@"httpStatusCode"],
        OSPErrorKeyCause: cause,
        OSPErrorKeyMessage: message,
        OSPErrorKeyDocsURL: json[@"docsUrl"],
        NSLocalizedDescriptionKey: message,
    };
    return [NSError errorWithDomain:OspryErrorDomain
                               code:OSPErrorCodeWithCause(cause)
                           userInfo:userInfo];
}

NSError* OSPErrorWithStatusCode(int statusCode)
{
    NSString *cause;
    NSString *message;
    switch (statusCode) {
        case 403:
            cause = @"forbidden";
            message = @"Forbidden.";
            break;
        case 404:
            cause = @"not-found";
            message = @"Not found.";
            break;
        case 500:
            cause = @"internal-error";
            message = @"Internal error.";
            break;
        case 503:
            cause = @"service-unavailable";
            message = @"Service unavailable.";
            break;
        default:
            statusCode = 500;
            cause = @"internal-error";
            message = @"Internal error.";
            break;
    }
    NSDictionary *userInfo = @{
        OSPErrorKeyHTTPStatusCode: @(statusCode),
        OSPErrorKeyCause: cause,
        OSPErrorKeyMessage: message,
        OSPErrorKeyDocsURL: [NSString stringWithFormat:@"https://ospry.io/docs#error-%@", cause],
        NSLocalizedDescriptionKey: message,
    };
    return [NSError errorWithDomain:OspryErrorDomain
                               code:OSPErrorCodeWithCause(cause)
                           userInfo:userInfo];
}

