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

@interface RIPSettingsViewController ()

@end

@implementation RIPSettingsViewController

- (id)init
{
    if (self = [super init]) {
        UIButton *logOutButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 200, 280, 50)];
        logOutButton.backgroundColor = [UIColor colorWithRed:59/255.0 green:137.0/255.0 blue:233.0/255.0 alpha:1.0];
        [logOutButton.layer setCornerRadius:5.0];
        [logOutButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [logOutButton.titleLabel setTextColor:[UIColor whiteColor]];
        [logOutButton.titleLabel setFont:[UIFont fontWithName:@"Avenir-Black" size:20]];
        [logOutButton setTitle:@"LOG OUT" forState:UIControlStateNormal];
        [logOutButton addTarget:self action:@selector(didPressLogOut:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:logOutButton];

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
- (void)didPressLogOut:(id)sender
{
    [PFUser logOut];
//    [self.navigationController popToRootViewControllerAnimated:NO];
//    [[self.navigationController presentedViewController] dismissViewControllerAnimated:NO completion:NULL];

    RIPSignUpViewController *signUpVC = [[RIPSignUpViewController alloc] init];
    RIPAppDelegate *app = [[UIApplication sharedApplication] delegate];
    app.window.rootViewController = signUpVC;
    [app.window makeKeyAndVisible];
}

@end
