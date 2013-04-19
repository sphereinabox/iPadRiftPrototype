//
//  NWViewController.h
//  CameraProcessing
//
//  Created by Nicholas Winters on 12/23/12.
//  Copyright (c) 2012 Nicholas Winters. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "BLE.h"

@interface NWViewController : GLKViewController <BLEDelegate>
{
    __weak IBOutlet UIButton *connectControllerButton;
}

- (IBAction)connectControllerButtonTouchUpInside:(id)sender;

@property (strong, nonatomic) BLE *ble;

@end
