# Ospry

iOS bindings for the Ospry image hosting API. Learn more about
Ospry at [ospry.io](https://ospry.io).

## About

**Ospry** allows developers to upload, download, delete, and change
  permissions on images stored with Ospry's image hosting
  services.

Use your public API key to upload and download images.

## Requirements

To use Ospry, you must have an active Ospry account. Sign up for one
free at [ospry.io](https://ospry.io).

Each account comes with a "sandbox" pair of public/secret keys for
development, and a set of production keys when you're ready to roll.

## Installation

Add the following to your `Podfile`:

```
pod 'Ospry', '~> 1.0'
```

Then install Ospry and its dependencies.

```
pod install
```

Alternatively, you can copy the source files into your project, but be
sure to grab the dependencies as well.

## Set the API Key

You can set the API key used by the default client like this:

```
[Ospry setKey:@"YOUR-PUBLIC-KEY"];
```

## Image Uploading

### uploadAssetWithURL:isPrivate:complete:

Uploads an image to Ospry with a given asset and privacy
setting.

**Example:**

```obj-c
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Assuming image is picked from photo library.
    NSURL *assetURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    [Ospry uploadAssetWithURL:assetURL
                    isPrivate:false
                     complete:^(OSPMetadata *metadata, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", error);
            return;
        }
        NSLog(@"received metadata: %@", metadata);
    }];
}
```

**Arguments:**

- `url` (`NSURL *`): the asset url obtained from ALAssetsLibrary or UIImagePickerController.
- `isPrivate` (`BOOL`): the privacy setting for the uploaded image.
- `complete` (`OSPMetadataBlock`): a callback for when the upload attempt is complete. The callback receives an `OSPMetadata` and an `NSError`.

### uploadFileAtPath:isPrivate:complete:

Uploads an image to Ospry with a given file and privacy
setting.

**Example:**

```obj-c
[Ospry uploadFileAtPath:imageFilePath
              isPrivate:NO
               complete:^(OSPMetadata *metadata, NSError *error) {
    if (error != nil) {
        NSLog(@"%@", error);
        return;
    }
    NSLog(@"received metadata: %@", metadata);
}];
```

**Arguments:**

- `path` (`NSString *`): the file path.
- `isPrivate` (`BOOL`): the privacy setting for the uploaded image.
- `complete` (`OSPMetadataBlock`): a callback for when the upload attempt is complete. The callback receives an `OSPMetadata` and an `NSError`.

### uploadUIImage:format:filename:isPrivate:complete:

Uploads a UIImage to Ospry with the given format, filename, and privacy
setting.

**Example:**

```obj-c
[Ospry uploadUIImage:image
              format:kOSPUploadFormatJPEG
            filename:@"foo.jpg"
           isPrivate:NO
            complete:^(OSPMetadata *metadata, NSError *error) {
    if (error != nil) {
        NSLog(@"%@", error);
        return;
    }
    NSLog(@"received metadata: %@", metadata);
}];
```

**Arguments:**

- `image` (`UIImage *`): the image.
- `format` (`OSPUploadFormat`): desired image format (e.g. jpeg).
- `filename` (`NSString *`): desired filename.
- `isPrivate` (`BOOL`): the privacy setting for the uploaded image.
- `complete` (`OSPMetadataBlock`): a callback for when the upload attempt is complete. The callback receives an `OSPMetadata` and an `NSError`.

### uploadCGImage:format:filename:isPrivate:complete:

Uploads a CGImageRef to Ospry with the given format, filename, and privacy
setting.

**Example:**

```obj-c
[Ospry uploadCGImage:image
              format:kOSPUploadFormatJPEG
            filename:@"foo.jpg"
           isPrivate:NO
            complete:^(OSPMetadata *metadata, NSError *error) {
    if (error != nil) {
        NSLog(@"%@", error);
        return;
    }
    NSLog(@"received metadata: %@", metadata);
}];
```

**Arguments:**

- `image` (`CGImageRef`): the image.
- `format` (`OSPUploadFormat`): desired image format (e.g. jpeg).
- `filename` (`NSString *`): desired filename.
- `isPrivate` (`BOOL`): the privacy setting for the uploaded image.
- `complete` (`OSPMetadataBlock`): a callback for when the upload attempt is complete. The callback receives an `OSPMetadata` and an `NSError`.

### uploadData:filename:isPrivate:complete:

Uploads NSData to Ospry with the given filename and privacy
setting.

**Example:**

```obj-c
[Ospry uploadData:data
         filename:@"foo.jpg"
        isPrivate:NO
         complete:^(OSPMetadata *metadata, NSError *error) {
    if (error != nil) {
        NSLog(@"%@", error);
        return;
    }
    NSLog(@"received metadata: %@", metadata);
}];
```

**Arguments:**

- `data` (`NSData *`): the image as NSData.
- `filename` (`NSString *`): desired filename.
- `isPrivate` (`BOOL`): the privacy setting for the uploaded image.
- `complete` (`OSPMetadataBlock`): a callback for when the upload attempt is complete. The callback receives an `OSPMetadata` and an `NSError`.

## Image Downloading

### downloadToFileAtPath:url:opts:complete:

Downloads an image to a file.

**Example:**

```obj-c
NSDictionary *opts = @{@"maxWidth": @(400)};
[Ospry downloadToFileAtPath:dst
                        url:metadata.url
                       opts:opts
                   complete:^(NSError *error) {
    if (error != nil) {
        NSLog(@"%@", error);
        return;
    }
    // Do something with the file.
}];
```

**Arguments:**

- `path` (`NSString *`): file path to store the image at.
- `url` (`NSString *`): image url.
- `opts` (`NSDictionary *`): options for the download, see formatURL:opts
- `complete` (`OSPCompleteBlock`): a callback for when the upload attempt is complete. The callback receives an `NSError`.

### downloadUIImageWithURL:opts:complete:

Downloads an image to a UIImage.

**Example:**

```obj-c
NSDictionary *opts = @{@"maxWidth": @(400)};
[Ospry downloadUIImageWithURL:metadata.url
                         opts:opts
                     complete:^(UIImage *image, NSError *error) {
    if (error != nil) {
        NSLog(@"%@", error);
        return;
    }
    // Do something with the UIImage.
}];
```

**Arguments:**

- `url` (`NSString *`): image url.
- `opts` (`NSDictionary *`): options for the download, see formatURL:opts
- `complete` (`OSPUIImageBlock`): a callback for when the upload attempt is complete. The callback receives a `UIImage` and an `NSError`.

### downloadCGImageWithURL:opts:complete:

Downloads an image to a CGImageRef.

**Example:**

```obj-c
NSDictionary *opts = @{@"maxWidth": @(400)};
[Ospry downloadCGImageWithURL:metadata.url
                         opts:opts
                     complete:^(CGImageRef image, NSError *error) {
    if (error != nil) {
        NSLog(@"%@", error);
        return;
    }
    // Do something with the CGImageRef.
}];
```

**Arguments:**

- `url` (`NSString *`): image url.
- `opts` (`NSDictionary *`): options for the download, see formatURL:opts
- `complete` (`OSPCGImageBlock`): a callback for when the upload attempt is complete. The callback receives a `CGImageRef` and an `NSError`.

### downloadDataWithURL:opts:complete:

Downloads an image to an NSData.

**Example:**

```obj-c
NSDictionary *opts = @{@"maxWidth": @(400)};
[Ospry downloadDataWithURL:metadata.url
                      opts:opts
                  complete:^(NSData *data, NSString *contentType, NSError *error) {
    if (error != nil) {
        NSLog(@"%@", error);
        return;
    }
    // Do something with the NSData.
}];
```

**Arguments:**

- `url` (`NSString *`): image url.
- `opts` (`NSDictionary *`): options for the download, see formatURL:opts
- `complete` (`OSPDataBlock`): a callback for when the upload attempt is complete. The callback receives an `NSData`, a `NSString` mime type, and an `NSError`.

## Reference

### Image Metadata

Callbacks that receive a `metadata` object in the callback can expect the following format:

```obj-c
@interface OSPMetadata : NSObject

@property (nonatomic) NSString *identifier;     // image ID
@property (nonatomic) NSString *url;            // download URL
@property (nonatomic) NSString *httpsURL;       // https download url
@property (nonatomic) NSDate   *timeCreated;    // upload time
@property (nonatomic) BOOL     isClaimed;       // whether the image has been claimed
@property (nonatomic) BOOL     isPrivate;       // whether the image is private
@property (nonatomic) NSString *filename;       // image's filename
@property (nonatomic) NSString *format;         // e.g. "jpeg"
@property (nonatomic) int64_t  size;            // file size in bytes
@property (nonatomic) int      height;          // height in pixels
@property (nonatomic) int      width;           // width in pixels

@end
```
