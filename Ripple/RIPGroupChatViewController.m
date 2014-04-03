//
//  RIPGroupChatViewController.m
//  Ripple
//
//  Created by Joe Newbry on 3/24/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "RIPGroupChatViewController.h"
#import "RIPSettingsViewController.h"
#import <SwipeView/SwipeView.h>
#import <JSMessage.h>
#import "RIPInviteContactsTableViewController.h"
#import "SBUser.h"
#import "SBUserBroadcast.h"

#import <Parse/Parse.h>
#import "RIPPeopleAroundData.h"
#import "RIPProfileViewController.h"

@interface RIPGroupChatViewController () <SwipeViewDataSource, SwipeViewDelegate, JSMessagesViewDataSource, JSMessagesViewDelegate>

@end

@implementation RIPGroupChatViewController

- (id)init
{
    if (self = [super init]){

        // display people around you
        SwipeView *peopleAround = [[SwipeView alloc] initWithFrame:CGRectMake(0 , 64, 320, 60)];
        peopleAround.backgroundColor = [UIColor clearColor];
        peopleAround.itemsPerPage = 5;
        peopleAround.truncateFinalPage = false;
        [peopleAround setAlignment:SwipeViewAlignmentEdge];
        peopleAround.pagingEnabled = false;
        peopleAround.wrapEnabled = false;
        peopleAround.bounces = true;
        peopleAround.dataSource = [RIPPeopleAroundData instance];
        peopleAround.delegate = self;
        [self.view addSubview:peopleAround];

        // fire up datasource that looks for nearby people using Social Bluetooth framework
        [RIPPeopleAroundData instance].delegate = self;
        [[RIPPeopleAroundData instance] startSearchForNearbyPeople];
        [RIPPeopleAroundData instance].swipeView = peopleAround;

        // fire up user broadcast using social bluetooth framework
        // once logged in set information to be broadcasted
        [SBUser createUserWithObjectId:[PFUser currentUser].objectId];
        [[SBUserBroadcast currentUserBroadcast] peripheralAddUserProfileService];

    }
    return self;
}

- (void)viewDidLoad
{
    // allows chat with users
    self.dataSource = self;
    self.delegate = self;

    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // setup chat
    [[JSBubbleView appearance] setFont:[UIFont fontWithName:@"Avenir-medium" size:16]];
    self.messageInputView.textView.placeHolder = @"Send Message Nearby Ripplers";
    self.messageInputView.backgroundColor = [UIColor colorWithRed:59/255.0 green:137.0/255.0 blue:233.0/255.0 alpha:1.0];

    [self setTitle:@"Ripple"];
    self.sender = @"Joe Newbry";

    UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(didPressSettings:)];

    self.navigationItem.rightBarButtonItem = settingsItem;

    [self setBackgroundColor:[UIColor whiteColor]];
}

#pragma mark - chat data source : REQUIRED

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (JSMessage *)messageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[JSMessage alloc] initWithText:@"Hi I'm Joe" sender:@"Chad" date:[NSDate distantPast]];
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender
{
    return nil;
}


#pragma mark - chat delegate : REQUIRED
- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date
{
    [JSMessageSoundEffect playMessageSentSound];

    [self finishSend];

    [self scrollToBottomAnimated:YES];

    // add message to list of messages
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{

    // add class that will say what type of message it is
    return JSBubbleMessageTypeIncoming;
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type forRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleLightGrayColor]];
}

-(JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}


#pragma mark - chat delegate : OPTIONAL
- (void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell messageType] == JSBubbleMessageTypeOutgoing) {
        cell.bubbleView.textView.textColor = [UIColor whiteColor];

        if ([cell.bubbleView.textView respondsToSelector:@selector(linkTextAttributes)]) {
            NSMutableDictionary *attrs = [cell.bubbleView.textView.linkTextAttributes mutableCopy];
            [attrs setValue:[UIColor blueColor] forKey:NSForegroundColorAttributeName];

            cell.bubbleView.textView.linkTextAttributes = attrs;
        }
    }

    if (cell.timestampLabel) {
        cell.timestampLabel.textColor = [UIColor lightGrayColor];
        cell.timestampLabel.shadowOffset = CGSizeZero;
    }

    if (cell.subtitleLabel) {
        cell.subtitleLabel.textColor = [UIColor lightGrayColor];
    }

    if (TARGET_IPHONE_SIMULATOR) {
        cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeNone;
    } else {
        cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeAll;
    }
}

- (BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}

- (BOOL)allowsPanToDismissKeyboard
{
    return YES;
}

#pragma mark - target action

- (void)didPressPerson:(id)sender
{
    
}

- (void)didPressInvite:(id)sender
{
    RIPInviteContactsTableViewController *inviteVC = [[RIPInviteContactsTableViewController alloc] init];
    [self.navigationController pushViewController:inviteVC animated:YES];
}

- (void)didPressProfile:(id)sender
{
    RIPProfileViewController *myProfileVC = [[RIPProfileViewController alloc] init];
    [self.navigationController pushViewController:myProfileVC animated:NO];
}

- (void)didPressSettings:(id)sender
{
    RIPSettingsViewController *settingsVC = [[RIPSettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsVC animated:NO];
}

@end
