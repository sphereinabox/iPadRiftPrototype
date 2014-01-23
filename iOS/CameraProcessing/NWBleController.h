//
//  NWBleController.h
//  CameraProcessing
//
//  Created by Nicholas Winters on 7/5/13.
//  Copyright (c) 2013 Nicholas Winters. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "BLE.h"

@interface NWBleController : NSObject <BLEDelegate>

@property (strong, nonatomic) BLE *ble;

- (void)connectBle;
- (void)disconnectBle;
- (struct BleControllerState)currentControlState;


@end
