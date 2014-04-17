//
//  SBUserBroadcast.h
//  Blink
//
//  Created by Joe Newbry on 2/12/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString  * const SBBroadcastPeripheralUserProfileUUID;
extern NSString  * const SBBroadcastServiceUserProfileUUID;
extern NSString  * const SBBroadcastCharacteristicUserProfileObjectId;

@interface SBUserBroadcast : NSObject

/**
 Creates a peripheral that is used to broadcast your user id
 
 @param The launchOption dictionary that is provided by iOS when the application launches

 @discussion This creates the peripheral that will broadcast your user id. You must pass in the launchOptions dictionary to support broadcasting when your application is minized. 
 
 @return Returns the SBUserBroadcast used to send a unique user id
 
 *** Specific Implementation Details *** 
 Pass in the launchOptions parameter from the following method called on application launch:
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 */

+ (SBUserBroadcast *)createPeripheralWithLaunchOptions:(NSDictionary *)launchOptions;


/**
Returns the currently created SBUserBroadcast

 @discussion This return the singleton SBUserBroadcast that you create with

 @return Returns the SBUserBroadcast user broadcast. If nil check to make sure the following method is being called:
 + (SBUserBroadcast *)createPeripheralWithLaunchOptions:(NSDictionary *)launchOptions;
 
 @see + (SBUserBroadcast *)createPeripheralWithLaunchOptions:(NSDictionary *)launchOptions

 */
+ (SBUserBroadcast *)currentBroadcast;

/**
 
 Sets the unique identifier for this specific user

 @discussion Each user must have a unique identifier to get the users associated data. This method must be called before calling addServices or startBroadcast.
 
 @see addServices, startBroadcast

*/
- (void)setUniqueIdentifier:(NSString *)UUID;

/**
 
 Adds the unique identifier broadcast service
 
 @discussion Adds the unique identifier broadcast service to the peripheral manager. This will continue broadcast the user identifier until the endBroadcast method is called
 
 */
- (void)addServices;

/**
 
 Start sharing your user id with nearby iPhones
 
 @discussion Start sharing your user id with nearby iPhones. Once this method is called the user id set will be broadcasted until you call endBroadcast
 */
- (void)startBroadcast;

/**
 
 Stop sharing your user id.
 
 @discussion Stop sharing your user id. Once this is called no one will be able to discover the specific user id. A good way to ensure that user privacy is maintained if a user logs out of the application.
 */
- (void)endBroadcast;

@end

