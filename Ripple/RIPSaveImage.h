//
//  BLKSaveImage.h
//  Blink
//
//  Created by Joe Newbry on 2/25/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIPSaveImage : NSObject <NSURLConnectionDelegate>

+ (RIPSaveImage *)instanceSavedImage;
- (void)saveImageInBackground:(NSURL *)url;
- (void)saveImageInBackground:(NSURL *)url toImage:(UIImage *)image;

@end

BOOL isSaved;
