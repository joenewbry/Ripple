//
//  UIFont+FontLookup.m
//  Ripple
//
//  Created by Joe Newbry on 4/9/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "UIFont+FontLookup.h"

@implementation UIFont (FontLookup)

+ (void)logAllFonts
{
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);

        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
}
@end
