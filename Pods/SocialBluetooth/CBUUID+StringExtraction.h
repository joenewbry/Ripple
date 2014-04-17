//
//  CBUUID+StringExtraction.h
//  Blink
//
//  Created by Joe Newbry on 2/28/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBUUID (StringExtraction)

- (NSString *)representativeString;

@end
