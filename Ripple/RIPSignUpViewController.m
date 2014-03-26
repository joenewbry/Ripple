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

@interface RIPSignUpViewController ()

@property (nonatomic, strong) UIButton *signUpButton;

@end

@implementation RIPSignUpViewController

@synthesize signUpButton;

- (id)init
{
    if (self = [super init]) {
        // position button based on view size
        float height = self.view.bounds.size.height;

        signUpButton = [[UIButton alloc] initWithFrame:CGRectMake(20, height - 60, 280, 50)];
        signUpButton.backgroundColor = [UIColor colorWithRed:59/255.0 green:137.0/255.0 blue:233.0/255.0 alpha:1.0];
        [signUpButton.layer setCornerRadius:5.0];
        [signUpButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [signUpButton.titleLabel setTextColor:[UIColor whiteColor]];
        [signUpButton.titleLabel setFont:[UIFont fontWithName:@"Avenir-Black" size:20]];
        [signUpButton setTitle:@"FACEBOOK SIGN IN" forState:UIControlStateNormal];
        [signUpButton addTarget:self action:@selector(didPressSignUp:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:signUpButton];

        // add welcome text
        UILabel *welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, 280, 40)];
        [welcomeLabel setTextAlignment:NSTextAlignmentCenter];
        [welcomeLabel setTextColor:[UIColor colorWithRed:59/255.0 green:137.0/255.0 blue:233.0/255.0 alpha:1.0]];
        [welcomeLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:30]];
        [welcomeLabel setText:@"Welcome to Ripple"];
        [self.view addSubview:welcomeLabel];

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
- (void)didPressSignUp:(id)sender
{
    // disable button while signing up
    signUpButton.enabled = false;

    // log in with facebook
    NSArray *permissionsArray = @[@"user_about_me"];
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        // transition to navigation controller with chat view as root
        if (!error){
            FBRequest *request = [FBRequest requestForMe];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error){
                    NSDictionary *userData = (NSDictionary *)result;
                    [PFUser currentUser].username = userData[@"name"];
                    NSString *facebookID = userData[@"id"];
                    NSString *pictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID];
                    [PFUser currentUser][@"pictureURL"] = pictureURL;

                    RIPGroupChatViewController *groupChatVC = [RIPGroupChatViewController new];
                    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:groupChatVC];

                    [self presentViewController:navController animated:NO completion:NULL];

                }
            }];


        }

    }];
}



@end
