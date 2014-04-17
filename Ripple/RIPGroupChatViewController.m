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

#import <Parse/Parse.h>
#import "RIPPeopleAroundData.h"
#import "RIPProfileViewController.h"

#import "SBUserBroadcast.h"
#import "RIPChatData.h"

@interface RIPGroupChatViewController () <SwipeViewDelegate, JSMessagesViewDelegate, JSMessagesViewDataSource, RIPChatDataDelegate>

@property (nonatomic, strong) SwipeView *peopleAround;

@end

@implementation RIPGroupChatViewController

@synthesize peopleAround;

- (id)init
{
    if (self = [super init]){

        // display people around you
        peopleAround = [[SwipeView alloc] initWithFrame:CGRectMake(0 , 64, 320, 60)];
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
        peopleAround.dataSource = [RIPPeopleAroundData instance];
        [[RIPPeopleAroundData instance] startSearchForNearbyPeople];
        [RIPPeopleAroundData instance].swipeView = peopleAround;

        // fire up chat data source
        [RIPChatData createInstanceWithUserId:[PFUser currentUser].objectId];
        [RIPChatData currentInstance].delegate = self;
    }
    return self;
}

BOOL fromSignUp;
- (id)initFromSignUp
{
    fromSignUp = true;
    return [self init];
}

- (void)viewDidLoad
{
    self.delegate = self;
    self.dataSource = self;

    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // make sure that datasource and delegate stuff is set up


    // setup chat
    [[JSBubbleView appearance] setFont:[UIFont fontWithName:@"Avenir-medium" size:16]];
    self.messageInputView.textView.placeHolder = @"Send Message Nearby Ripplers";
    self.messageInputView.backgroundColor = [UIColor colorWithRed:59/255.0 green:137.0/255.0 blue:233.0/255.0 alpha:1.0];

    [self setTitle:@"Ripple"];
    self.sender = [PFUser currentUser][@"username"];

    UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(didPressSettings:)];

    self.navigationItem.rightBarButtonItem = settingsItem;

    [self setBackgroundColor:[UIColor whiteColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // reload nearby people and profile to update if new people are discovered
    // or if user updated profile
    [peopleAround reloadData];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    // transition to profile view
    if (fromSignUp) {
        fromSignUp = false;
        [self didPressProfile:self];

    }
}


#pragma mark - chat delegate : REQUIRED
- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date
{
    [JSMessageSoundEffect playMessageSentSound];
    [self finishSend];
    [self scrollToBottomAnimated:YES];


    // save message in background
    PFObject *message = [PFObject objectWithClassName:@"Message"];
    message[@"message"] = text;
    message[@"sender"] = [PFUser currentUser];
    message[@"senderName"]  = sender;
    message[@"senderUserId"] = [PFUser currentUser].objectId;
    message[@"recipients"] = [[RIPPeopleAroundData instance] peopleNearbyIds];
    [[RIPChatData currentInstance] addMessage:message];

    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // create relation from user to message in background
            PFUser *user = [PFUser currentUser];
            PFRelation *relation = [user relationForKey:@"messages"];
            [relation addObject:message];
            [user saveInBackground];
        }
    }];

    // add message to list of messages
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ([[RIPChatData currentInstance] isSenderSelfForRowAtIndexPath:indexPath]) {
        return JSBubbleMessageTypeOutgoing;
    }

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

#pragma mark - chat data source : REQUIRED

// TODO MAKE IS SO THIS GETS CALLED ON RELOAD
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[RIPChatData currentInstance] messageCount];
}

- (JSMessage *)messageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[RIPChatData currentInstance] messageForRowAtIndexPath:indexPath];
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender
{
    return [[RIPChatData currentInstance] avatarImageViewForRowAtIndexPath:indexPath sender:sender];
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

#pragma mark - Chat Data Source Delegate
- (void)newMessageReceived
{
    [self.tableView reloadData];
}

#pragma mark - target action

- (void)didPressPerson:(id)sender
{
    
}

- (void)didPressAdd:(id)sender
{
    RIPInviteContactsTableViewController *inviteVC = [[RIPInviteContactsTableViewController alloc] init];
    [self.navigationController pushViewController:inviteVC animated:YES];
}

- (void)didPressProfile:(id)sender
{
    RIPProfileViewController *myProfileVC = [[RIPProfileViewController alloc] initWithNibName:@"Profile" bundle:[NSBundle mainBundle]];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:myProfileVC];

    [self presentViewController:navController animated:YES completion:nil];
}

- (void)didPressSettings:(id)sender
{
    RIPSettingsViewController *settingsVC = [[RIPSettingsViewController alloc] initWithNibName:@"Settings" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:settingsVC animated:NO];
}

@end
