//
//  RIPChatData.h
//  Ripple
//
//  Created by Joe Newbry on 4/2/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSMessage.h>
#import <JSMessagesViewController.h>
#import <Parse/Parse.h>

@protocol RIPChatDataDelegate <NSObject>

- (void)newMessageReceived;

@end

@interface RIPChatData : NSObject 

@property (nonatomic, weak)id <RIPChatDataDelegate, NSObject> delegate;

+ (RIPChatData *)createInstanceWithUserId:(NSString *)userId;
+ (RIPChatData *)currentInstance;

- (void)addMessage:(PFObject *)message;

- (NSInteger)messageCount;
- (JSMessage *)messageForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender;
- (BOOL)isSenderSelfForRowAtIndexPath:(NSIndexPath *)indexPath;

@end