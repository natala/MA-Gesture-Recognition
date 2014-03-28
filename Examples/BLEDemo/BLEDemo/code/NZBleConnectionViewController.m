//
//  NZBleConnectionViewController.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 26/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "NZBleConnectionViewController.h"

@interface NZBleConnectionViewController ()

@property (nonatomic,weak) UIPanGestureRecognizer *panRecognizer;

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
    /*[BLEDiscovery sharedInstance].peripheralDelegate = self;
    [BLEDiscovery sharedInstance].discoveryDelegate = self;
    [[BLEDiscovery sharedInstance] startScanningForSupportedUUIDs];
    self.accelerometerData = [[SensorData alloc] initWithValueHeadersX:'x' Y:'y' Z:'z'];*/
    
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
    }/*
    if([BLEDiscovery sharedInstance].connectedService){
        self.connectedLabel.text = @"CONNECTED";
    } else {
        self.connectedLabel.text = @"NOT CONNECTED";
    }*/
}

-(BOOL)extractDataFromBuffer:(uint8_t *)buffer withLength:(NSInteger)length to:(SensorData *)sensorData{
    if (!sensorData) {
        return false;
    }
    bool readPackage = true;
    // TODO move this to one method of the SensorData class
    if( [sensorData.x setValueFromBuffer:buffer withBufferLength:length ] ){
        NSLog(@"finished reading X data!");
    } else readPackage = false;
    if( [sensorData.y setValueFromBuffer:buffer withBufferLength:length ] ){
        NSLog(@"finished reading Y data!");
    } else readPackage = false;
    if( [sensorData.z setValueFromBuffer:buffer withBufferLength:length ] ){
        NSLog(@"finished reading Z data!");
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


#pragma mark -
#pragma mark BleServiceDataDelegate
#pragma mark -
/*
-(void) didReceiveData:(uint8_t *)buffer lenght:(NSInteger)length{
    bool readPackage = true;
    // TODO move this to one method of the SensorData class
    if( [self.accelerometerData.x setValueFromBuffer:buffer withBufferLength:length ] ){
        NSLog(@"finished reading X data!");
    } else readPackage = false;
    if( [self.accelerometerData.y setValueFromBuffer:buffer withBufferLength:length ] ){
        NSLog(@"finished reading Y data!");
    } else readPackage = false;
    if( [self.accelerometerData.z setValueFromBuffer:buffer withBufferLength:length ] ){
        NSLog(@"finished reading Z data!");
    } else readPackage = false;
    
    if (readPackage) {
        [self updateSensorDataTextWithSensorData:];
        // Update the accelerometer graph view
      //  if (!isPaused)
      //  {
      //      [accelerometerView addData:accelerometerData];
      //  }
    }
    
    */
    /*  int16_t accData[3];
     //NSMutableArray *accelerometerData = [NSMutableArray arrayWithObjects:0,0,0, nil]; // the received accelerometer data
     NSString * text = @"";
     for (int i = 0 ; i < length ; i++) {
     uint8_t val = buffer[i];
     
     if((val == a) && (i+12 < length)){    // start reading accelerometer data
     NSLog(@"start");
     i++;
     accData[0] = [self readAccelerometerValueFrom:buffer atIndex:i andBufferLength:length];
     i = i+4;
     accData[1] = [self readAccelerometerValueFrom:buffer atIndex:i andBufferLength:length];
     i = i+4;
     accData[2] = [self readAccelerometerValueFrom:buffer atIndex:i andBufferLength:length];
     i = i+4;
     if( accData[0] && accData[1] && accData[2]);
     
     //val = buffer[i];
     // if( val == 'z' ){
     NSLog(@"end of data");
     text = [text stringByAppendingFormat:@"ax: %d \n ay: %d \n az: %d ",accData[0],accData[1],accData[2]];
     // }
     
     */
    // NSLog(@"uint16 %d", value);
    // NSLog(@"int16 %d", (int16_t)value);
    /* NSString *strTmp = @"";
     NSMutableString *str = [strTmp mutableCopy];
     for(NSInteger numberCopy = value; numberCopy > 0; numberCopy >>= 1)
     {
     // Prepend "0" or "1", depending on the bit
     [str insertString:((numberCopy & 1) ? @"1" : @"0") atIndex:0];
     }
     NSLog(@"in binary %@", str);
     */
    
    
    
    // }
    //  }
    
    // NSLog(@"**********");
    
    //NSLog(@"%@",text);
    //self.receivedLabel.text = text;
//}

-(void)updateSensorDataTextWithSensorData:(SensorData*)data{
    self.receivedDataLabel.text = [[NSString alloc] initWithFormat:@"ax: %d, ay: %d, az: %d", data.x.value, data.y.value, data.z.value ];
}

/*-(void)updateSensorDataText{
    self.receivedDataLabel.text = [[NSString alloc] initWithFormat:@"ax: %d, ay: %d, az: %d", self.accelerometerData.x.value, self.accelerometerData.y.value, self.accelerometerData.z.value ];
}*/

#pragma mark -
#pragma mark BleDiscoveryDelegate
#pragma mark -
/*
- (void) discoveryDidRefresh {
}

- (void) peripheralDiscovered:(CBPeripheral*) peripheral {
    //    [BLEDiscovery sharedInstance].supportedServiceUUIDs
    if([BLEDiscovery sharedInstance].connectedService == nil){
        [[BLEDiscovery sharedInstance] connectPeripheral:peripheral];
    }
}

- (void) discoveryStatePoweredOff {
}

#pragma mark -
#pragma mark BleServiceProtocol
#pragma mark -

-(void) bleServiceDidConnect:(BLEService *)service{
    service.delegate = self;
    service.dataDelegate = self;
    [self updateConnectedLabel];
}

-(void) bleServiceDidDisconnect:(BLEService *)service{
    [self updateConnectedLabel];
}

-(void) bleServiceIsReady:(BLEService *)service{
    
}

-(void) bleServiceDidReset {
}

-(void) reportMessage:(NSString*) message{
}
*/

@end
