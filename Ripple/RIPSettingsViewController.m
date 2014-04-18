//
//  RIPSettingsViewController.m
//  Ripple
//
//  Created by Joe Newbry on 3/24/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "RIPSettingsViewController.h"
#import <Parse/Parse.h>
#import "RIPAppDelegate.h"
#import "RIPSignUpViewController.h"
#import "FUIButton.h"
#import <FlatUIKit/UIColor+FlatUI.h> // flat colors

// to reset all data sources
#import "RIPChatData.h"
#import "RIPPeopleAroundData.h"

// to stop sharing profile
#import <SBUserBroadcast.h>

@interface RIPSettingsViewController ()
@property (strong, nonatomic) IBOutlet FUIButton *logOutButton;
@property (strong, nonatomic) IBOutlet UILabel *logOutText;

@end

@implementation RIPSettingsViewController

@synthesize logOutButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // configure button
        [logOutButton setBackgroundColor:[UIColor alizarinColor]];
        logOutButton.shadowColor = [UIColor pomegranateColor];
        logOutButton.shadowHeight = 3.0f;
        logOutButton.cornerRadius = 6.0f;
        logOutButton.titleLabel.font = [UIFont fontWithName:@"ComicNeue-Bold" size:20];
        [logOutButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
        [logOutButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateSelected];
        [logOutButton setTitle:@"LOG OUT" forState:UIControlStateNormal];

        // configure logout text
        [self.logOutText setFont:[UIFont fontWithName:@"ComicNeue-Thin" size:20]];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - target action
- (IBAction)didPressLogOut:(id)sender
{
    [PFUser logOut];
    [[RIPPeopleAroundData instance] logOut];
    [[RIPChatData currentInstance] logOut];
    [[SBUserBroadcast currentBroadcast] endBroadcast];

    RIPSignUpViewController *signUpVC = [[RIPSignUpViewController alloc] initWithNibName:@"SignUp" bundle:[NSBundle mainBundle]];
    RIPAppDelegate *app = [[UIApplication sharedApplication] delegate];
    app.window.rootViewController = signUpVC;
    [app.window makeKeyAndVisible];
}

@end
