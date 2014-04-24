//
//  NZBleConnectionViewController.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 26/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "NZBleConnectionViewController.h"
#import "NZNotificationConstants.h"

@interface NZBleConnectionViewController ()

@property NSString *connectedLabelText;

@end

@implementation NZBleConnectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bleDidConnect:) name:NZDidConnectToBle object:nil];
    if (!self.connectedLabel) {
        self.connectedLabelText = @"NOT CONNECTED";
    }
    self.connectedLabel.text = self.connectedLabelText;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) updateConnectedLabel:(BOOL)connected{
    if (connected) {
        self.connectedLabelText = @"CONNECTED";
    } else {
        self.connectedLabelText = @"NOT CONNECTED";
    }
}

/*
-(BOOL)extractDataFromBuffer:(uint8_t *)buffer withLength:(NSInteger)length to:(SensorData *)sensorData{
    if (!sensorData) {
        return false;
    }
    bool readPackage = true;
    // TODO move this to one method of the SensorData class
    if( [sensorData.x setValueFromBuffer:buffer withBufferLength:(int)length ] ){
       // NSLog(@"finished reading X data!");
    } else readPackage = false;
    if( [sensorData.y setValueFromBuffer:buffer withBufferLength:(int)length ] ){
        //NSLog(@"finished reading Y data!");
    } else readPackage = false;
    if( [sensorData.z setValueFromBuffer:buffer withBufferLength:(int)length ] ){
        //NSLog(@"finished reading Z data!");
    } else readPackage = false;
    
    if (readPackage) {
        [self updateSensorDataTextWithSensorData:sensorData];
        //[self updateSensorDataText];
        // Update the accelerometer graph view
        //  if (!isPaused)
        //  {
        //      [accelerometerView addData:accelerometerData];
        //  }
    }
    return readPackage;
}
 */

-(void)updateSensorDataTextWithSensorData:(SensorData*)data{
    self.receivedDataLabel.text = [[NSString alloc] initWithFormat:@"ax: %ld, ay: %ld, az: %ld", data.x.value, data.y.value, data.z.value ];
}


#pragma mark -
#pragma mark manage notifications
#pragma mark -


@end
