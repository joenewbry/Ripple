//
//  RIPPeopleAroundDataModel.m
//  Ripple
//
//  Created by Joe Newbry on 3/25/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "RIPPeopleAroundData.h"
#import <Parse/Parse.h>
#import "SBUserDiscovery.h"
#import "RIPSaveImage.h"
#import "PFFile+UIImageHelper.h"
#import "RIPFacesById.h"

@interface RIPPeopleAroundData () <SBUserDiscoveryDelegate>

@property (nonatomic, strong) NSMutableArray *peopleAroundImages;
@property (nonatomic, strong) NSMutableSet *discoveredUserObjectIds;
@property (nonatomic, strong) NSMutableArray *peopleAround;

@end

@implementation RIPPeopleAroundData

static RIPPeopleAroundData *instance = nil;
+ (RIPPeopleAroundData *)instance {
    @synchronized(self) {
        if (instance == nil) instance = [[RIPPeopleAroundData alloc] init];
    }
    return instance;
}

#pragma marks - getters

- (NSMutableArray *)peopleAround
{
    if (!_peopleAround) _peopleAround = [NSMutableArray new];
    return _peopleAround;
}

- (NSMutableSet *)discoveredUserObjectIds
{
    if (!_discoveredUserObjectIds) _discoveredUserObjectIds = [NSMutableSet new];
    return _discoveredUserObjectIds;
}

- (NSMutableArray *)peopleAroundImages
{
    if (!_peopleAroundImages) _peopleAroundImages = [NSMutableArray new];
    return _peopleAroundImages;
}

// start searching for users
- (id)init
{
    if (self = [super init]) {
        _peopleAroundImages = [NSMutableArray new];
        _discoveredUserObjectIds = [NSMutableSet new];
        _peopleAround = [NSMutableArray new];
    }
    return self;
}

- (void)startSearchForNearbyPeople
{
    // start search for people around you
    [SBUserDiscovery createUserDiscovery];
    [SBUserDiscovery currentUserDiscovery].delegate = self;
    [[SBUserDiscovery currentUserDiscovery] searchForUsers];

}


#pragma mark - swipe view data source
- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    // for first and last item
    return [self.peopleAroundImages count] + 2;

    // todo create singleton instance with that
    // responds to count, image, name requests
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UIButton *personButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
    personButton.tag = index;
    personButton.clipsToBounds = true;

    // todo add protocol to get rid of warning messages
//    if (index == 0) {
//        [personButton setImage:[UIImage imageNamed:@"plus@2x"] forState:UIControlStateNormal];
//        [personButton addTarget:self.delegate action:@selector(didPressInvite:) forControlEvents:UIControlEventTouchUpInside];
//    }
    if (index == 0) {

        //PFFile *profileImage = [PFUser currentUser][@"profilePicture"];
        //NSData *imgData = [profileImage getData];

        if (![[RIPFacesById instance] getFaceImgForUserId:[PFUser currentUser].objectId]) {
            PFFile *profileImg = [PFUser currentUser][@"profilePicture"];
            [profileImg getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                [[RIPFacesById instance] setFaceImg:[UIImage imageWithData:data] forUserId:[PFUser currentUser].objectId];
                [self.delegate reloadSwipeViewIndex:index];
            }];
        }
        UIImage *profileImage = [[RIPFacesById instance] getFaceImgForUserId:[PFUser currentUser].objectId];
        //[profileImage imageFromFileWithPlaceholderImage:[UIImage imageNamed:@"user"]];
        [personButton setImage:profileImage forState:UIControlStateNormal];

        [personButton addTarget:self.delegate action:@selector(didPressProfile:) forControlEvents:UIControlEventTouchUpInside];

    }

    // todo, make sure race conditions are avoided on data check
    else if (index == [self.peopleAroundImages count] + 1)
    {
        [personButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
        [personButton addTarget:self.delegate action:@selector(didPressAdd:) forControlEvents:UIControlEventTouchUpInside];
    }

    else
    {
        [personButton setImage:[self.peopleAroundImages objectAtIndex:index-1] forState:UIControlStateNormal];
        [personButton addTarget:self.delegate action:@selector(didPressPerson:) forControlEvents:UIControlEventTouchUpInside];
    }

    personButton.layer.cornerRadius = 25;
    personButton.layer.borderWidth = 1;
    [personButton.layer setBorderColor:[UIColor colorWithRed:59/255.0 green:137.0/255.0 blue:233.0/255.0 alpha:1.0].CGColor];
    personButton.backgroundColor = [UIColor whiteColor];

    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [containerView addSubview:personButton];
    return containerView;
}


#pragma mark - SBUserConnection Delegate

- (void)didReceiveUserID:(NSString *)userID
{
    NSLog(@"Got user ID: %@", userID);
    if (![self.discoveredUserObjectIds containsObject:userID]) {
        [self.discoveredUserObjectIds addObject:userID]; // store so we don't make a second request
        PFQuery *queryForUser = [PFQuery queryWithClassName:@"_User"];
        [queryForUser whereKey:@"objectId" equalTo:userID];
        [queryForUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            // need to make sure it's a valid request
            if (objects && [objects count] > 0) {
                NSLog(@"Found nearby user");
                PFUser *discoveredUser = objects[0];
                [self.peopleAround addObject:discoveredUser];
                PFFile *thumbnailFile = discoveredUser[@"profilePicture"];
                [thumbnailFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    NSLog(@"Found face for user");
                    UIImage *img = [UIImage imageWithData:data];
                    [self.peopleAroundImages addObject:img];
                    [[RIPFacesById instance] setFaceImg:img forUserId:userID];
                    [self.swipeView reloadData];
                }];
            } 
        }];
    }
}

#pragma mark - external interface
- (NSArray *)peopleNearbyIds
{
    return [self.discoveredUserObjectIds allObjects];
}

- (NSArray *)peopleNearby
{
    return self.peopleAround;
}

- (UIImage *)profileImageForUserId:(NSString *)userId
{
    return [[RIPFacesById instance] getFaceImgForUserId:userId];
}

- (void)logOut
{
    self.peopleAround = nil;
    self.peopleAroundImages = nil;
    self.discoveredUserObjectIds = nil;
}

@end
