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
#import "RIPSaveImage.h"

@interface RIPSignUpViewController ()

@property (nonatomic, strong) UIButton *signUpButton;

// store user profile image from facebook
@property (nonatomic, strong) NSMutableData *imgData;
@property (nonatomic, strong) NSURLConnection *URLConnection;
@property (nonatomic, strong) UIImage *imgRef;


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
    signUpButton.enabled = true;

    // log in with facebook
    NSArray *permissionsArray = @[@"user_about_me"];
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        // transition to navigation controller with chat view as root
        if (error) NSLog(@"There's an error: %@", [error description]);
        if (!error){
            FBRequest *request = [FBRequest requestForMe];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error){
                    NSDictionary *userData = (NSDictionary *)result;
                    [PFUser currentUser].username = userData[@"name"];
                    [PFUser currentUser][@"birthday"] = userData[@"birthday"];
                    [PFUser currentUser][@"college"] = [self getCollegeStringFromEducation:userData[@"education"]];
                    [PFUser currentUser][@"relationshipStatus"] = userData[@"relationship_status"];

                    NSString *facebookID = userData[@"id"];
                    NSString *pictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID];
                    [PFUser currentUser][@"pictureURL"] = pictureURL;

                    [[PFUser currentUser] saveInBackground];

                    [self saveImageInBackground:[NSURL URLWithString:pictureURL]];
                }
            }];


        }

    }];

    // we've made it this far so we should just go to home page, user is already good to g
}


- (void)saveImageInBackground:(NSURL *)url
{
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2.0f];
    self.imgData = [NSMutableData new];
    self.URLConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
}

// Called every time a chunk of the data is received
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.imgData appendData:data]; // Build the image
}

// Called when the entire image is finished downloading
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    // Set the image in the header imageView
    PFFile *imageFile = [PFFile fileWithData:self.imgData]; // saves to parse

    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [PFUser currentUser][@"profileImage"] = imageFile;
        [[PFUser currentUser] saveEventually];
    }];

    UIImage *thumbnailImage =[UIImage imageWithData:self.imgData scale:.1];
    PFFile *thumbnailFile = [PFFile fileWithData:UIImagePNGRepresentation(thumbnailImage)];

    [thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [PFUser currentUser][@"thumbnailImage"] = thumbnailFile;
        [[PFUser currentUser] saveEventually];
    }];

    [self signIn];
}

- (void)signIn
{
    RIPGroupChatViewController *groupChatVC = [RIPGroupChatViewController new];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:groupChatVC];
    [self presentViewController:navController animated:NO completion:NULL];
}

- (NSString *)getCollegeStringFromEducation:(FBGraphObject *)fBGraphObject
{
    for (NSDictionary *school in fBGraphObject) {
        if ([school[@"type"] isEqualToString:@"College"]){
            return school[@"school"][@"name"];
        }
    }
    return @"No College Found";
}



@end
