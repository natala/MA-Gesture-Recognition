//
//  NZSensorDataHeaders.h
//  BLEDemo
//
//  Created by Natalia Zarawska on 04/05/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef NZ_SENSOR_DATA_HEADERS
#define NZ_SENSOR_DATA_HEADERS

/*!
 * supported heades
 */
extern const uint8_t    kLinearAccelerationX;
extern const NSInteger  kLinearAccelerationXOffset;

extern const uint8_t    kLinearAccelerationY;
extern const NSInteger  kLinearAccelerationYOffset;

extern const uint8_t    kLinearAccelerationZ;
extern const NSInteger  kLinearAccelerationZOffset;

extern const uint8_t    kYaw;
extern const NSInteger  kYawOffset;

extern const uint8_t    kPitch;
extern const NSInteger  kPitchOffset;

extern const uint8_t    kRoll;
extern const NSInteger  kRollOffset;

#endif