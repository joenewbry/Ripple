//
//  BLKSaveImage.m
//  Blink
//
//  Created by Joe Newbry on 2/25/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "RIPSaveImage.h"
#import <Parse/Parse.h>
#import "SBUser.h"
#import "SBUserBroadcast.h"

@interface RIPSaveImage ()

@property (nonatomic, strong) NSMutableData *imgData;
@property (nonatomic, strong) NSURLConnection *URLConnection;
@property (nonatomic, strong) UIImage *imgRef;

@end

@implementation RIPSaveImage

BOOL saveToImage;

static RIPSaveImage *instance = nil;

+ (RIPSaveImage *)instanceSavedImage
{
    @synchronized (self) {
        if (instance == nil) {
            instance = [[RIPSaveImage alloc] init];
        }
    }
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.imgData = [NSMutableData new];
    }
    return self;
}

- (void)saveImageInBackground:(NSURL *)url
{
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2.0f];
    self.URLConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
}

- (void)saveImageInBackground:(NSURL *)url toImage:(UIImage *)image
{
    self.imgRef = image;
    saveToImage = true;

}

// Called every time a chunk of the data is received
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.imgData appendData:data]; // Build the image
}

// Called when the entire image is finished downloading
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    if (saveToImage) self.imgRef = [UIImage imageWithData:self.imgData];
    // Set the image in the header imageView
    PFFile *imageFile = [PFFile fileWithData:self.imgData]; // saves to parse

    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [PFUser currentUser][@"profileImage"] = imageFile;
        [[PFUser currentUser] saveEventually];
    }];

    UIImage *thumbnailImage =[UIImage imageWithData:self.imgData scale:.1];
    PFFile *thumbnailFile = [PFFile fileWithData:UIImagePNGRepresentation(thumbnailImage)];

    [thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [PFUser currentUser][@"thumbnailImage"] = thumbnailFile;
        [[PFUser currentUser] saveEventually];
    }];

}
@end
