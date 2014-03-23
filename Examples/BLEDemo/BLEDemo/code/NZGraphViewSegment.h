//
//  NZGraphViewSegment.h
//  BLEDemo
//
//  Created by Natalia Zarawska on 20/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

// The GraphViewSegment manages up to 32 accelerometer values and a CALayer that it updates with
// the segment of the graph that those values represent.

#import <Foundation/Foundation.h>
#import "NZGraphViewHelper.h"
#import "NZConstants.h"

@interface NZGraphViewSegment : NSObject {
    float xHistory[kSegmentSize];
    float yHistory[kSegmentSize];
    float zHistory[kSegmentSize];
    int index;
    //CGPoint lines[(kGraphSegmentSize-1)*2];
}

@property (nonatomic, readonly) CALayer *layer;
@property (nonatomic) float height;
//@property (nonatomic) CGRect frame;

//- (id)initWithHeight:(float) height;
- (id)initWithFrame:(CGRect) frame;
- (BOOL)addX:(float)x y:(float)y z:(float)z;
- (void)reset;
- (BOOL)isFull;
- (BOOL)isVisibleInRect:(CGRect) r;
- (void)resetLayer;

@end
