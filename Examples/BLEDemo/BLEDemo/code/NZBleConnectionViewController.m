//
//  NZBleConnectionViewController.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 26/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "NZBleConnectionViewController.h"

@interface NZBleConnectionViewController ()

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
   /* // set the background image
    
    CGSize size = self.view.layer.bounds.size;
    UIGraphicsBeginImageContext(size);
    UIImage *img = [UIImage imageNamed:@"bleImage.png"];
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:newImg];
    */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) updateConnectedLabel:(BOOL)connected{
    if (connected) {
        self.connectedLabel.text = @"CONNECTED";
    } else {
        self.connectedLabel.text = @"NOT CONNECTED";
    }
}

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

-(void)updateSensorDataTextWithSensorData:(SensorData*)data{
    self.receivedDataLabel.text = [[NSString alloc] initWithFormat:@"ax: %ld, ay: %ld, az: %ld", data.x.value, data.y.value, data.z.value ];
}

@end
