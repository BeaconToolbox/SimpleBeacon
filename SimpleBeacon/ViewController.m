//
//  ViewController.m
//  SimpleBeacon
//
//  Created by George Villasboas on 11/13/13.
//  Copyright (c) 2014 BeaconToolbox - Logics Software. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <sys/sysctl.h>

@interface ViewController ()<CBPeripheralManagerDelegate>
@property (strong, nonatomic) CBPeripheralManager *peripheral;
@property (weak, nonatomic) IBOutlet UISwitch *onOffSwitch;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@end

@implementation ViewController

#pragma mark -
#pragma mark Getters overriders
#pragma mark -

#pragma mark -
#pragma mark Setters overriders
#pragma mark -

#pragma mark -
#pragma mark Designated initializers
#pragma mark -

#pragma mark -
#pragma mark Public methods
#pragma mark -

#pragma mark -
#pragma mark Private methods
#pragma mark -

/**
 *  Returns the current user device idiom in a readable format
 *
 *  @return The device idiom on a readable format
 */
- (NSString *)device
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"iPad" : @"iPhone";
}

/**
 *  Returns the current OS version
 *
 *  @return The os version
 */
- (NSString *)osVersion
{
    int mib[2] = {CTL_KERN, KERN_OSVERSION};
    u_int namelen = sizeof(mib) / sizeof(mib[0]);
    size_t bufferSize = 0;
    
    NSString *osBuildVersion = nil;
    
    // Get the size for the buffer
    sysctl(mib, namelen, NULL, &bufferSize, NULL, 0);
    
    u_char buildBuffer[bufferSize];
    int result = sysctl(mib, namelen, buildBuffer, &bufferSize, NULL, 0);
    
    if (result >= 0) {
        osBuildVersion = [[NSString alloc] initWithBytes:buildBuffer length:bufferSize encoding:NSUTF8StringEncoding];
    }
    
    return [NSString stringWithFormat:@"%@ (%@)", [[UIDevice currentDevice] systemVersion], osBuildVersion];
}

/**
 *  Starts advertising
 */
- (void)start
{
    self.peripheral = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

/**
 *  Stops advertising
 */
- (void)stop
{
    [self.peripheral stopAdvertising];
    self.view.backgroundColor = [UIColor redColor];
}

#pragma mark -
#pragma mark ViewController life cycle
#pragma mark -

- (void)viewWillAppear:(BOOL)animated
{
    self.view.backgroundColor = [UIColor redColor];
    
    self.versionLabel.text = [NSString stringWithFormat:@"%@\niOS %@", [self device], [self osVersion]];
    
}

#pragma mark -
#pragma mark Overriden methods
#pragma mark -

#pragma mark -
#pragma mark Storyboards Segues
#pragma mark -

#pragma mark -
#pragma mark Target/Actions
#pragma mark -

- (IBAction)turnOnOff:(UISwitch *)sender
{
    if (sender.on) [self start];
    else [self stop];
}


#pragma mark -
#pragma mark Delegates
#pragma mark -

#pragma mark CBPeripheralManager Delegates

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state != CBPeripheralManagerStatePoweredOn){
        self.view.backgroundColor = [UIColor yellowColor];
        self.onOffSwitch.on = self.peripheral.isAdvertising;
        return;
    }
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"359E7924-DF9F-43DD-98DE-8A74409627FD"];
    CLBeaconRegion *region = [[CLBeaconRegion alloc]
                              initWithProximityUUID:uuid
                              major:10.0
                              minor:20.0
                              identifier:@"identifier"];
    
    NSDictionary *peripheralData = [region peripheralDataWithMeasuredPower:nil];
    [self.peripheral startAdvertising:peripheralData];
}


- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (!error) self.view.backgroundColor = [UIColor greenColor];
    else self.view.backgroundColor = [UIColor redColor];

    self.onOffSwitch.on = self.peripheral.isAdvertising;
}


#pragma mark -
#pragma mark Notification center
#pragma mark -

@end
