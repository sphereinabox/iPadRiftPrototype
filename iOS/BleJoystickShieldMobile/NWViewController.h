//
//  NWViewController.h
//  BleJoystickShieldMobile
//
//  Created by Nicholas Winters on 4/12/13.
//  Copyright (c) 2013 Nicholas Winters. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"

@interface NWViewController : UIViewController <BLEDelegate>
{
}

@property (weak, nonatomic) IBOutlet UIButton *ConnectButton;
- (IBAction)ConnectButtonTouchUpInside:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ConnectActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *RssiLabel;
@property (weak, nonatomic) IBOutlet UISlider *XAxisSlider;
@property (weak, nonatomic) IBOutlet UISlider *YAxisSlider;
@property (weak, nonatomic) IBOutlet UISwitch *AButtonSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *BButtonSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *XButtonSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *YButtonSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *StickButtonSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *StartButtonSwitch;

@property (strong, nonatomic) BLE *ble;

@end
