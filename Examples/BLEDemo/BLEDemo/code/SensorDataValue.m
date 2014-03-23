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

/*-(id)initWithHeader:(uint8_t) header andBytesLength: (int)valueLength{
    if ( self = [super init] ) {
        self.header = header;
        self.bytesNumber = [[NSNumber alloc] initWithInt:valueLength];
        return self;
    } else return nil;
}*/


/*
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
*/

-(id)initWithHeader:(uint8_t) header{
    if ( self = [super init] ) {
        self.header = header;
        self.bytesNumber = [[NSNumber alloc] initWithInt:2];
        return self;
    } else return nil;
}

-(BOOL)setValueFromBuffer:(uint8_t *)buffer withBufferLength:(int) length{
    if( length < [self.bytesNumber integerValue])
        return false;
    int headerLength = 1;
    for (int i = 0; (i + headerLength + [self.bytesNumber integerValue]) <= length; i++) {
        if(buffer[i] == header){
            self.value = [[self class] intFromTwoBytes:buffer offset:(i+1)];
            return true;
        }
    }
    return false;
}

/*
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
}*/

/******** helper functions ***********/
+(NSInteger) intFromTwoBytes:(uint8_t*) buffer offset:(NSInteger) offset{
    
    uint8_t low = buffer[offset];
    uint8_t high = buffer[offset+1];
    int val = ((high << 8 | low) - 32768);
    return val;
}
 

@end
