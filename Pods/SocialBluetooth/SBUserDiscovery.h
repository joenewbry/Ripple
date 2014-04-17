//
//  SBUserDiscovery.h
//  Blink
//
//  Created by Joe Newbry on 2/12/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SBUserDiscoveryDelegate

@optional

/**
 
 Implement to recieve the user id of nearby users
 
 */
- (void)didReceiveUserID:(NSString *)userID;

#warning not implemented
/** 
 
 Impletement to recieve user id of user moving out of range or stoping broadcasting.
 
 @discussion Impletement to recieve user id of user moving out of range or stoping broadcasting. Use to ensure that user privacy is maintained if someone wants to log out.
 */
- (void)userDidDisconnectWithId:(NSString *)userId;

@end

@interface SBUserDiscovery : NSObject

/**
 
 Create SBUserDiscovery singleton that is used to discover nearby users
 
 @discussion This is where the magic happens. Make sure to create user discovery when the application is open to find nearby users.
 
 */
+ (SBUserDiscovery *)createUserDiscovery;

/**
 
 Return the SBUserDiscovery object used to discover nearby users.
 
 @discussion Use this to call methods on the SBUserDiscovery singleton.

 @see searchForUsers, stopSearchingForUsers
 */
+ (SBUserDiscovery *)currentUserDiscovery;


/** 
 
 Search for nearby users.
 
 @discussion Once you've created your SBUserDiscovery object make sure to implement the SBUserDiscoveryDelegate and then call searchFor Users
 
 @see searchForUsers
 */
- (void)searchForUsers;

/**
 
 Stop search for nearby users.
 */
- (void)stopSearchForUsers;

/**
 Set the delegate to recieve notifications when a new user is found and when a user goes out of range.
 
 @discussion Impement the SBUserDiscoveryDelegate to get notifications when a new user id is found or when a user disconnects.
 */

@property (nonatomic, weak) id <SBUserDiscoveryDelegate, NSObject> delegate;


@end


