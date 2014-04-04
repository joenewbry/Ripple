//
//  RIPProfileViewController.m
//  Ripple
//
//  Created by Joe Newbry on 4/2/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "RIPProfileViewController.h"
#import <Parse/Parse.h>
#import <VLBCameraView.h>

@interface RIPProfileViewController () <VLBCameraViewDelegate>


@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *collegeTextField;
@property (strong, nonatomic) IBOutlet UITextField *statusTextField;
@property (strong, nonatomic) IBOutlet UITextField *birthdayTextField;

@property (nonatomic, weak) IBOutlet VLBCameraView *profilePictureImageView;

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

    // if a user is logged in fetch data and update view
        [[PFUser currentUser] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if ([PFUser currentUser].username) self.nameTextField.text = [PFUser currentUser].username;
            if ([PFUser currentUser][@"college"]) self.collegeTextField.text = [PFUser currentUser][@"college"];
            if ([PFUser currentUser][@"relationshipStatus"]) self.statusTextField.text = [PFUser currentUser][@"relationshipStatus"];
            if ([PFUser currentUser][@"birthday"]) self.birthdayTextField.text = [PFUser currentUser][@"birthday"];

        }];

    // set camera view circle mask and outline
    self.profilePictureImageView.layer.cornerRadius = 90;
    self.profilePictureImageView.layer.borderColor = [UIColor colorWithRed:59.0/255.0 green:237.0/255.0 blue:233.0/255.0 alpha:1.0].CGColor;
    self.profilePictureImageView.layer.borderWidth = 1;

    // set view gesture recognizer
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

//    self.profilePictureImageView = [[VLBCameraView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
//    //    self.profilePictureImageView.backgroundColor = [UIColor purpleColor];
//    //    self.profilePictureImageView.clipsToBounds = true;
//    //    self.profilePictureImageView.layer.cornerRadius = 80;
//    //    self.profilePictureImageView.layer.borderColor = [UIColor colorWithRed:59/255.0 green:137.0/255.0 blue:233.0/255.0 alpha:1.0].CGColor;
//    //    self.profilePictureImageView.layer.borderWidth = 1;
//    self.profilePictureImageView.delegate = self;
//    self.profilePictureImageView.allowPictureRetake = true;
//    [self.view addSubview:self.profilePictureImageView];

//    VLBCameraView *view = [[VLBCameraView alloc] initWithFrame:CGRectMake(0,60,320,320)];
//    view.delegate = self;
//    [self.view addSubview:view];
//
//    [view takePicture];
    self.profilePictureImageView.allowPictureRetake = true;

}

#pragma mark - VLBImageViewDelegate
- (void)cameraView:(VLBCameraView *)cameraView didFinishTakingPicture:(UIImage *)image withInfo:(NSDictionary *)info meta:(NSDictionary *)meta
{

}

- (void)cameraView:(VLBCameraView *)cameraView didErrorOnTakePicture:(NSError *)error
{

}

- (void)cameraView:(VLBCameraView *)cameraView willRetakePicture:(UIImage *)image
{

}

#pragma mark - editing profile (except picture which is above)
- (IBAction)didFinishEditingName:(id)sender {
    [PFUser currentUser].username = [(UITextField *)sender text];
}

- (IBAction)didFinishEditingCollege:(id)sender {
    [PFUser currentUser][@"college"] = [(UITextField *)sender text];
}

- (IBAction)didFinishEditingRelationshipStatus:(id)sender {
    [PFUser currentUser][@"relationshipStatus"] = [(UITextField *)sender text];
}

- (IBAction)didFinishEditingBirthday:(id)sender {
    [PFUser currentUser][@"birthday"] = [(UITextField *)sender text];
}

#pragma mark - gesture recognizers
- (void)didTap:(id)sender
{
    [self.profilePictureImageView takePicture];
}





@end
