//
//  RIPFacesById.m
//  Ripple
//
//  Created by Joe Newbry on 4/16/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "RIPFacesById.h"

@implementation RIPFacesById

static RIPFacesById *instance = nil;
+ (RIPFacesById *)instance
{
    @synchronized(self) {
        if (instance == nil) instance = [[RIPFacesById alloc] init];
    }
    return instance;
}

- (void)setFaceImg:(UIImage *)UIImage forUserId:(NSString *)userId
{
    [self setObject:UIImage forKey:userId];
}

- (UIImage *)getFaceImgForUserId:(NSString *)userId
{
    return [self objectForKey:userId];
}

@end
