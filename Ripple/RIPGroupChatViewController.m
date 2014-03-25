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
        peopleAround.pagingEnabled = true;
        peopleAround.wrapEnabled = false;
        peopleAround.bounces = true;
        peopleAround.dataSource = self;
        peopleAround.delegate = self;
        [self.view addSubview:peopleAround];
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

    [self setTitle:@"Ripple"];
    self.sender = @"Joe Newbry";

    UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(didPressSettings:)];

    self.navigationItem.rightBarButtonItem = settingsItem;
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


#pragma mark - swipe view data source
- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return 10;

    // todo create singleton instance with that
    // responds to count, image, name requests
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UIButton *personButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
    personButton.tag = index;
    [personButton setImage:[UIImage imageNamed:@"plus@2x"] forState:UIControlStateNormal];

    personButton.layer.cornerRadius = 25;
    personButton.layer.borderWidth = 1;
    [personButton.layer setBorderColor:[UIColor colorWithRed:59/255.0 green:137.0/255.0 blue:233.0/255.0 alpha:1.0].CGColor];
    [personButton addTarget:self action:@selector(didSelectPerson:) forControlEvents:UIControlEventTouchUpInside];

    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [containerView addSubview:personButton];
    return containerView;
}

#pragma mark - target action

- (void)didSelectPerson:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *selectedButton = (UIButton *)sender;
        NSLog(@"Selected index for button is %ld", (long)selectedButton.tag);

        if (selectedButton.tag == 0) {

            //self.navigationController pushViewController:<#(UIViewController *)#> animated:<#(BOOL)#>
        }
    }


}

- (void)didPressSettings:(id)sender
{
    RIPSettingsViewController *settingsVC = [[RIPSettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

@end
