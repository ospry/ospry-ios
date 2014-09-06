//  Copyright 2014 Ospry. All rights reserved.

#import "OSPViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import "Ospry.h"

@interface OSPViewController ()

@property (nonatomic) UIImagePickerController *ipc;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIActivityIndicatorView *spinner;
@property (nonatomic) UILabel *statusLabel;

@end

@implementation OSPViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    self.title = @"Photoz";
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 200)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = self.imageView.center;
    [self.view addSubview:self.spinner];
    
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                 self.spinner.frame.origin.y + self.spinner.frame.size.height,
                                                                 self.view.frame.size.width,
                                                                 20)];
    self.statusLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    self.statusLabel.text = @"";
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.statusLabel];
    
    CGFloat y = self.imageView.frame.origin.y + self.imageView.frame.size.height;
    
    UILabel *directions = [[UILabel alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, 50)];
    directions.text = @"Upload a photo to Ospry:";
    directions.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:directions];
    
    y = directions.frame.origin.y + directions.frame.size.height;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIButton *libraryBtn = [self makeButton:@"Photo Library"];
        libraryBtn.tag = UIImagePickerControllerSourceTypePhotoLibrary;
        y = [self layoutButton:libraryBtn y:y];
        [self.view addSubview:libraryBtn];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIButton *cameraBtn = [self makeButton:@"Camera"];
        cameraBtn.tag = UIImagePickerControllerSourceTypeCamera;
        y = [self layoutButton:cameraBtn y:y];
        [self.view addSubview:cameraBtn];
    }
}

-(UIButton *)makeButton:(NSString *)title
{
    UIButton *b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    b.frame = CGRectMake(0, 0, 120, 50);
    [b setTitle:title forState:UIControlStateNormal];
    [b addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    return b;
}

-(CGFloat) layoutButton:(UIButton *)b y:(CGFloat)y
{
    b.center = CGPointMake(self.view.frame.size.width/2.0, y + b.frame.size.height/2.0);
    return b.frame.origin.y + b.frame.size.height;
}

-(void)click:(UIButton *)sender
{
    self.ipc = [[UIImagePickerController alloc] init];
    self.ipc.delegate = self;
    self.ipc.sourceType = sender.tag;
    [self presentViewController:self.ipc animated:YES completion:NULL];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.imageView.image = nil;
    [self.spinner startAnimating];
    self.statusLabel.text = @"uploading...";

    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        ALAssetsLibrary *lib = [ALAssetsLibrary new];
        [lib writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
            
            [self uploadWithAssetURL:assetURL];
        
        }];
    } else {
        [self uploadWithAssetURL:[info valueForKey:UIImagePickerControllerReferenceURL]];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
    self.ipc = nil;
}

-(void)uploadWithAssetURL:(NSURL *)assetURL
{
    [Ospry uploadAssetWithURL:assetURL isPrivate:false complete:^(OSPMetadata *metadata, NSError *error) {
        
        if (error != nil) {
            NSLog(@"%@", error);
            return;
        }
        NSLog(@"received metadata: %@", metadata);
        self.statusLabel.text = @"downloading...";
        NSDictionary *opts = @{@"maxHeight": @(self.imageView.frame.size.height * [UIScreen mainScreen].scale)};
        [Ospry downloadUIImageWithURL:metadata.url opts:opts complete:^(UIImage *image, NSError *error) {
            
            if (error != nil) {
                NSLog(@"%@", error);
                return;
            }
            NSLog(@"download complete");
            self.imageView.image = image;
            
            [self.spinner stopAnimating];
            self.statusLabel.text = @"";
            
        }];
        
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
