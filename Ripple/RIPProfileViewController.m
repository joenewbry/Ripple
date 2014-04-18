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
#import "RIPFacesById.h"

@interface RIPProfileViewController () <VLBCameraViewDelegate, UITextFieldDelegate>


@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *collegeTextField;
@property (strong, nonatomic) IBOutlet UITextField *statusTextField;
@property (strong, nonatomic) IBOutlet UITextField *birthdayTextField;

@property (nonatomic, weak) IBOutlet VLBCameraView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;

@property (strong, nonatomic) IBOutlet UIButton *takePictureButton;

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

    // create navigation bar and set title and back button
    self.title = @"Your Profile";

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissViewController:)];
    [self.navigationItem setRightBarButtonItem:doneButton];

    // if a user is logged in fetch data and update view
        [[PFUser currentUser] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if ([PFUser currentUser].username) self.nameTextField.text = [PFUser currentUser].username;
            if ([PFUser currentUser][@"college"]) self.collegeTextField.text = [PFUser currentUser][@"college"];
            if ([PFUser currentUser][@"relationshipStatus"]) self.statusTextField.text = [PFUser currentUser][@"relationshipStatus"];
            if ([PFUser currentUser][@"birthday"]) self.birthdayTextField.text = [PFUser currentUser][@"birthday"];

            if ([PFUser currentUser][@"profilePicture"]) {
                [self.profilePictureImageView setHidden:true];
                self.profilePicture.hidden = false;

                PFFile *profilePictureFile = [PFUser currentUser][@"profilePicture"];
                [profilePictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    self.profilePicture.image = [UIImage imageWithData:data];
                }];

                // make sure button logic for action when take picture/retake picture button
                // works correctly
                pictureTaken = true;
                [self.takePictureButton setTitle:@"RETAKE PICTURE" forState:UIControlStateNormal];

            } else {
                self.profilePictureImageView.hidden = false;
                self.profilePicture.hidden = true;
            }


        }];

    // set camera view circle mask and outline
    self.profilePictureImageView.layer.cornerRadius = 90;
    [self.profilePictureImageView setClipsToBounds:true];

    // set profile picture circle mask
    self.profilePicture.clipsToBounds = true;
    self.profilePicture.layer.cornerRadius = 90;
    self.profilePicture.layer.borderColor  = [UIColor colorWithRed:59.0/255.0 green:137.0/255.0 blue:233.0/255.0 alpha:1.0].CGColor;
    self.profilePicture.layer.borderWidth = 1;

    // make camera view delegate correctly and allow picture retake
    self.profilePictureImageView.delegate = self;
    self.profilePictureImageView.allowPictureRetake = true;

    // set text field delegates to self
    self.nameTextField.delegate = self;
    self.collegeTextField.delegate = self;
    self.statusTextField.delegate = self;
    self.birthdayTextField.delegate = self;

    // listen for keyboard showing and hiding so that view can shift up and down
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}


#pragma mark - VLBImageViewDelegate
- (void)cameraView:(VLBCameraView *)cameraView didFinishTakingPicture:(UIImage *)image withInfo:(NSDictionary *)info meta:(NSDictionary *)meta
{
    self.profilePicture.hidden = false;
    self.profilePicture.image = image;

    UIImage *rotatedImg = [self rotateUIImage:image clockwise:YES];

    [[RIPFacesById instance] setFaceImg:rotatedImg forUserId:[PFUser currentUser].objectId];

    NSData *pictureData = UIImagePNGRepresentation(rotatedImg);

    PFFile *profilePictureFile = [PFFile fileWithData:pictureData];
    [PFUser currentUser][@"profilePicture"] = profilePictureFile;
    [[PFUser currentUser] saveInBackground];
}

// helper method to rotate the underlying CGImage
- (UIImage*)rotateUIImage:(UIImage*)sourceImage clockwise:(BOOL)clockwise
{
    CGSize size = sourceImage.size;
    UIGraphicsBeginImageContext(CGSizeMake(size.height, size.width));
    [[UIImage imageWithCGImage:[sourceImage CGImage] scale:1.0 orientation:clockwise ? UIImageOrientationRight : UIImageOrientationLeft] drawInRect:CGRectMake(0,0,size.height ,size.width)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
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
    [[PFUser currentUser] saveInBackground];
}

- (IBAction)didFinishEditingCollege:(id)sender {
    [PFUser currentUser][@"college"] = [(UITextField *)sender text];
    [[PFUser currentUser] saveInBackground];
}

- (IBAction)didFinishEditingRelationshipStatus:(id)sender {
    [PFUser currentUser][@"relationshipStatus"] = [(UITextField *)sender text];
    [[PFUser currentUser] saveInBackground];
}

- (IBAction)didFinishEditingBirthday:(id)sender {
    [PFUser currentUser][@"birthday"] = [(UITextField *)sender text];
    [[PFUser currentUser] saveInBackground];
}


#pragma mark - Keyboard Notifications
// to add scrolling to active text field
// see the following link:
// https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html

- (void)keyboardWasShown:(NSNotification *)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    [self.view setFrame:CGRectMake(0, -kbSize.height, self.view.frame.size.width, self.view.frame.size.height)];
}
- (void)keyboardWasHidden:(NSNotification *)aNotification
{
    [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}


BOOL pictureTaken;
#pragma mark - gesture recognizers
- (IBAction)didPressTakePicture:(id)sender {
    if (!pictureTaken) {
        pictureTaken = true;
        [self.profilePictureImageView takePicture];
        [self.profilePictureImageView setHidden:true];
        [self.takePictureButton setTitle:@"RETAKE PICTURE" forState:UIControlStateNormal];
    }
    else {
        [self.profilePictureImageView setHidden:false];
        [self.profilePictureImageView retakePicture];
        pictureTaken = false;
        self.profilePicture.hidden = true;
        [self.takePictureButton setTitle:@"TAKE PICTURE" forState:UIControlStateNormal];

    }
}


#pragma mark - TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // resign first responder
    [textField resignFirstResponder];

    // move first responder to next text field
    if ([textField isEqual:self.nameTextField]){
        [self.collegeTextField becomeFirstResponder];
    }
    if ([textField isEqual:self.collegeTextField]) {
        [self.statusTextField becomeFirstResponder];
    }
    if ([textField isEqual:self.statusTextField]) {
        [self.birthdayTextField becomeFirstResponder];
    }
    // no text field becomes first responder after last text field
    if ([textField isEqual:self.birthdayTextField]) {

    }
    return YES;
}

#pragma mark - Dismiss view controller
- (void)dismissViewController:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
