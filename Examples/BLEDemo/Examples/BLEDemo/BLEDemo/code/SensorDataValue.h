//
//  SensorDataValue.h
//  BLEDemo
//
//  Created by Natalia Zarawska on 12/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SensorDataValue : NSObject
{}

@property (strong, nonatomic) NSNumber *value;
@property (nonatomic) uint8_t header;
@property (strong, nonatomic) NSNumber *bytesNumber;

-(id)initWithHeader:(uint8_t) header andBytesLength: (int)valueLength;

-(uint8_t)headerWithLength:(NSNumber *)lenght;

/*!
 * returns true if value found
 */
-(BOOL)readValueFromBuffer:(uint8_t *)buffer withBufferLength:(int) length;

@end
