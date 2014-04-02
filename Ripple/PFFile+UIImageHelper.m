//
//  PFFile+UIImageHelper.m
//  Ripple
//
//  Created by Joe Newbry on 3/26/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "PFFile+UIImageHelper.h"

@implementation PFFile (UIImageHelper)

- (UIImage *)imageFromFileWithPlaceholderImage:(UIImage *)placeholder
{
    UIImage __block *img = placeholder;
    [self getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        img = [UIImage imageWithData:data];
    }];
    return img;
}

@end
