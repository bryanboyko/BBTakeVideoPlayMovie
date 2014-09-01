//
//  BBTableViewController.m
//  BBTakeVideoPlayMovie
//
//  Created by Bryan Boyko on 9/1/14.
//  Copyright (c) 2014 none. All rights reserved.
//

#import "BBTableViewController.h"
#import "BBVideoStore.h"
#import "BBVideo.h"
#import "BBVideoViewController.h"

@interface BBTableViewController ()

@property (nonatomic) UISwipeGestureRecognizer *cellStartEditing, *cellStopEditing;

@end

@implementation BBTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        //add new video button
        UINavigationItem *navItem = self.navigationItem;
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewVideo:)];
        navItem.rightBarButtonItem = bbi;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"# of videos: %d", [[[BBVideoStore sharedStore] allVideos] count]);
    return [[[BBVideoStore sharedStore] allVideos] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSLog(@"CELL");
    
    cell.backgroundColor = [UIColor redColor];
    
    NSArray *videos = [[BBVideoStore sharedStore] allVideos];
    BBVideo *video = videos[indexPath.row];
    
    cell.textLabel.text = video.videoName;
    cell.imageView.image = video.thumbnail;
    
    //etc.
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.cellStartEditing = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleEditingMode:)];
    
    BBVideoViewController *vvc = [[BBVideoViewController alloc] initForNewVideo:NO];
    
    NSArray *videos = [[BBVideoStore sharedStore] allVideos];
    BBVideo *selectedVideo = videos[indexPath.row];
    
    vvc.video = selectedVideo;
    
    [self.navigationController pushViewController:vvc animated:YES];
}


- (IBAction)addNewVideo:(id)sender
{

    BBVideo *newVideo = [[BBVideoStore sharedStore] createVideo];
    
    BBVideoViewController *vvc = [[BBVideoViewController alloc] initForNewVideo:YES];
    
    vvc.video = newVideo;
    
    vvc.dismissBlock = ^{
        [self.tableView reloadData];
        NSLog(@"BLOCK");
    };
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vvc];
    
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)toggleEditingMode:(id)sender
{
    if (self.isEditing) {
        [self setEditing:NO animated:YES];
    } else {
        [self.tableView reloadData];
        [self setEditing:YES animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if tableview is asking to commit a delete command
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *videos = [[BBVideoStore sharedStore] allVideos];
        BBVideo *video = videos[indexPath.row];
        [[BBVideoStore sharedStore] removeVideo:video];
        
        //remove row with animation
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView reloadData];
}



@end
