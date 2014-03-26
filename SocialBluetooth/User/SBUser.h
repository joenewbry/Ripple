//
//  SBUser.h
//  Blink
//
//  Created by Joe Newbry on 2/11/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SBUser : NSObject {
}

@property (nonatomic, strong) NSString *objectId;

// class methods to create user and get currentUser
+ (SBUser *)createUserWithObjectId:(NSString *)objectId;
+ (SBUser *)currentUser;
+ (SBUser *)createUser;

// SBUser sharing controls
//- (void)shareProfile;
//- (void)shareProfileWithLaunchOptions:(NSDictionary *)launchOptions broadcastInBackground:(BOOL)shouldBroadcast;
//- (void)shareUUID;
//- (void)shareUUIDWithLaunchOptions:(NSDictionary *)launchOptions broadcastInBackground:(BOOL)shouldBoradcast;
//- (void)stopShareProfile;
//- (void)logout;

@end
