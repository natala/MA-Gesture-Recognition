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

@property (nonatomic) NSInteger value;
@property (nonatomic) uint8_t header;
@property (strong, nonatomic) NSNumber *bytesNumber;

/*!
 * for later
 */
-(id)initWithHeader:(uint8_t) header andBytesLength: (int)valueLength;
-(uint8_t)headerWithLength:(NSNumber *)lenght;

/*!
 * 
 */
-(id)initWithHeader:(uint8_t) header;


/*!
 * returns true if value found
 */
-(BOOL)setValueFromBuffer:(uint8_t *)buffer withBufferLength:(int) length;

/*!
 * @param buffer the buffer from which the bytes will be read to initiate the number
 * @param offset indicates where in the buffer to start
 */
+(NSInteger)intFromTwoBytes:(uint8_t*) buffer offset:(NSInteger) offset;

@end
