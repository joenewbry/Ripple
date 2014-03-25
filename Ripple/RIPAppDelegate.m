//
//  RIPAppDelegate.m
//  Ripple
//
//  Created by Joe Newbry on 3/22/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "RIPAppDelegate.h"
#import <Parse/Parse.h>
#import "RIPGroupChatViewController.h"
#import "RIPSignUpViewController.h"

@implementation RIPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    // configure Parse
    [Parse setApplicationId:@"zDKQTO7Woa8CxWyvJIJ3kqCWJiBNQLVevHd4NND1"
                  clientKey:@"kbjzFOHawHbdT30LefPfaNMn7oR9MCmsHqUaEXRA"];

    // configure navigation bar left and right items
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:59/255.0 green:137.0/255.0 blue:233.0/255.0 alpha:1.0]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];


    // Customize the title text for *all* UINavigationBars
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor],
      NSForegroundColorAttributeName,
      [UIFont fontWithName:@"Avenir-Heavy" size:30.0],
      NSFontAttributeName,
      nil]];


    // set up window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];

    // set root view controller depending on if a user is logged in
    [PFUser logOut];
    if (true) {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[RIPGroupChatViewController new]];

        self.window.rootViewController = navController;
    } else {
        self.window.rootViewController = [RIPSignUpViewController new];
    }

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
