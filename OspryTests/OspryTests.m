// Copyright 2014 Ospry. All Rights Reserved.

#import <XCTest/XCTest.h>

#import <AssetsLibrary/AssetsLibrary.h>
#import "Ospry.h"

@interface OspryTests : XCTestCase

@property (nonatomic) NSString *imagePath;

@end

@implementation OspryTests

-(void)setUp
{
    [super setUp];
    [Ospry setKey:OSPRY_PUBLIC_KEY];
    NSBundle *b = [NSBundle bundleForClass:[OspryTests class]];
    self.imagePath = [b pathForResource:@"taxis" ofType:@"jpg"];
}

-(void)tearDown
{
    [super tearDown];
}

-(void)testUploadAsset
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"upload complete"];
    
    UIImage *image = [UIImage imageWithContentsOfFile:self.imagePath];
    ALAssetsLibrary *lib = [ALAssetsLibrary new];
    [lib writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error) {
        
        [lib assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            uint64_t size = [rep size];
            
            [Ospry uploadAssetWithURL:assetURL isPrivate:NO complete:^(OSPMetadata *metadata, NSError *error) {
                
                [expectation fulfill];
                XCTAssertNil(error, @"Error was non-nil: %@", error);
                
                NSLog(@"metadata received: %@", metadata);
                XCTAssertEqual(size, metadata.size);
                XCTAssertEqual((int)image.size.height, metadata.height);
                XCTAssertEqual((int)image.size.width, metadata.width);
                
            }];
            
        } failureBlock:^(NSError *error) {

            XCTFail(@"%@", error);
            
        }];

    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

-(void)testUploadFile
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"upload complete"];
    
    NSError *error;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:self.imagePath error:&error];
    XCTAssertNil(error, @"Error was non-nil: %@", error);
    int64_t size = [attrs[NSFileSize] longLongValue];

    [Ospry uploadFileAtPath:self.imagePath isPrivate:NO complete:^(OSPMetadata *metadata, NSError *error) {
        
        [expectation fulfill];
        XCTAssertNil(error, @"Error was non-nil: %@", error);
        
        NSLog(@"metadata received: %@", metadata);
        XCTAssertEqual(size, metadata.size);
        XCTAssertEqualObjects(@"taxis.jpg", metadata.filename);
        XCTAssertFalse(metadata.isPrivate);
        
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

-(void)testUploadUIImage
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"upload"];
    
    UIImage *image = [UIImage imageWithContentsOfFile:self.imagePath];
    
    [Ospry uploadUIImage:image format:kOSPUploadFormatJPEG filename:@"taxis.jpg" isPrivate:NO complete:^(OSPMetadata *metadata, NSError *error) {

        [expectation fulfill];
        XCTAssertNil(error, @"Error was non-nil: %@", error);
        
        NSLog(@"metadata received: %@", metadata);
        XCTAssertEqual((int)image.size.height, metadata.height);
        XCTAssertEqual((int)image.size.width, metadata.width);
        XCTAssertEqualObjects(@"taxis.jpg", metadata.filename);
        XCTAssertFalse(metadata.isPrivate);
        
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

-(void)testUploadCGImage
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"upload"];
    
    UIImage *image = [UIImage imageWithContentsOfFile:self.imagePath];
    
    [Ospry uploadCGImage:[image CGImage] format:kOSPUploadFormatJPEG filename:@"taxis.jpg" isPrivate:NO complete:^(OSPMetadata *metadata, NSError *error) {
        
        [expectation fulfill];
        XCTAssertNil(error, @"Error was non-nil: %@", error);
        
        NSLog(@"metadata received: %@", metadata);
        XCTAssertEqual((int)image.size.height, metadata.height);
        XCTAssertEqual((int)image.size.width, metadata.width);
        XCTAssertEqualObjects(@"taxis.jpg", metadata.filename);
        XCTAssertFalse(metadata.isPrivate);
        
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

-(void)testUploadData
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"upload"];
    
    UIImage *image = [UIImage imageWithContentsOfFile:self.imagePath];
    NSData *data = UIImageJPEGRepresentation(image, 0.9);
    
    [Ospry uploadData:data filename:@"taxis.jpg" isPrivate:NO complete:^(OSPMetadata *metadata, NSError *error) {

        [expectation fulfill];
        XCTAssertNil(error, @"Error was non-nil: %@", error);
        
        NSLog(@"metadata received: %@", metadata);
        XCTAssertEqual((int)image.size.height, metadata.height);
        XCTAssertEqual((int)image.size.width, metadata.width);
        XCTAssertEqualObjects(@"taxis.jpg", metadata.filename);
        XCTAssertFalse(metadata.isPrivate);
        
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

-(void)testDownloadFile
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"upload/download"];
    
    [Ospry uploadFileAtPath:self.imagePath isPrivate:NO complete:^(OSPMetadata *metadata, NSError *error) {

        XCTAssertNil(error, @"Error was non-nil: %@", error);
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *dst = [[paths firstObject] stringByAppendingPathComponent:metadata.filename];
        NSLog(@"dst = %@", dst);
        
        NSDictionary *opts = @{@"maxWidth": @(400)};
        [Ospry downloadToFileAtPath:dst url:metadata.url opts:opts complete:^(NSError *error) {
            
            [expectation fulfill];
            XCTAssertNil(error, @"Error was non-nil: %@", error);
            
            UIImage *image = [UIImage imageWithContentsOfFile:dst];
            XCTAssertEqual(400, (int)image.size.width);
            
            // Clean up.
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:dst error:&error];

        }];
        
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

-(void)testDownloadUIImage
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"upload/download"];
    
    [Ospry uploadFileAtPath:self.imagePath isPrivate:NO complete:^(OSPMetadata *metadata, NSError *error) {
        
        XCTAssertNil(error, @"Error was non-nil: %@", error);
        
        NSDictionary *opts = @{@"maxWidth": @(400)};
        [Ospry downloadUIImageWithURL:metadata.url opts:opts complete:^(UIImage *image, NSError *error) {
            
            [expectation fulfill];
            XCTAssertNil(error, @"Error was non-nil: %@", error);
            
            XCTAssertEqual(400, (int)image.size.width);
            
        }];
        
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

-(void)testDownloadCGImage
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"upload/download"];
    
    [Ospry uploadFileAtPath:self.imagePath isPrivate:NO complete:^(OSPMetadata *metadata, NSError *error) {
        
        XCTAssertNil(error, @"Error was non-nil: %@", error);
        
        NSDictionary *opts = @{@"maxWidth": @(400)};
        [Ospry downloadCGImageWithURL:metadata.url opts:opts complete:^(CGImageRef image, NSError *error) {
            
            [expectation fulfill];
            XCTAssertNil(error, @"Error was non-nil: %@", error);
            
            XCTAssertEqual(400, CGImageGetWidth(image));
            
        }];
        
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

-(void)testDownloadData
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"upload/download"];
    
    [Ospry uploadFileAtPath:self.imagePath isPrivate:NO complete:^(OSPMetadata *metadata, NSError *error) {
        
        XCTAssertNil(error, @"Error was non-nil: %@", error);
        
        NSDictionary *opts = @{@"maxWidth": @(400)};
        [Ospry downloadDataWithURL:metadata.url opts:opts complete:^(NSData *data, NSString *contentType, NSError *error) {

            [expectation fulfill];
            XCTAssertNil(error, @"Error was non-nil: %@", error);
            
            XCTAssertEqualObjects(@"image/jpeg", contentType);
            UIImage *image = [UIImage imageWithData:data];
            XCTAssertEqual(400, (int)image.size.width);
            
        }];
        
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

@end
