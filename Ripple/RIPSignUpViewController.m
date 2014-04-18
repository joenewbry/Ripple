//
//  RIPSignUpViewController.m
//  Ripple
//
//  Created by Joe Newbry on 3/24/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "RIPSignUpViewController.h"
#import <Parse/Parse.h>
#import "RIPGroupChatViewController.h"
#import "RIPProfileViewController.h"
#import "RIPSaveImage.h"
#import "SBUserBroadcast.h"
#import <FUIButton.h> // buttons
#import <UIFont+FlatUI.h> // custom font
#import <FlatUIKit/UIColor+FlatUI.h> // flat colors
#import "RIPConstants.h"

@interface RIPSignUpViewController ()

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet FUIButton *joinUsButton;
@property (strong, nonatomic) IBOutlet FUIButton *signInButton;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

// store user profile image from facebook
@property (nonatomic, strong) NSMutableData *imgData;
@property (nonatomic, strong) NSURLConnection *URLConnection;
@property (nonatomic, strong) UIImage *imgRef;


@end

@implementation RIPSignUpViewController

#warning display errors on login and signup to user
#warning provide password reset option

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.titleLabel setFont:[UIFont fontWithName:@"ComicNeue-Light" size:60]];
    [self.titleLabel setText:@"TweetDar"];

    // animate drawing of text
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 10.0;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    [self.titleLabel.layer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];

    self.joinUsButton.buttonColor = [UIColor peterRiverColor];
    [self.joinUsButton setBackgroundColor:[UIColor peterRiverColor]];
    self.joinUsButton.shadowColor = [UIColor belizeHoleColor];
    self.joinUsButton.shadowHeight = 3.0f;
    self.joinUsButton.cornerRadius = 6.0f;
    self.joinUsButton.titleLabel.font = [UIFont fontWithName:@"ComicNeue-Bold" size:20];
    [self.joinUsButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.joinUsButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateSelected];

    self.signInButton.buttonColor = [UIColor concreteColor];
    [self.signInButton setBackgroundColor:[UIColor concreteColor]];
    self.signInButton.shadowColor = [UIColor asbestosColor];
    self.signInButton.shadowHeight = 3.0f;
    self.signInButton.cornerRadius = 6.0f;
    self.signInButton.titleLabel.font = [UIFont fontWithName:@"ComicNeue-Bold" size:20];
    [self.signInButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.signInButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateSelected];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - target action
- (IBAction)didPressJoinUs:(id)sender {

    [self checkUsernameAndPassword];
    // good to go, so create parse user and move to profile view
    [self signUp];
}
- (IBAction)didPressSignIn:(id)sender {
    [self checkUsernameAndPassword];

    [self signIn];

}

- (void)signUp
{
    PFUser *newUser = [PFUser user];
    newUser.username = self.usernameTextField.text;
    newUser.password = self.passwordTextField.text;

    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self startBluetooth:newUser];
            [self registerUserToPFInstallationForPush:newUser];

            // present profile view with home view as root view in view controller
            RIPGroupChatViewController *groupChatVC = [[RIPGroupChatViewController alloc] initFromSignUp];
            NSLog(@"Chat View Created");
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:groupChatVC];

            [self presentViewController:navController animated:YES completion:nil];

        }

    }];
}

- (void)signIn
{
    [PFUser logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {
        if (!error) {
            [self startBluetooth:[PFUser currentUser]];
            [self registerUserToPFInstallationForPush];

            RIPGroupChatViewController *groupChatVC = [RIPGroupChatViewController new];

            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:groupChatVC];
            [self presentViewController:navController animated:NO completion:nil];
        }
        
    }];
}

- (void)startBluetooth:(PFUser *)newUser
{
    // we've create a new user

    // fire up user broadcast using social bluetooth framework
    // once logged in set information to be broadcasted
    [SBUserBroadcast createPeripheralWithLaunchOptions:nil];
    [[SBUserBroadcast currentBroadcast] setUniqueIdentifier:newUser.objectId];
    [[SBUserBroadcast currentBroadcast] addServices];
    [[SBUserBroadcast currentBroadcast] startBroadcast];
}

- (void)registerUserToPFInstallationForPush:(PFUser *)newUser
{
    NSString *privateChannelName = [NSString stringWithFormat:@"user_%@", newUser.objectId];
    [[PFInstallation currentInstallation] setObject:newUser  forKey:kInstallationUserKey];
    [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:kInstallationChannelsKey];
    [[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) NSLog(@"Error for PFINstallation is: %@", [error localizedDescription]);
        NSLog(@"Installation is");
    }];
    [newUser setObject:privateChannelName forKey:kUserPrivateChannelKey];
    [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) NSLog(@"Error saving user is: %@", [error localizedDescription]);
        NSLog(@"private channel for user saved");
    }];
}

- (void)checkUsernameAndPassword
{
    // no username let the user know to input a user name
    if ([self.usernameTextField.text length] == 0) {
        [self.usernameTextField setPlaceholder:@">> Username <<"];
        return;
    }
    // no password. let user know to input password
    else if ([self.passwordTextField.text length] == 0) {
        [self.passwordTextField setPlaceholder:@">> Password <<"];
        return;
    }
}

@end
