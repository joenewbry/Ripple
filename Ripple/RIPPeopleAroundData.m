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
    [SBUserDiscovery currentUserDiscovery].delegate = self;
    [[SBUserDiscovery currentUserDiscovery] searchForUsers];

}


#pragma mark - swipe view data source
- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return [self.peopleAround count] + 2;

    // todo create singleton instance with that
    // responds to count, image, name requests
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UIButton *personButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
    personButton.tag = index;
    personButton.clipsToBounds = true;

    // todo add protocol to get rid of warning messages
    if (index == 0) {
        [personButton setImage:[UIImage imageNamed:@"plus@2x"] forState:UIControlStateNormal];
        [personButton addTarget:self.delegate action:@selector(didPressInvite:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if (index == 1) {
        [personButton setImage:[UIImage imageNamed:@"user"] forState:UIControlStateNormal];
        // TODO: fectch real profile image and save as PFFile to parse
        [personButton addTarget:self.delegate action:@selector(didPressProfile:) forControlEvents:UIControlEventTouchUpInside];

    } else
    {
        [personButton setImage:[UIImage imageNamed:@"user"] forState:UIControlStateNormal];
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

- (void)userDidConnectWithobjectId:(NSString *)objectId
{
    if (![self.discoveredUserObjectIds containsObject:objectId]) {
        PFQuery *queryForUser = [PFQuery queryWithClassName:@"_User"];
        [queryForUser whereKey:@"objectId" equalTo:objectId];
        [queryForUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [self.peopleAround addObject:objects[0]];
            // adjust for 2 additional slots, invite, and your profile, and count overstepping index by 1
            // +2 -1 = 1
            [self.swipeView reloadItemAtIndex:[self.peopleAround count] + 1];
        }];
    }
}

@end
