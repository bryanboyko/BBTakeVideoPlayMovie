//
//  BBVideo.m
//  BBTakeVideoPlayMovie
//
//  Created by Bryan Boyko on 9/1/14.
//  Copyright (c) 2014 none. All rights reserved.
//

#import "BBVideo.h"

@implementation BBVideo


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.videoName = [aDecoder decodeObjectForKey:@"videoName"];
        self.videoURL = [aDecoder decodeObjectForKey:@"videoURL"];
        self.videoKey = [aDecoder decodeObjectForKey:@"videoURL"];
        self.thumbnail = [aDecoder decodeObjectForKey:@"thumbnail"];
    }
    return self;
}



- (instancetype)init
{
    return [self initWithVideoName:@"name" videoURL:nil];
}

- (instancetype)initWithVideoName:(NSString *)videoName videoURL:(NSURL *)videoURL
{
    self = [super init];
    if (self) {
        self.videoName = videoName;
        self.videoURL = videoURL;
        
        NSUUID *uuid = [[NSUUID alloc] init];
        NSString *key = [uuid UUIDString];
        self.videoKey = key;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"Destroyed: %@", self);
}


- (NSString *)description
{
    NSString *descriptionString =
    [[NSString alloc] initWithFormat:@"videoName: %@, videoURL: %@",
     self.videoName,
     self.videoURL];
    return descriptionString;
}



- (void)setThumbnailFromImage:(UIImage *)image
{
    CGSize originalSizeImage = image.size;
    
    //make thumbnail size
    CGRect newRect = CGRectMake(0, 0, 40, 40);
    
    //scaling ration to maintain same aspect ratio
    float ratio = MAX(newRect.size.width / originalSizeImage.width, newRect.size.height / originalSizeImage.height);
    
    //create transparent bitmap with scaling factor equal to size of screen
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    
    //create rounded rectangle path
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:5.0];
    
    //make subsqequent drawing clip to this rounded rectangle
    [path addClip];
    
    //center image in thumbnail rectangle
    CGRect projectRect;
    projectRect.size.width = ratio * originalSizeImage.width;
    projectRect.size.height = ratio * originalSizeImage.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;
    
    //draw the image on it
    [image drawInRect:projectRect];
    
    //Get image from image context and keep it as thumbnail
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    self.thumbnail = smallImage;
    
    //cleanup image context resources
    UIGraphicsEndImageContext();
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.videoName forKey:@"videoName"];
    [aCoder encodeObject:self.videoURL forKey:@"videoURL"];
    [aCoder encodeObject:self.videoKey forKey:@"videoKey"];
    [aCoder encodeObject:self.thumbnail forKey:@"thumbnail"];
}

@end
