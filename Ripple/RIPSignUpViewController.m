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

@interface RIPSignUpViewController ()

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UIButton *joinUsButton;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;


// store user profile image from facebook
@property (nonatomic, strong) NSMutableData *imgData;
@property (nonatomic, strong) NSURLConnection *URLConnection;
@property (nonatomic, strong) UIImage *imgRef;


@end

@implementation RIPSignUpViewController

- (id)init
{
    if (self = [super init]) {

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
- (IBAction)didPressJoinUs:(id)sender {

    // no username let the user know to input a user name
    if ([self.usernameTextField.text length] == 0) {
        [self.usernameTextField setPlaceholder:@">> Username <<"];
    }
    // no password. let user know to input password
    else if ([self.passwordTextField.text length] == 0) {
        [self.passwordTextField setPlaceholder:@">> Password <<"];
    }
    // good to go, so create parse user and move to profile view
    else {
        [self signIn];
    }
}

- (void)signIn
{
    PFUser *newUser = [PFUser user];
    newUser.username = self.usernameTextField.text;
    newUser.password = self.passwordTextField.text;

    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        // we've create a new user
        RIPGroupChatViewController *groupChatVC = [RIPGroupChatViewController new];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:groupChatVC];
        RIPProfileViewController *profileVC = [[RIPProfileViewController alloc] initWithNibName:@"Profile" bundle:[NSBundle mainBundle]];
        [navController pushViewController:profileVC animated:NO];
        [self presentViewController:navController animated:NO completion:NULL];
    }];

}

@end
