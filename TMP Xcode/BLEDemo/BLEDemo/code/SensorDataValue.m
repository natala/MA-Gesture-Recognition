//
//  SensorDataValue.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 12/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "SensorDataValue.h"

@implementation SensorDataValue

- (id)initWithHeader:(uint8_t)header andOffset:(NSInteger)offset{
    if ( self = [super init] ) {
        self.header = header;
        self.name = @"undefined";
        self.offset = offset;
        //self.bytesNumber = [[NSNumber alloc] initWithInt:2];
        return self;
    } else return nil;
}

- (id)initWithHeader:(uint8_t)header andOffset:(NSInteger)offset andName:(NSString *)name{
    if (self = [super init]) {
        self.header = header;
        self.name = name;
        self.offset = offset;
        return self;
    } else return nil;
}

- (id)initWithSensorValue:(SensorDataValue *)sensorValue {
    if (self = [super init]) {
        self.header = sensorValue.header;
        self.name = [[NSString alloc] initWithString:sensorValue.name];
        self.offset = sensorValue.offset;
        self.value = [[NSNumber alloc] initWithInteger:[sensorValue.value integerValue]];
        return self;
    } else return nil;
}

-(BOOL)setValueFromBuffer:(uint8_t *)buffer withBufferLength:(int) length{
    
    // check if at least header and value length is there
    if (length < 2) {
        return false;
    }
   // if( length < [self.bytesNumber integerValue])
   //     return false;
    for (int i = 0; i < length; i++) {
        if ((buffer[i] == self.header) && (i == self.offset)) {
            self.value = [[self class] initValueFormBuffer:buffer withLength:length andOffset:(i+1)];
            if (self.value) {
                return true;
            }
        }
    }
    return false;
}

#pragma mark -
#pragma mark Class Functions - Helpers
#pragma mark -

+ (NSNumber *)initValueFormBuffer:(uint8_t *)buffer withLength:(NSInteger)length andOffset:(NSInteger)offset {
    if (length < offset+1) {
        return nil;
    }
    
    int valLength   = buffer[offset];
    if (length < offset+1+valLength+1) {
        return nil;
    }

#warning add int the data package the info about the value type [if floar or int16]
    // 2 - we asume it is a iny16_t, else it is a float
   // if (valLength == 2) {
        NSNumber *val = [NSNumber numberWithInteger:[[self class]intFromBuffer:buffer withOffset:(offset+1) andLength:valLength]];
        return val;
    //}
    
    //NSNumber *val = [NSNumber numberWithFloat:[[self class] floatFromBuffer:buffer withOffset:(offset+1) andLength:valLength]];
   //return val;
}

+ (NSInteger)intFromBuffer:(uint8_t *)buffer withOffset:(NSInteger)offset andLength:(NSInteger)valLength {
    
    int isNegative = buffer[offset];
    NSInteger intVal;
    
#warning fix it so that the length can be different than 2
    uint8_t low = buffer[offset+1];
    uint8_t high = buffer[offset+2];
    intVal = (high << 8 | low);
    if (isNegative) {
        intVal= (-intVal)-1;
    }
    //memcpy(&intVal, &(buffer[offset+1]), valLength);
    return intVal;
}

+ (NSInteger)floatFromBuffer:(uint8_t *)buffer withOffset:(NSInteger)offset andLength:(NSInteger)valLength {
    
    int isNegative = buffer[offset];
    float floatVal;
#warning fix it so that the length can be different than 4
    uint16_t low   = (buffer[offset+2] << 8 | buffer[offset+1]);
    uint16_t high  = (buffer[offset+4] << 8 | buffer[offset+3]);
    floatVal = (high << 16 | low);
   // memcpy(&floatVal, &(buffer[offset+1]), valLength);
    if (isNegative) {
        floatVal = -floatVal;
    }
    return floatVal;
}

/*
+(NSInteger) intFromTwoBytes:(uint8_t *)buffer offset:(NSInteger)offset{
    // check the first byte for the sign indicator
    
    if (buffer[offset-1] == 'x') {
        NSInteger valLength = buffer[offset];
        float val = [SensorDataValue floatFromBuffer:buffer offset:(offset+1) length:valLength];
    }
    
    int isNegativ = buffer[offset];
    
    uint8_t low = buffer[offset+1];
    uint8_t high = buffer[offset+2];
    int value = (high << 8 | low);
    if (isNegativ) {
        value = (-value)-1;
    }
    return value;
}

+(float) floatFromBuffer:(uint8_t *)buffer offset:(NSInteger)offset length:(NSInteger) length
{
    int isNegative = buffer[offset];
    float floatValue;
    memcpy(&floatValue, &(buffer[offset+1]), length);
    if (isNegative) {
        floatValue = -floatValue;
    }
    for (int i = offset+1; i < length; i++) {
        NSLog(@"%d", buffer[i]);
    }
    
    return floatValue;
}*/
 

@end
