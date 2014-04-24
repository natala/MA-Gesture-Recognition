//
//  NZBleConnectionViewController.h
//  BLEDemo
//
//  Created by Natalia Zarawska on 26/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEDiscovery.h"
#import "BLEService.h"
#import "SensorData.h"
#import "NZGraphView.h"

@interface NZBleConnectionViewController : UIViewController

#pragma mark -
#pragma mark properties
#pragma mark - 

@property (weak, nonatomic) IBOutlet UILabel *connectedLabel;

@property (weak, nonatomic) IBOutlet UILabel *receivedDataLabel;

//@property (strong, nonatomic) SensorData *accelerometerData;

#pragma mark - 
#pragma mark methods
#pragma mark -

/*
 * called to update the the accelerometer data
 */
//-(BOOL)extractDataFromBuffer:(uint8_t *)buffer withLength:(NSInteger)length to:(SensorData *)sensorData;

-(void) updateConnectedLabel:(BOOL)connected;

-(void)updateSensorDataTextWithSensorData:(SensorData*)data;

@end
