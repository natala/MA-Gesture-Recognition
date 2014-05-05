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

/*! \brief offset in the buffer
 *
 */
@property (nonatomic) NSInteger offset;

@property (strong, nonatomic) NSNumber *value;

/*! \brief indicated where to start processinf the buffer
 *  supported headers are defined in NZSensorDataHeaders.h
 */
@property (nonatomic) uint8_t header;

/*! \brief
 *
 */
//@property (nonatomic) NSInteger bytesNumber;

/*! \brief name of the sensor data. For example "Linear Acceleration X"
 *
 */
@property (strong, nonatomic) NSString *name;

/*!
 * for later
 */
//-(id)initWithHeader:(uint8_t) header andBytesLength: (int)valueLength;
//-(uint8_t)headerWithLength:(NSNumber *)lenght;

/*! \brief initialize with a given header
 *  @param header the header indicating where to start extracting data form buffer
 *  @param offset indicates where in the header should start reading the value
 */
- (id)initWithHeader:(uint8_t)header andOffset:(NSInteger)offset;

/*! \brief initialize with a given header and value name
 * @param header the header indicating where to start extracting data form buffer
 * @param offset indicates where in the header should start reading the value
 * @param name the name of the value
 */
- (id)initWithHeader:(uint8_t)header andOffset:(NSInteger)offset andName:(NSString *)name;

/*! \brief set the value of the sensor data
 * @param buffer the received buffer from which to extract
 * @param length the length of the buffer
 * @return if succeeded
 */
-(BOOL)setValueFromBuffer:(uint8_t *)buffer withBufferLength:(int) length;

/*!
 * @param buffer the buffer from which the bytes will be read to initiate the number
 * @param offset indicates where in the buffer to start
 */
//+(NSInteger)intFromTwoBytes:(uint8_t*) buffer offset:(NSInteger) offset;

@end
