//
//  SBUserDiscovery.h
//  Blink
//
//  Created by Joe Newbry on 2/12/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBUser.h"

@protocol SBUserDiscoveryDelegate

@optional
- (void)didReceiveObjectID:(NSString *)objectID;
- (void)didReceiveUserName:(NSString *)userName;
- (void)didReceiveQuote:(NSString *)quote;
- (void)didReceiveStatus:(NSString *)status;
- (void)didReceiveProfileImage:(UIImage *)profileImage;
- (void)didReceiveSBUser:(SBUser *)sbUser;

// TODO get disconnect working
- (void)userDidDisconnectWithObjectId:(NSString *)userId;

@end

@interface SBUserDiscovery : NSObject

+ (SBUserDiscovery *)createUserDiscovery;

// TODO, not currently handled but used for long term searching for users
+ (SBUserDiscovery *)createUserDiscoveryWithLaunchOptions:(NSDictionary *)launchOptions;
+ (SBUserDiscovery *)currentUserDiscovery;

- (void)searchForUsers;
- (void)stopSearchForUsers;

@property (nonatomic, weak) id <SBUserDiscoveryDelegate, NSObject> delegate;


@end


