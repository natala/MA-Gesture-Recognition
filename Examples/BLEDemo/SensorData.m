//
//  SensorData.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 12/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "SensorData.h"

@implementation SensorData

@synthesize x,y,z;

-(id)initWithValueHeadersX:(uint8_t) xT Y:(uint8_t) yT Z:(uint8_t) zT{
    if( self = [super init] ){
        self.x = [[SensorDataValue alloc] initWithHeader:xT];
        self.y = [[SensorDataValue alloc] initWithHeader:yT];
        self.z = [[SensorDataValue alloc] initWithHeader:zT];
        return self;
    } else return nil;
}

- (BOOL)sensorDataFromBuffer:(uint8_t *)buffer withLength:(NSInteger)length;
{
    bool readPackage = true;
    // TODO move this to one method of the SensorData class
    if( [self.x setValueFromBuffer:buffer withBufferLength:(int)length ] ){
        // NSLog(@"finished reading X data!");
    } else readPackage = false;
    if( [self.y setValueFromBuffer:buffer withBufferLength:(int)length ] ){
        //NSLog(@"finished reading Y data!");
    } else readPackage = false;
    if( [self.z setValueFromBuffer:buffer withBufferLength:(int)length ] ){
        //NSLog(@"finished reading Z data!");
    } else readPackage = false;

    return readPackage;
}

@end
