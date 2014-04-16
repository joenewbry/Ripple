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

@interface RIPPeopleAroundData () <SBUserDiscoveryDelegate>

@property (nonatomic, strong) NSMutableArray *peopleAround;
@property (nonatomic, strong) NSMutableSet *discoveredUserObjectIds;

@end

@implementation RIPPeopleAroundData

static RIPPeopleAroundData *instance = nil;
+ (RIPPeopleAroundData *)instance {
    @synchronized(self) {
        if (instance == nil) instance = [[RIPPeopleAroundData alloc] init];
    }
    return instance;
}

// start searching for users
- (id)init
{
    if (self = [super init]) {
        _peopleAround = [NSMutableArray new];
        _discoveredUserObjectIds = [NSMutableSet new];
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
    return [self.peopleAround count] + 1;

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

        PFFile *profileImage = [PFUser currentUser][@"profilePicture"];
        NSData *imgData = [profileImage getData];

        //[profileImage imageFromFileWithPlaceholderImage:[UIImage imageNamed:@"user"]];
        [personButton setImage:[UIImage imageWithData:imgData] forState:UIControlStateNormal];

        [personButton addTarget:self.delegate action:@selector(didPressProfile:) forControlEvents:UIControlEventTouchUpInside];

    } else
    {
        [personButton setImage:[self.peopleAround objectAtIndex:index-1] forState:UIControlStateNormal];
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
    if (![self.discoveredUserObjectIds containsObject:userID]) {
        [self.discoveredUserObjectIds addObject:userID]; // store so we don't make a second request
        PFQuery *queryForUser = [PFQuery queryWithClassName:@"_User"];
        [queryForUser whereKey:@"objectId" equalTo:userID];
        [queryForUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            // need to make sure it's a valid request
            if (objects && [objects count] > 0) {
                PFUser *discoveredUser = objects[0];
                PFFile *thumbnailFile = discoveredUser[@"profilePicture"];
                [thumbnailFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    [self.peopleAround addObject:[UIImage imageWithData:data]];
                    // adjust for 1 additional slot, your profile, and count overstepping index by 1
                    // +1 -1 = 0
                    [self.swipeView reloadData];
                    NSLog(@"Swipe view should have another person");
                    //[self.swipeView reloadItemAtIndex:[self.peopleAround count]];
                }];
            } 
        }];
    }
}

@end
