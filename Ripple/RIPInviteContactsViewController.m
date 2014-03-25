//
//  RIPInviteContactsViewController.m
//  Ripple
//
//  Created by Joe Newbry on 3/24/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "RIPInviteContactsViewController.h"
#import <AddressBook/AddressBook.h>

@interface RIPInviteContactsViewController ()

@property (nonatomic, assign) ABAddressBookRef addressBook;
@property (nonatomic, strong) NSMutableArray *contactsArray;

@end

@implementation RIPInviteContactsViewController

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

    _addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    self.contactsArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self checkAddressBook];
}

- (void)checkAddressBook
{
    switch (ABAddressBookGetAuthorizationStatus()) {
        case kABAuthorizationStatusAuthorized:
            [self accessGrantedForAddressBook];
            break;

        case kABAuthorizationStatusNotDetermined :
            [self requestAddressBookAccess];

        default:
            break;
    }
}

- (void)requestAddressBookAccess
{
    RIPInviteContactsViewController * __weak weakSelf = self;

    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error)
                                             {
                                                 if (granted)
                                                 {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         [weakSelf accessGrantedForAddressBook];
                                                     });
                                                 }
                                             });
}



// User has granted access to address book data
- (void)accessGrantedForAddressBook
{
    // Load data from the plist file.

    self.contactsArray = [NSMutableArray arrayWithArray:[self getContactList]];

    for (NSDictionary* dict in self.contactsArray){
        NSLog(@"object is %@", dict[@"number"]);
    }

}

- (NSArray *)getContactList
{
    //CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);


    NSArray *contacts;
    NSMutableArray *formatedContacts = [[NSMutableArray alloc] init];

    if (addressBook != nil){
        NSLog(@"We're in");
        contacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);

        // get name and number properites and store in an array of strings
        for (NSUInteger i = 0; i < [contacts count]; i ++){
            ABRecordRef onePersonInContacts = (__bridge ABRecordRef)contacts[i];
            NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(onePersonInContacts, kABPersonFirstNameProperty);
            NSString *lastName =  (__bridge_transfer NSString *)ABRecordCopyValue(onePersonInContacts, kABPersonLastNameProperty);

            if (firstName == nil){
                firstName = @"";
            }
            if (lastName == nil){
                lastName = @"";
            }
            if (firstName == nil && lastName == nil)
            {
                break;
            }
            NSString *fullName = [NSString stringWithFormat:@"%@ %@",
                                  firstName, lastName];
            ABMultiValueRef phoneNumberMultiValue = ABRecordCopyValue(onePersonInContacts, kABPersonPhoneProperty);
            NSUInteger phoneNumberIndex = 0;
            NSString *phoneNumber = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneNumberMultiValue, phoneNumberIndex);

            //            NSString *fullNameWithPhone = [NSString stringWithFormat:@"%@ %@",
            //                                           fullName, phoneNumber];
            //            NSLog(@"contact added is %@", fullNameWithPhone);

            if (fullName && phoneNumber){
                [formatedContacts addObject:@{@"name": fullName,
                                              @"number": phoneNumber}];
            }


            if (phoneNumber){
                [self.contactsArray setValue:phoneNumber forKey:fullName];
                NSLog(@"Phone Number:%@, for key:%@", phoneNumber, fullName);
            }

            //NSLog(@"is the phoneNumberArray not nill?, %@", (NSInteger *)[self.phoneNumbersArray count]);

            //NSLog(@"Formatted contacts %@", ()[formatedContacts count]);
        }
    }

    //    NSMutableArray* strings = [NSMutableArray arrayWithObjects:@"dog", @"ant", @"cat",nil];
    //    [strings sortUsingSelector:@selector(compare:)];
    //[formatedContacts sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [formatedContacts removeObject:@" "];
    //formatedContacts = (NSMutableArray *)[formatedContacts
                                          //filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF beginswith '#'"]];
    //    NSLog(@"%@", strings);

    NSArray *finalContactList = [[NSArray alloc] initWithArray:formatedContacts];
    //NSLog(@"Length of list returned %@", [finalContactList count]);
    return finalContactList;
}


@end
