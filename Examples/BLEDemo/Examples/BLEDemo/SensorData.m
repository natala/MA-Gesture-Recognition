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

-(id)initWithValueHeaderX:(uint8_t) xT Y:(uint8_t) yT Z:(uint8_t) zT{
    if( self = [super init] ){
        self.x = [[SensorDataValue alloc] initWithHeader:xT andBytesLength:2];
        self.y = [[SensorDataValue alloc] initWithHeader:yT andBytesLength:2];
        self.z = [[SensorDataValue alloc] initWithHeader:zT andBytesLength:2];
        return self;
    } else return nil;
}

@end
