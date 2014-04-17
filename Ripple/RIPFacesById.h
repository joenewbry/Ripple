//
//  RIPFacesById.h
//  Ripple
//
//  Created by Joe Newbry on 4/16/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIPFacesById : NSCache

+ (RIPFacesById *)instance;

- (void)setFaceImg:(UIImage *)UIImage forUserId:(NSString*)userId;
- (UIImage *)getFaceImgForUserId:(NSString *)userId;

@end
