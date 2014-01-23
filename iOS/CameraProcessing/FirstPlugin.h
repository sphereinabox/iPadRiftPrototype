//
//  FirstPlugin.h
//  CameraProcessing
//
//  Created by Nicholas Winters on 7/5/13.
//  Copyright (c) 2013 Nicholas Winters. All rights reserved.
//

#ifndef CameraProcessing_FirstPlugin_h
#define CameraProcessing_FirstPlugin_h

#import "BLE.h"

struct BleControllerState {
    BOOL IsConnected;
    float AxisX;
    float AxisY;
    BOOL ButtonDownA;
    BOOL ButtonDownB;
    BOOL ButtonDownX;
    BOOL ButtonDownY;
    BOOL ButtonDownStick; // Clicking button on left stick.
    BOOL ButtonDownStart;
};

void BleControllerNativeTryConnect ();

void BleControllerNativeDisconnect ();

struct BleControllerState BleControllerNativeGetStatus ();

#endif
