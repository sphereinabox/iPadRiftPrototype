//
//  FirstPlugin.c
//  CameraProcessing
//
//  Created by Nicholas Winters on 7/5/13.
//  Copyright (c) 2013 Nicholas Winters. All rights reserved.
//

#include "FirstPlugin.h"
#include "NWBleController.h"

#pragma mark - Private C interface

NWBleController * _bleController = nil;

void InitBleController() {
    NSLog(@"InitBleController()");
    if (!_bleController) {
        _bleController = [[NWBleController alloc] init];
    }
}

#pragma mark - Public interface:

void BleControllerNativeTryConnect () {
    NSLog(@"FirstPlugin: Asked to connect");
    if (!_bleController) {
        _bleController = [[NWBleController alloc] init];
    }
    [_bleController connectBle];
}

void BleControllerNativeDisconnect () {
    NSLog(@"FirstPlugin: Asked to disconnect");
    if (!_bleController) {
        _bleController = [[NWBleController alloc] init];
    }
    [_bleController disconnectBle];
}

struct BleControllerState BleControllerNativeGetStatus () {
    if (!_bleController) {
        _bleController = [[NWBleController alloc] init];
    }
    /*
     NSLog(@"Hello from BleControllerNativeGetStatus()");
     struct BleControllerState result = {};
     result.IsConnected = TRUE;
     result.AxisX = 1.0f;
     result.AxisY = 1.0f;
     result.ButtonDownA = TRUE;
     result.ButtonDownB = FALSE;
     result.ButtonDownX = TRUE;
     result.ButtonDownY = FALSE;
     result.ButtonDownStick = TRUE; // Clicking button on left stick.
     result.ButtonDownStart = FALSE;
     return result;
     */
    return [_bleController currentControlState];
}
