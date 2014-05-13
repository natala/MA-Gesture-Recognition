//
//  SensorData.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 12/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "SensorData.h"

@implementation SensorData

-(id)initWithValueHeadersX:(uint8_t) x Y:(uint8_t) y Z:(uint8_t) z andOffsetsX:(NSInteger)offsetX Y:(NSInteger)offsetY Z:(NSInteger)offsetZ{
    if( self = [super init] ){
        self.x = [[SensorDataValue alloc] initWithHeader:x andOffset:offsetX];
        self.y = [[SensorDataValue alloc] initWithHeader:y andOffset:offsetY];
        self.z = [[SensorDataValue alloc] initWithHeader:z andOffset:offsetZ];
        self.name = @"undefined";
        self.hasValues = false;
        return self;
    } else return nil;
}


-(id)initWithValueHeadersX:(uint8_t) x Y:(uint8_t) y Z:(uint8_t) z andOffsetsX:(NSInteger)offsetX Y:(NSInteger)offsetY Z:(NSInteger)offsetZ andName:(NSString *)name {
    if( self = [super init] ){
        self.x = [[SensorDataValue alloc] initWithHeader:x andOffset:offsetX];
        self.y = [[SensorDataValue alloc] initWithHeader:y andOffset:offsetY];
        self.z = [[SensorDataValue alloc] initWithHeader:z andOffset:offsetZ];
        self.name = name;
        self.hasValues = false;
        return self;
    } else return nil;

}

- (id)initWithSensorData:(SensorData *)sensorData
{
    if( self = [super init] ){
        self.x = [[SensorDataValue alloc] initWithSensorValue:sensorData.x];
        self.y = [[SensorDataValue alloc] initWithSensorValue:sensorData.y];
        self.z = [[SensorDataValue alloc] initWithSensorValue:sensorData.z];
        self.name = [[NSString alloc] initWithString:sensorData.name];
        self.hasValues = false;
        return self;
    } else return nil;
}

- (BOOL)sensorDataFromBuffer:(uint8_t *)buffer withLength:(NSInteger)length;
{
    bool readPackage = true;
    // TODO: move this to one method of the SensorData class
    
    if( [self.x setValueFromBuffer:buffer withBufferLength:(int)length ] ){
        // NSLog(@"finished reading X data!");
    } else readPackage = false;
    if( [self.y setValueFromBuffer:buffer withBufferLength:(int)length ] ){
        //NSLog(@"finished reading Y data!");
    } else readPackage = false;
    if( [self.z setValueFromBuffer:buffer withBufferLength:(int)length ] ){
        //NSLog(@"finished reading Z data!");
    } else readPackage = false;
    
    self.hasValues = readPackage;
    return readPackage;
}

@end
