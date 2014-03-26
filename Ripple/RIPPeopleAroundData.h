//
//  RIPPeopleAroundDataModel.h
//  Ripple
//
//  Created by Joe Newbry on 3/25/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RIPPerson.h"
#import <SwipeView/SwipeView.h>
#import "RIPGroupChatViewController.h"


@interface RIPPeopleAroundData : NSObject <SwipeViewDataSource>

+ (RIPPeopleAroundData *)instance;

@property (nonatomic, weak) RIPGroupChatViewController *delegate;
@property (nonatomic, weak) SwipeView *swipeView;

- (void)startSearchForNearbyPeople;

@end

