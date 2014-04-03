//
//  RIPProfileViewController.m
//  Ripple
//
//  Created by Joe Newbry on 4/2/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "RIPProfileViewController.h"
#import <Parse/Parse.h>

@interface RIPProfileViewController ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *collegeLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *birthdayLabel;
@property (nonatomic, strong) UIImageView *profilePictureImageView;

@end

@implementation RIPProfileViewController

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


    // TODO figure out view life cycle so config happens right
    //      and then plugging in values happens
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 235, 300, 40)];
    self.nameLabel.text = @"Hello World";
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:24];
    self.nameLabel.textColor = [UIColor colorWithRed:59/255.0 green:137.0/255.0 blue:233.0/255.0 alpha:1.0];
    [self.view addSubview:self.nameLabel];

    self.collegeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 260, 300, 40)];
    self.collegeLabel.text = @"CMC";
    self.collegeLabel.textAlignment = NSTextAlignmentCenter;
    self.collegeLabel.font = [UIFont fontWithName:@"Avenir-Book" size:20];
    self.collegeLabel.textColor = [UIColor colorWithRed:59/255.0 green:137.0/255.0 blue:233.0/255.0 alpha:1.0];
    [self.view addSubview:self.collegeLabel];

    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 285, 300, 40)];
    self.statusLabel.text = @"Single";
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.font = [UIFont fontWithName:@"Avenir-Book" size:20];
    self.statusLabel.textColor = [UIColor colorWithRed:59/255.0 green:137.0/255.0 blue:233.0/255.0 alpha:1.0];
    [self.view addSubview:self.statusLabel];

    self.birthdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 310, 300, 40)];
    self.birthdayLabel.text = @"05/21/1992";
    self.birthdayLabel.textAlignment = NSTextAlignmentCenter;
    self.birthdayLabel.font = [UIFont fontWithName:@"Avenir-Book" size:20];
    self.birthdayLabel.textColor = [UIColor colorWithRed:59/255.0 green:137.0/255.0 blue:233.0/255.0 alpha:1.0];
    [self.view addSubview:self.birthdayLabel];

    self.profilePictureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(80, 80, 160, 160)];
    self.profilePictureImageView.image = [UIImage imageNamed:@"user.png"];
    self.profilePictureImageView.clipsToBounds = true;
    self.profilePictureImageView.layer.cornerRadius = 80;
    self.profilePictureImageView.layer.borderColor = [UIColor colorWithRed:59/255.0 green:137.0/255.0 blue:233.0/255.0 alpha:1.0].CGColor;
    self.profilePictureImageView.layer.borderWidth = 1;
    [self.view addSubview:self.profilePictureImageView];

    [[PFUser currentUser] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        self.nameLabel.text = [PFUser currentUser].username;
        self.collegeLabel.text = [PFUser currentUser][@"college"];
        self.statusLabel.text = [PFUser currentUser][@"relationshipStatus"];
        self.birthdayLabel.text = [PFUser currentUser][@"birthday"];

        PFFile *imgFile = [PFUser currentUser][@"profileImage"];
        [imgFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            self.profilePictureImageView.image = [UIImage imageWithData:data];
        }];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
