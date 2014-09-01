//
//  BBVideoViewController.h
//  BBTakeVideoPlayMovie
//
//  Created by Bryan Boyko on 9/1/14.
//  Copyright (c) 2014 none. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBVideo;

@interface BBVideoViewController : UIViewController

@property (nonatomic, strong) BBVideo *video;

- (instancetype)initForNewVideo:(BOOL)isNew;

@property (nonatomic, copy) void (^dismissBlock)(void);

@end
