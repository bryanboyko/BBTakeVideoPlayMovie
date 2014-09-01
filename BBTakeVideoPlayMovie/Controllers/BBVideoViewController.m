//
//  BBVideoViewController.m
//  BBTakeVideoPlayMovie
//
//  Created by Bryan Boyko on 9/1/14.
//  Copyright (c) 2014 none. All rights reserved.
//

#import "BBVideoViewController.h"
#import "BBVideo.h"
#import "BBVideoStore.h"
#import "BBImageStore.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@interface BBVideoViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *videoNameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *albumButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;




@property (nonatomic, strong)MPMoviePlayerController *videoController;


- (IBAction)takePicture:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
- (IBAction)chooseFromPhotoAlbum:(id)sender;
- (IBAction)playVideo:(id)sender;



@end

@implementation BBVideoViewController

- (instancetype)initForNewVideo:(BOOL)isNew
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        if (isNew) {
            UIBarButtonItem *doneVideo = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
            self.navigationItem.rightBarButtonItem = doneVideo;
            
            UIBarButtonItem *cancelVideo = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
            self.navigationItem.leftBarButtonItem = cancelVideo;
        }
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    @throw [NSException exceptionWithName:@"Wrong init" reason:@"Use initForNewVideo" userInfo:nil];
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.video.videoName;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    UIInterfaceOrientation io = [[UIApplication sharedApplication] statusBarOrientation];
    [self prepareViewsForOrientation:io];
    
    BBVideo *video = self.video;
    
    self.videoNameTextField.text = video.videoName;
    
    NSString *itemKey = self.video.videoKey;
    if (itemKey) {
        // Get image for image key from the image store
        UIImage *imageToDisplay = [[BBImageStore sharedStore] imageForKey:itemKey];
        
        // Use that image to put on the screen in imageView
        self.imageView.image = imageToDisplay;
    } else {
        // Clear the imageView
        self.imageView.image = nil;
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
    
    BBVideo *video = self.video;
    video.videoName = self.videoNameTextField.text;
    video.videoURL = self.video.videoURL;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)setVideo:(BBVideo *)video
//{
//
//        self.video = video;
//        self.navigationItem.title = self.video.videoName;
//
//    
//}

- (IBAction)takePicture:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeMovie, nil];
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (IBAction)backgroundTapped:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)chooseFromPhotoAlbum:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,      nil];
    }
    
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)playVideo:(id)sender {
    NSLog(@"touched");
    if (self.video.videoURL) {
        self.videoController = [[MPMoviePlayerController alloc] init];
        [self.videoController  setContentURL:self.video.videoURL];
        [self.view addSubview:self.videoController.view];
        [self.videoController setFullscreen:YES];
        [self.videoController play];
    }
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.video.videoURL = info[UIImagePickerControllerMediaURL];
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.movie"]){
        // Saving the video / // Get the new unique filename
        NSString *sourcePath = [[info objectForKey:@"UIImagePickerControllerMediaURL"]relativePath];
        UISaveVideoAtPathToSavedPhotosAlbum(sourcePath, nil, @selector(video:didFinishSavingWithError:contextInfo:),nil);
    }
    
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self performSelector:@selector(addImageToImageView) withObject:self afterDelay:0];
}



//required for saving video to album
- (void)video: (NSString *) videoPath didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
    
    NSLog(@"Video Saving Error: %@", error);
    [[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];
    NSLog(@"saved video to album");
    
}

- (void)addImageToImageView
{
    //retrieve thumbnail from videoURL
    AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:self.video.videoURL options:nil];
    AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
    generate1.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 2);
    CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
    UIImage *one = [[UIImage alloc] initWithCGImage:oneRef];
    self.imageView.image = one;
    [self.video setThumbnailFromImage:one];
    
    
    if (one) {
        [[BBImageStore sharedStore] setImage:one forKey:self.video.videoKey];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)prepareViewsForOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        self.nameLabel.hidden = YES;
        self.imageView.hidden = YES;
        self.cameraButton.enabled = NO;
    } else {
        self.nameLabel.hidden = NO;
        self.imageView.hidden = NO;
        self.cameraButton.enabled = YES;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self prepareViewsForOrientation:toInterfaceOrientation];
}

- (void)save:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
}

- (void)cancel:(id)sender
{
    //if user cancels, remove exercise from store
    [[BBVideoStore sharedStore] removeVideo:self.video];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
}

@end
