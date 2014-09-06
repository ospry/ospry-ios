// Copyright 2014 Ospry. All Rights Reserved.

#import <Foundation/Foundation.h>

#import "OSPMetadata.h"

// Formats to convert bitmaps to before upload.
typedef NS_ENUM(NSUInteger, OSPUploadFormat) {
    kOSPUploadFormatJPEG,
    kOSPUploadFormatPNG
};

typedef void (^OSPMetadataBlock)(OSPMetadata *metadata, NSError *error);
typedef void (^OSPUIImageBlock)(UIImage *image, NSError *error);
typedef void (^OSPCGImageBlock)(CGImageRef image, NSError *error);
typedef void (^OSPNSDataBlock)(NSData *data, NSString *contentType, NSError *error);
typedef void (^OSPCompleteBlock)(NSError *error);

@interface OSPClient : NSObject

@property (nonatomic) NSString *key;
@property (nonatomic) NSString *serverURL;

// Uploads the asset corresponding to the given asset url. The URL can be
// obtained using ALAssetsLibrary or UIImagePickerController
// (UIImagePickerControllerReferenceURL).
-(void)uploadAssetWithURL:(NSURL *)url
                isPrivate:(BOOL)isPrivate
                 complete:(OSPMetadataBlock)complete;

// Uploads the file corresponding to the given path.
-(void)uploadFileAtPath:(NSString *)path
              isPrivate:(BOOL)isPrivate
               complete:(OSPMetadataBlock)complete;

// Uploads the bitmap image corresponding to the given UIImage. The bitmap
// is converted into the chosen format before being uploaded.
-(void)uploadUIImage:(UIImage *)image
              format:(OSPUploadFormat)format
            filename:(NSString *)filename
           isPrivate:(BOOL)isPrivate
            complete:(OSPMetadataBlock)complete;

// Uploads the bitmap image corresponding to the given CGImageRef. The bitmap
// is converted into the chosen format before being uploaded.
-(void)uploadCGImage:(CGImageRef)image
              format:(OSPUploadFormat)format
            filename:(NSString *)filename
           isPrivate:(BOOL)isPrivate
            complete:(OSPMetadataBlock)complete;

// Uploads the binary data (which should contain an image).
-(void)uploadData:(NSData *)data
         filename:(NSString *)filename
        isPrivate:(BOOL)isPrivate
         complete:(OSPMetadataBlock)complete;

// Downloads the image corresponding to the given url, saves it to a
// file. Optionally, the image is modified on the server according to
// the specified options (see formatURL:opts: for documentation).
-(void)downloadToFileAtPath:(NSString *)path
                        url:(NSString *)url
                       opts:(NSDictionary *)opts
                   complete:(OSPCompleteBlock)complete;

// Downloads the image corresponding to the given url. Optionally, the
// image is modified on the server according to the specified options
// (see formatURL:opts: for documentation on the options).
-(void)downloadUIImageWithURL:(NSString *)url
                         opts:(NSDictionary *)opts
                     complete:(OSPUIImageBlock)complete;

// Downloads the image corresponding to the given url. Optionally, the
// image is modified on the server according to the specified options
// (see formatURL:opts: for documentation on the options).
-(void)downloadCGImageWithURL:(NSString *)url
                         opts:(NSDictionary *)opts
                     complete:(OSPCGImageBlock)complete;

// Downloads the image data corresponding to the given url. Optionally,
// the image id modified on the server according to the specified options
// (see formatURL:opts: for documentation on the options).
-(void)downloadDataWithURL:(NSString *)url
                      opts:(NSDictionary *)opts
                  complete:(OSPNSDataBlock)complete;

// Modifies an image url according to the given options:
//   maxHeight - NSNumber (e.g. @(400))
//   maxWidth  - NSNumber (e.g. @(400))
//   format    - NSString (@"jpeg", @"png", or @"gif")
-(NSString *)formatURL:(NSString *)url opts:(NSDictionary *)opts;

-(NSArray *)formats;

@end
