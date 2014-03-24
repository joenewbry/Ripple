//
//  RIPGroupChatViewController.m
//  Ripple
//
//  Created by Joe Newbry on 3/24/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "RIPGroupChatViewController.h"
#import "RIPSettingsViewController.h"

@interface RIPGroupChatViewController ()

@end

@implementation RIPGroupChatViewController

- (id)init
{
    if (self = [super init]){


    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self setTitle:@"Ripple"];
    UIImage *gearImg = [UIImage imageNamed:@"cog.png"];
    UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithImage:gearImg style:UIBarButtonItemStylePlain target:self action:@selector(didPressSettings:)];
    [self.navigationItem setRightBarButtonItem:settingsItem];
    NSLog(@"white color is %@", [UIColor whiteColor].description);
    NSLog(@"%@", self.navigationController.navigationBar.tintColor.description);
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    NSLog(@"%@", self.navigationController.navigationBar.tintColor.description);
    [self.navigationController.navigationBar setTranslucent:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - target action
- (void)didPressSettings:(id)sender
{
    RIPSettingsViewController *settingsVC = [[RIPSettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

@end
