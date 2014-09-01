//
//  BBVideo.h
//  BBTakeVideoPlayMovie
//
//  Created by Bryan Boyko on 9/1/14.
//  Copyright (c) 2014 none. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBVideo : NSObject <NSCoding>

@property (nonatomic, copy) NSString *videoName;
@property (nonatomic, copy) NSURL *videoURL;

@property (nonatomic, copy) NSString *videoKey;
@property (nonatomic) UIImage *thumbnail;

// designated initailzer for BBVideo
- (instancetype)initWithVideoName:(NSString *)videoName
                         videoURL:(NSURL *)videoURL;

- (void)setThumbnailFromImage:(UIImage *)image;

@end
