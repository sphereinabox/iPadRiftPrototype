//
//  NWViewController.m
//  BleJoystickShieldMobile
//
//  Created by Nicholas Winters on 4/12/13.
//  Copyright (c) 2013 Nicholas Winters. All rights reserved.
//

#import "NWViewController.h"

@interface NWViewController ()

@end

@implementation NWViewController

@synthesize ble;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Rotate Y slider to be veritcal.
    self.YAxisSlider.transform =
    CGAffineTransformRotate(self.YAxisSlider.transform, 1.5f*M_PI);
    // swap frame width/height
    CGRect originalFrame = self.YAxisSlider.frame;
    self.YAxisSlider.frame = CGRectMake(originalFrame.origin.x, originalFrame.origin.y, originalFrame.size.height, originalFrame.size.width);

    ble = [[BLE alloc] init];
    [ble controlSetup:1];
    ble.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ConnectButtonTouchUpInside:(id)sender {
    if (ble.activePeripheral) {
        if (ble.activePeripheral.isConnected)
        {
            // Disconnect:
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
            [self.ConnectButton setTitle:@"Connect" forState:UIControlStateNormal];
            return;
        }
    }
    [self.ConnectButton setEnabled:false];
    [ble findBLEPeripherals:2]; // Why is this 2?
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    [self.ConnectActivityIndicator startAnimating];
}

- (void)connectionTimer: (NSTimer *)timer
{
    self.ConnectButton.enabled = true;
    [self.ConnectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    
    if (ble.peripherals.count > 0)
    {
        [ble connectPeripheral:[ble.peripherals objectAtIndex:0]];
    }
    else
    {
        [self.ConnectButton setTitle:@"Connect" forState:UIControlStateNormal];
        [self.ConnectActivityIndicator stopAnimating];
    }
}

#pragma mark - BLE Delagate methods
- (void)bleDidDisconnect
{
    NSLog(@"-->Disconnected");
    
    [self.ConnectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [self.ConnectActivityIndicator stopAnimating];
    
    self.RssiLabel.text = @"---";

    // TODO: reset state of all controls
}

-(void)bleDidUpdateRSSI:(NSNumber *)rssi
{
    self.RssiLabel.text = rssi.stringValue;
}

-(void)bleDidConnect
{
    NSLog(@"-->Connected");
    
    [self.ConnectActivityIndicator stopAnimating];
    
    [self.ConnectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    
    // TODO: reset state of all controls
}

-(void)bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSLog(@"Length: %d", length);
    
    if (length >= 3) {
        self.XAxisSlider.value = data[0] / 255.0f;
        self.YAxisSlider.value = data[1] / 255.0f;
        unsigned char buttons = data[2];
        self.AButtonSwitch.on = (buttons & 0x01) != 0;
        self.BButtonSwitch.on = (buttons & 0x02) != 0;
        self.XButtonSwitch.on = (buttons & 0x04) != 0;
        self.YButtonSwitch.on = (buttons & 0x08) != 0;
        self.StickButtonSwitch.on = (buttons & 0x10) != 0;
        self.StartButtonSwitch.on = (buttons & 0x20) != 0;
    }
}

@end
