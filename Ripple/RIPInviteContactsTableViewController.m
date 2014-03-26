//
//  RIPInviteContactsTableViewController.m
//  Ripple
//
//  Created by Joe Newbry on 3/24/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "RIPInviteContactsTableViewController.h"
#import <ABContactHelper/ABContactsHelper.h>

@interface RIPInviteContactsTableViewController ()

@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSMutableArray *contactsAlphabet;
@property (nonatomic, strong) NSMutableSet *selectedContacts;

@end

@implementation RIPInviteContactsTableViewController

- (id)init
{
    if (self = [super init]) {
        // configure navigation bar
        self.title = @"Invite Friends";
        self.navigationItem.leftBarButtonItem.title = @"";

        self.selectedContacts = [NSMutableSet new];

        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Invite" style:UIBarButtonItemStylePlain target:self action:@selector(didPressInvite:)];
        self.navigationItem.rightBarButtonItem = rightButton;

        [self.tableView setAllowsMultipleSelection:true];

        // get contacts from super cool library ABContactsHelper
        self.contacts = [[NSMutableArray alloc] initWithArray:[ABContactsHelper contacts]];

        // filter out unusable contacts
        NSPredicate *poundPredicate = [NSPredicate predicateWithFormat:@"!(contactName beginswith '#')"];
        NSPredicate *applePreidicate = [NSPredicate predicateWithFormat:@"!(contactName beginswith 'Apple Inc.')"];
        NSPredicate *emptyNameStringPredicate = [NSPredicate predicateWithFormat:@"contactName != ''"];
        NSPredicate *emptyPhoneObjectPredicate = [NSPredicate predicateWithFormat:@"phoneArray != nil"];
        NSPredicate *emptyPhoneStringPredicate = [NSPredicate predicateWithFormat:@"phoneArray[0] != ''"];

        [self.contacts filterUsingPredicate:poundPredicate];
        [self.contacts filterUsingPredicate:applePreidicate];
        [self.contacts filterUsingPredicate:emptyNameStringPredicate];
        [self.contacts filterUsingPredicate:emptyPhoneObjectPredicate];
        [self.contacts filterUsingPredicate:emptyPhoneStringPredicate];

        // sort contacts
        self.contacts = [NSMutableArray arrayWithArray:[self.contacts sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSString *first = [(ABContact*)a firstname];
            NSString *second = [(ABContact*)b firstname];
            return [first compare:second];
        }]];

        // index contacts by first name so table view index works
        self.contactsAlphabet = [NSMutableArray new];
        NSMutableDictionary *aSection;
        NSString *firstLetter;
        NSMutableArray *rowValues;
        NSMutableArray *sortedContacts = [NSMutableArray new];
        BOOL newSection = true;
        for (ABContact *aContact in self.contacts){
            // check if we've hit a new letter
            if (firstLetter && firstLetter != [aContact.contactName substringToIndex:1]){
                newSection = true;
            }

            // if newSection process previous section
            if (newSection){
                if (aSection) {
                    [aSection setValue:rowValues forKey:@"rowValues"];
                    [sortedContacts addObject:aSection];
                }
                aSection = [NSMutableDictionary new];
                rowValues = [NSMutableArray new];
                firstLetter = [aContact.contactName substringToIndex:1];
                [self.contactsAlphabet addObject:firstLetter];
                [aSection setValue:firstLetter forKey:@"headerTitle"];
            }

            [rowValues addObject:aContact];
        }

        self.contacts = sortedContacts;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.contacts count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.contacts objectAtIndex:section][@"rowValues"] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContactCell"];

    ABContact *contactAtIndex = (ABContact *)[[self.contacts objectAtIndex:indexPath.section][@"rowValues"] objectAtIndex:indexPath.row];

    cell.selectionStyle = UITableViewCellSelectionStyleGray;

    cell.textLabel.text = contactAtIndex.contactName;
    cell.textLabel.textColor = [UIColor colorWithRed:59/255.0 green:137.0/255.0 blue:233.0/255.0 alpha:1.0];
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:16];
    cell.textLabel.highlightedTextColor = [UIColor whiteColor];

    cell.detailTextLabel.text = contactAtIndex.phoneArray[0];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:59/255.0 green:137.0/255.0 blue:233.0/255.0 alpha:1.0];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Avenir-Book" size:16];
    cell.detailTextLabel.highlightedTextColor = [UIColor whiteColor];

    UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(276, 8, 26, 26)];
    circle.clipsToBounds = true;
    circle.layer.cornerRadius = 13;
    circle.layer.borderWidth = 1;
    circle.layer.borderColor = [UIColor colorWithRed:59/255.0 green:137.0/255.0 blue:233.0/255.0 alpha:1.0].CGColor;

    [cell.contentView addSubview: circle];


    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.contacts valueForKey:@"headerTitle"];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.contactsAlphabet indexOfObject:title];
}


#pragma mark - Table view delegate

// keep track of which cells are selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ABContact *contactToAdd = [[self.contacts objectAtIndex:indexPath.section][@"rowValues"] objectAtIndex:indexPath.row];
    [self.selectedContacts addObject:contactToAdd.phoneArray[0]];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ABContact *contactToRemove = [[self.contacts objectAtIndex:indexPath.section][@"rowValues"] objectAtIndex:indexPath.row];

    [self.selectedContacts removeObject:contactToRemove.phoneArray[0]];
}


#pragma mark - target action
-(void)didPressInvite:(id)sender
{
    [self showSMS];
}

-(void)showSMS
{
    if (![MFMessageComposeViewController canSendText]){
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Try different device" message:@"Your apple device can't send text messages" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [warningAlert show];
        return;
    }
    NSString *message = [NSString stringWithFormat:@"Check out Ripple! The easiest way to chat with people nearby"];
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:[self.selectedContacts allObjects]];
    [messageController setBody:message];

    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

#pragma mark - message compose delegate

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Message failed to send!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [warningAlert show];
            break;
        }
        case MessageComposeResultSent:
            [self.tabBarController setSelectedIndex:1];
            [self performSegueWithIdentifier:@"Submitted Assignments" sender:self];
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
