//
//  SensorDataValue.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 12/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "SensorDataValue.h"

@implementation SensorDataValue

@synthesize value, header, bytesNumber;

-(id)initWithHeader:(uint8_t) header andBytesLength: (int)valueLength{
    if ( self = [super init] ) {
        self.header = header;
        self.bytesNumber = [[NSNumber alloc] initWithInt:valueLength];
        return self;
    } else return nil;
}

-(uint8_t)headerWithLength:(NSNumber *)lenght{
    if (self.header) {
        //NSData *data = [self.header dataUsingEncoding:NSUTF8StringEncoding];
        //lenght = [[NSNumber alloc] initWithInt:self.header.length ];
        //const void *bytes = [data bytes];
        //return (uint8_t*)bytes;
        lenght = [[NSNumber alloc] initWithInt:1];
        NSLog(@"for now only 1 char for header");
        return self.header;
    } else return nil;
}


-(BOOL)readValueFromBuffer:(uint8_t *)buffer withBufferLength:(int) length{
    if( length < [self.bytesNumber integerValue])
        return false;
    
    bool retValue = false;
    NSNumber *headerLength = [[NSNumber alloc] initWithInt:1];
    uint8_t header = [self headerWithLength:headerLength];
    uint8_t headerArray[ [headerLength integerValue] ];
    headerArray[0] = header;
    for (int i = 0; (i + [headerLength integerValue] + [self.bytesNumber integerValue]) <= length && !retValue; i++) {
        bool equal = true;
        for (int k = 0; k < [headerLength integerValue] && equal; k++) {
            if (buffer[i+k] != headerArray[k]) {
                equal = false;
            }
        }
        // read the value
        if (equal) {
            i++;
            self.value = [self readFromBuffer:buffer withLength:length atIndex:i];
            if (self.value) {
                return true;
            } else return false;
        }
    }
}

-(NSNumber*)readFromBuffer:(uint8_t*) buffer withLength:(int) length atIndex:(int) index{
    if( index + [self.bytesNumber integerValue] >= length )
        return nil;
    
    if( [self.bytesNumber integerValue] > 2 ){
        NSLog(@"For now we suppoer only 2 byte long values!!! ");
        return nil;
    }
    uint8_t valuePart[[self.bytesNumber integerValue]];
    int16_t value;
    NSLog(@"header: %d", buffer[index]);
    // for now I assume that it is 2 and not more
    for (int k = 0; k < [self.bytesNumber integerValue]; k++) {
        valuePart[k] = buffer[index+k];
        NSLog(@"%d", valuePart[k]);
    }
     NSLog(@"%d", buffer[index+2]);
     NSLog(@"%d", buffer[index+3]);
    if ([self.bytesNumber integerValue] ==  1 ) {
        value = (int16_t)((uint16_t)valuePart[0]);
    }
    else if( [self.bytesNumber integerValue] == 2 ){
        value = (int16_t)((uint16_t)valuePart[0]) | ((uint16_t)valuePart[1] << 8);
    }
    
    NSLog(@"value: %d", value);
    return [[NSNumber alloc] initWithInt:(int)value];

}

@end
