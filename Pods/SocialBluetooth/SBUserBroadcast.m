//
//  SBUserBroadcast.m
//  Blink
//
//  Created by Joe Newbry on 2/12/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "SBUserBroadcast.h"
#import <UIKit/UIApplication.h>
#import <CoreBluetooth/CoreBluetooth.h>

NSString *peripheralRestorationUUID = @"A6499ECB-0B6C-4609-B161-E3D15687AF3D";

NSString * const SBBroadcastPeripheralUserProfileUUID = @"FC038B47-0022-4F8B-A8A3-74EC7D930B56";
NSString * const SBBroadcastServiceUserProfileUUID = @"1EF38271-ADE8-44A5-B9B6-BAB493D9A1F6";
NSString * const SBBroadcastCharacteristicUserProfileObjectId = @"2863DBD0-C65D-4F75-86B2-4A29D59776A5";


@interface SBUserBroadcast () <CBPeripheralDelegate, CBPeripheralManagerDelegate>

- (id)init;
- (id)initWithLaunchOptions:(NSDictionary *)launchOptions;

// peripheral managers
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;

// services
@property (nonatomic, strong) CBMutableService *userProfileService;

// characteristics
@property (nonatomic, strong) CBMutableCharacteristic *objectIdCharacteristic;

// values of characteristics
@property (nonatomic, strong) NSString *objectId;

@end


@implementation SBUserBroadcast

// class methods
static SBUserBroadcast *mySBUserBroadcast = nil;

+ (SBUserBroadcast *)createPeripheralWithLaunchOptions:(NSDictionary *)launchOptions
{
    @synchronized(self) {
        if (mySBUserBroadcast == nil) mySBUserBroadcast = [[self alloc] initWithLaunchOptions:launchOptions];
    }
    return mySBUserBroadcast;
}

+ (SBUserBroadcast *)currentBroadcast
{
    @synchronized(self) {
        if (mySBUserBroadcast == nil) mySBUserBroadcast = [[self alloc] init];
    }
    return mySBUserBroadcast;
}

// getters and setters

- (NSString *)objectId
{
    if (!_objectId) _objectId = @"Z0zYr8Fw4Y";
    return _objectId;
}

- (id)init
{
    return [self initWithLaunchOptions:nil];
}


// should only be called once
- (id)initWithLaunchOptions:(NSDictionary *)launchOptions
{
    if (self = [super init]) {
        // if there is a restoration key in launch options for peripheral then use it to restore
        if (launchOptions[UIApplicationLaunchOptionsBluetoothPeripheralsKey]) {
            self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:@{ CBCentralManagerOptionShowPowerAlertKey : @YES,
                CBCentralManagerOptionRestoreIdentifierKey : launchOptions[UIApplicationLaunchOptionsBluetoothPeripheralsKey]
                                                                                                             }];
        }
        // create a new restoration key
        else {
            self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:@{ CBCentralManagerOptionShowPowerAlertKey : @YES,
                                                                                                             CBCentralManagerOptionRestoreIdentifierKey : @"Unique-Restoration-Identifier"
                                                                                                             }];
        }
    }
    return self;
}

- (void)setUniqueIdentifier:(NSString *)UUID
{
    self.objectId = UUID;
}

BOOL addObjectIDServiceWhenPoweredOn;
- (void)addServices
{
    if (!self.objectId) {
        NSLog(@"No object ID found, using default 'Social Bluetooth is Cool!'");
    }
    if (!self.peripheralManager || self.peripheralManager.state != CBCentralManagerStatePoweredOn) {
        addObjectIDServiceWhenPoweredOn = true; // used in delegate method to call add service
        return;
    }

    NSData *objectIdData = [self.objectId dataUsingEncoding:NSUTF8StringEncoding];
    self.objectIdCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:SBBroadcastCharacteristicUserProfileObjectId] properties:CBCharacteristicPropertyRead value:objectIdData permissions:CBAttributePermissionsReadable];

    self.userProfileService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:SBBroadcastServiceUserProfileUUID] primary:YES];
    [self.userProfileService setCharacteristics:@[self.objectIdCharacteristic/**, self.userNameCharacteristic, self.profileImageCharacteristic, self.statusCharacteristic, self.quoteCharacteristic*/]];

    // share newly created user services
    [self.peripheralManager addService:self.userProfileService];
}

BOOL broadcastProfileWhenPoweredOn; // used so that Bluetooth State Change delegte can call startBroadcast
BOOL broadcastProfileWhenProfileServiceCreated; // used so that adding UUID service can call start Broadcast
- (void)startBroadcast
{
    // peripheral manager must be powered on to call methods on it
    if (self.peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Peripheral Manager is not powered on, method will be called when it's powered on");
        broadcastProfileWhenPoweredOn = true;
        return;
    }

    // service must be added before it can be advertised
    if (!self.userProfileService) {
        broadcastProfileWhenProfileServiceCreated = true;
        return;
    }
    [self.peripheralManager startAdvertising:@{
                                                CBAdvertisementDataServiceUUIDsKey : @[self.userProfileService.UUID]
                                                }];
}

- (void)endBroadcast
{
    // TODO : add way to check to see if peripheral and central are created or not
    [self.peripheralManager stopAdvertising];
    self.peripheralManager = nil;
}



#pragma mark - peripheral manager delegate
- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict
{
    NSLog(@"Peripherary state is being restored");
}
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSString *errorMessage = [[NSString alloc] init];
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"Peripheral manager powered on");
            if (addObjectIDServiceWhenPoweredOn) [self addServices];
            if (broadcastProfileWhenPoweredOn) [self startBroadcast];
            break;
        case CBPeripheralManagerStatePoweredOff:
            errorMessage = @"It looks like Bluetooth is turned off. Turn on Bluetooth to discover people!";
            break;
        case CBPeripheralManagerStateResetting:
            break;
        case CBPeripheralManagerStateUnauthorized:
            errorMessage = @"peripheral state unauthorized";
            break;
        case CBPeripheralManagerStateUnknown:
            break;
        case CBPeripheralManagerStateUnsupported:
            break;
    }

    if (peripheral.state == CBPeripheralManagerStateUnknown ||
        peripheral.state == CBPeripheralManagerStateUnsupported ||
        peripheral.state == CBPeripheralManagerStatePoweredOff ){
        NSLog(@"WARNING: Bluetooth must be turned on for app to work");
    }


}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)myService
                    error:(NSError *)error {
    NSLog(@"Peripheral manager did add service %@", [myService description]);
    if (error) {
    }

    if ([myService isEqual:self.userProfileService]){
        if (broadcastProfileWhenProfileServiceCreated) {
            [self startBroadcast];
        }
    }

}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral Manager stated advertising peripheral %@", [peripheral description]);
    if (error) {
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    if ([request.characteristic.UUID isEqual:self.objectIdCharacteristic.UUID]) {
        [self respondToReadRequest:request forCharacteristic:self.objectIdCharacteristic];
    }
}

#pragma mark - Supporting Methods
- (void)respondToReadRequest:(CBATTRequest *)request forCharacteristic:(CBCharacteristic *)characteristic
{
    if (request.offset > characteristic.value.length) {
        return;
    }
    request.value = [characteristic.value subdataWithRange:NSMakeRange(request.offset, characteristic.value.length - request.offset)];
    [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
}

@end


