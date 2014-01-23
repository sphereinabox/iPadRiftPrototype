//
//  NWBleController.m
//  CameraProcessing
//
//  Created by Nicholas Winters on 7/5/13.
//  Copyright (c) 2013 Nicholas Winters. All rights reserved.
//

#import "NWBleController.h"
#import "FirstPlugin.h"
#include <math.h>

@interface NWBleController () {
    struct BleControllerState _previousInput;
    struct BleControllerState _currentInput;
}
@end

@implementation NWBleController

@synthesize ble;

- (id)init
{
    self = [super init];
    if (self) {
        self.ble = [[BLE alloc] init];
        [self.ble controlSetup:1];
        self.ble.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    self.ble = nil;
    //[super dealloc];
}

- (void) connectBle {
    NSLog(@"BLE: Connecting...");
    [ble findBLEPeripherals:2]; // Why is this 2?
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
}

- (void) disconnectBle {
    if (ble.activePeripheral) {
        if (ble.activePeripheral.isConnected)
        {
            // Disconnect:
            NSLog(@"BLE: disconnecting...");
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
            return;
        }
    }
}

- (struct BleControllerState)currentControlState {
    return _currentInput;
}

- (void)connectionTimer: (NSTimer *)timer
{
    if (ble.peripherals.count > 0)
    {
        NSLog(@"BLE: found device, finalizing connection");
        [ble connectPeripheral:[ble.peripherals objectAtIndex:0]];
    }
    else
    {
        NSLog(@"BLE: Connection search timed out");
    }
}
#pragma mark - BLE Delagate methods
- (void)bleDidDisconnect
{
    NSLog(@"BLE: Disconnected");
    
    // reset state of all controls
    struct BleControllerState inputData = {};
    _currentInput = inputData;
}

-(void)bleDidUpdateRSSI:(NSNumber *)rssi
{
}

-(void)bleDidConnect
{
    NSLog(@"BLE: Connected");
}

-(void)bleDidReceiveData:(unsigned char *)data length:(int)length
{
    //NSLog(@"Length: %d", length);
    
    if (length >= 3) {
        struct BleControllerState inputData = {};
        inputData.IsConnected = true;
        
        inputData.AxisX = fminf(2.0f * data[0] / 254.0f - 1.0f, 1.0f);
        inputData.AxisY = fminf(2.0f * data[1] / 254.0f - 1.0f, 1.0f);
        unsigned char buttons = data[2];
        inputData.ButtonDownA = (buttons & 0x01) != 0;
        inputData.ButtonDownB = (buttons & 0x02) != 0;
        inputData.ButtonDownX = (buttons & 0x04) != 0;
        inputData.ButtonDownY = (buttons & 0x08) != 0;
        inputData.ButtonDownStick = (buttons & 0x10) != 0;
        inputData.ButtonDownStart = (buttons & 0x20) != 0;
        
        _currentInput = inputData;
    }
}

@end
