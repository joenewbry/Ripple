//
//  PFFile+UIImageHelper.h
//  Ripple
//
//  Created by Joe Newbry on 3/26/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFFile (UIImageHelper)

- (UIImage *)imageFromFileWithPlaceholderImage:(UIImage *)placeholder;

@end
