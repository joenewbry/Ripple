//
//  SBUserDiscovery.m
//  Blink
//
//  Created by Joe Newbry on 2/12/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "SBUserDiscovery.h"
#import "SBUserBroadcast.h"
#import "CBUUID+StringExtraction.h"
#import <UIKit/UIApplication.h>

NSString const *centralManagerRestorationUUID = @"F2552FC0-92C9-4A60-AA97-215E5FC3EE95";

@interface SBUserDiscovery () <CBCentralManagerDelegate, CBPeripheralDelegate> {
}

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) NSMutableSet *discoveringUsers; // peripherals that I'm attempting to connect to
@property (strong, nonatomic) NSMutableArray *discoveredUsers; // peripherals that I've connected to
@property (strong, nonatomic) NSMutableDictionary *userData;

// store array of discovered users
// send out messages when new user with data is found

@end

@implementation SBUserDiscovery
@synthesize centralManager;
@synthesize discoveredUsers;

BOOL searchWhenReady;



#pragma mark - External API

+ (id)createUserDiscovery
{
    static SBUserDiscovery *mySBUserDiscovery = nil;
    @synchronized(self) {
        if (mySBUserDiscovery == nil) mySBUserDiscovery = [[SBUserDiscovery alloc] init];
    }
    return mySBUserDiscovery;
}

+ (id)createUserDiscoveryWithLaunchOptions:(NSDictionary *)launchOptions
{
    static SBUserDiscovery *mySBUserDiscovery = nil;
    @synchronized(self) {
        if (mySBUserDiscovery == nil) mySBUserDiscovery = [[SBUserDiscovery alloc] initWithLaunchOptions:launchOptions];
    }
    return mySBUserDiscovery;
}

+ (id)currentUserDiscovery
{
    static SBUserDiscovery *mySBUserDiscovery = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySBUserDiscovery = [[self alloc] init];
    });
    return mySBUserDiscovery;
}

- (CBCentralManager *)centralManager
{

    if (!centralManager) centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey : @YES }];
    return centralManager;
}

- (NSMutableDictionary *)userData
{
    if (!_userData) _userData = [[NSMutableDictionary alloc]initWithDictionary:@{@"time-stamp" : @"Some date string"}];
    return _userData;
}

- (id)init
{
    return [self initWithLaunchOptions:nil];
}

- (id)initWithLaunchOptions:(NSDictionary *)launchOptions
{
    if (self = [super init]) {
        if (launchOptions)
        { self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:
                                                  @{CBCentralManagerOptionShowPowerAlertKey : @YES,
                                                    CBCentralManagerOptionRestoreIdentifierKey : launchOptions[UIApplicationLaunchOptionsBluetoothCentralsKey]                                                            }];
        } else {

        }
        self.discoveringUsers = [[NSMutableSet alloc] init];
        self.discoveredUsers  = [[NSMutableArray alloc] init];
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:
                               @{CBCentralManagerOptionShowPowerAlertKey : @YES}];
    }
    return self;
}
- (void)searchForUsers
{
    if (self.centralManager.state != CBCentralManagerStatePoweredOn){
        NSLog(@"Central Manager isn't powered on will call method when it gets powered on");
        searchWhenReady = true;
        return;
    }
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SBBroadcastServiceUserProfileUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @NO }];
}

- (void)stopSearchForUsers
{
    [self.centralManager stopScan];
    self.centralManager = nil;
}

#pragma mark - Central Manager Delegate
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict
{
    NSLog(@"central manager restoring state");
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
     switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            break;
        case CBCentralManagerStatePoweredOn:
             NSLog(@"Central manager powered on");
             if (searchWhenReady) [self searchForUsers];
            break;
        case CBCentralManagerStateResetting:
            break;
        case CBCentralManagerStateUnauthorized:
            break;
        case CBCentralManagerStateUnknown:
            break;
        case CBCentralManagerStateUnsupported:
            break;
    }

}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Central manager found peripherpheral");
    [self.discoveringUsers addObject:peripheral];
    [self.centralManager connectPeripheral:peripheral options:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Connected to peripheral with correct service UUID");
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SBBroadcastServiceUserProfileUUID]]]; // search for user profile service
    peripheral.delegate = self;
    [self.discoveredUsers addObject:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (error) NSLog(@"Central manager disconnected from peripheral with error: %@", [error localizedDescription]);
}




#pragma mark - Peripheral Delegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    int count = 0;

    
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:SBBroadcastServiceUserProfileUUID]]) {
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:SBBroadcastCharacteristicUserProfileObjectId]] forService:service];
        }
        count ++;
    }
}

// for found peripheral and service and characteristic attempt to read value
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *characteristic in service.characteristics) {
        [peripheral readValueForCharacteristic:characteristic];
    }
}

// read and store value depending on what characteristic is being read
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSData *myData = characteristic.value;

    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SBBroadcastCharacteristicUserProfileObjectId]]){
        self.userData[@"objectId"] = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];

        if ([self.delegate respondsToSelector:@selector(didReceiveUserID:)]) {
            NSLog(@"User ID: %@ is sent to delegate", self.userData[@"objectId"] );
            [self.delegate didReceiveUserID:self.userData[@"objectId"]];

        }

    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"characteristic updated is %@", [characteristic.UUID representativeString]);
}



- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices
{

    for (CBService *service in invalidatedServices){
        if ([service.UUID isEqual:[CBUUID UUIDWithString:SBBroadcastServiceUserProfileUUID]]){
            for (CBCharacteristic *characteristic in service.characteristics){
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SBBroadcastCharacteristicUserProfileObjectId]]){
                    if ([self.delegate respondsToSelector:@selector(userDidDisconnectWithObjectId:)]){
                        NSString *objectUUID = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
                        [self.delegate performSelector:@selector(userDidDisconnectWithObjectId:) withObject:objectUUID];
                    }

                }
            }
        }
    }
}


@end

