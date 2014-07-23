//
//  SensorData.h
//  BLEDemo
//
//  Created by Natalia Zarawska on 12/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SensorDataValue.h"

@interface SensorData : NSObject
{}

@property (strong, nonatomic) SensorDataValue *x;
@property (strong, nonatomic) SensorDataValue *y;
@property (strong, nonatomic) SensorDataValue *z;

-(id)initWithValueHeaderX:(uint8_t) _x Y:(uint8_t) _y Z:(uint8_t) _z;

@end
