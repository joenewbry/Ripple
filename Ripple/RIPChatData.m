//
//  RIPChatData.m
//  Ripple
//
//  Created by Joe Newbry on 4/2/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "RIPChatData.h"
#import "RIPPeopleAroundData.h"
#import <Parse/Parse.h>
#import "RIPFacesById.h"
#import <JSAvatarImageFactory.h>

@interface RIPChatData ()

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSMutableArray *chatMessages;

@end

@implementation RIPChatData

// set up static data source
static RIPChatData *instance = nil;

+ (RIPChatData *)createInstanceWithUserId:(NSString *)userId
{
    @synchronized(self) {
        if (instance == nil) instance = [[RIPChatData alloc] initWithUserId:userId];
    }
    return instance;
}

+ (RIPChatData *)currentInstance {
    @synchronized(self) {
        //if (instance == nil) instance = [[RIPChatData alloc] init];
    }
    return instance;
}


- (id)initWithUserId:(NSString *)userId
{
    if (self = [super init]){
        _userId = userId;
        _chatMessages = [NSMutableArray new];

#warning not sure if I can start async request here
        [self lookForMessages];
    }
    return self;
}

- (void)lookForMessages
{
    PFUser *user = [PFUser currentUser];
    PFRelation *messages = [user relationForKey:@"messages"];
    PFQuery *query = [messages query];
    query.limit = 20;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error fetching messages");
        } else {
            // object has all the messages
            [self.chatMessages addObjectsFromArray:objects];
            [self reloadMessages];

            // get images for the chatters
            for (PFObject *message in self.chatMessages) {
                PFQuery *query = [PFUser query];
                [query whereKey:@"objectId" equalTo:message[@"senderUserId"]];

                // get image data and store it in image chache
                [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if (!error) {
                        PFFile *imgFile = object[@"profilePicture"];
                        [imgFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                            UIImage *profileImg = [UIImage imageWithData:data];
                            [[RIPFacesById instance] setFaceImg:profileImg forUserId:object.objectId];
                        }];
                    }
                }];
            }
        }
    }];
}

- (void)addMessage:(id)message
{
    [self.chatMessages addObject:message];
    [self reloadMessages];
}

- (NSInteger)messageCount
{
    return [self.chatMessages count];
}

- (JSMessage *)messageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[JSMessage alloc] initWithText:self.chatMessages[indexPath.row][@"message"] sender:self.chatMessages[indexPath.row][@"senderName"] date:self.chatMessages[indexPath.row][@"createdAt"]];
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender
{
    UIImage *img = [[RIPPeopleAroundData instance] profileImageForUserId:self.chatMessages[indexPath.row][@"senderUserId"]];
    UIImage* imgCropped = [JSAvatarImageFactory avatarImage:img croppedToCircle:YES];

    UIImageView *imgView = [[UIImageView alloc] initWithImage:imgCropped];
    return imgView;
}

- (BOOL)isSenderSelfForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *senderName = self.chatMessages[indexPath.row][@"senderName"];
    NSString *userName = [PFUser currentUser][@"username"];
    return [senderName isEqualToString:userName];
}

#pragma mark - Helper methods
- (void)reloadMessages
{
    if ([self.delegate respondsToSelector:@selector(newMessageReceived)]){
        [self.delegate newMessageReceived]; // makes view controller, tell
        // this class to reload data
    }
}

@end
