//
//  NZGraphViewSegment.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 20/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "NZGraphViewSegment.h"
#import "NZConstants.h"

@implementation NZGraphViewSegment


- (id)initWithFrame:(CGRect) frame maxY:(float)maxY andMinY:(float)minY
{
    self = [super init];
	if (self != nil) {
		_layer = [[CALayer alloc] init];
		_layer.delegate = self;
        _layer.frame = frame;
        _height = frame.size.height;
        _minY = minY;
        _maxY = maxY;
		//layer.opaque = YES;
		index = kGraphSegmentSize;
 //       NSLog(@"SegmentHeight: %f", _height);
	}
	return self;
}

/*
- (void)setFrame:(CGRect)frame
{
    _frame = frame;
    _height = frame.size.height;
    //layer.bounds = CGRectMake(0.0, - self.height - kGraphViewGraphOffsetY, kGraphSegmentSize, height);
    layer.bounds = CGRectMake(0.0, - _height, kGraphSegmentSize, _height);
    layer.position = CGPointMake(layer.bounds.origin.x, layer.bounds.origin.y*2.0f);
}*/

- (void)resetLayer
{
    CGRect frame = self.layer.frame;
    frame.origin = CGPointMake(kGraphViewLeftAxisWidth-kGraphSegmentSize, 0.0);
    self.layer.frame = frame;
}

- (void)reset
{
	// Clear out our components and reset the index to kSegmentSize to start filling values again...
	memset(xHistory, 0, sizeof(xHistory));
	memset(yHistory, 0, sizeof(yHistory));
	memset(zHistory, 0, sizeof(zHistory));
	index = kSegmentSize;
	// Inform Core Animation that we need to redraw this layer.
	[self.layer setNeedsDisplay];
}

- (BOOL)isFull
{
	// Simple, this segment is full if there are no more space in the history.
	return index == 0;
}

- (BOOL)isVisibleInRect:(CGRect)r
{
	// Just check if there is an intersection between the layer's frame and the given rect.
	return CGRectIntersectsRect(r, self.layer.frame);
}

- (BOOL)addX:(float)x y:(float)y z:(float)z
{
	// If this segment is not full, then we add a new acceleration value to the history.
	if (index > 0)
	{
		// First decrement, both to get to a zero-based index and to flag one fewer position left
		--index;
		xHistory[index] = x;
		yHistory[index] = y;
		zHistory[index] = z;
		// And inform Core Animation to redraw the layer.
		[self.layer setNeedsDisplay];
	}
	// And return if we are now full or not (really just avoids needing to call isFull after adding a value).
	return index == 0;
}

- (void)drawLayer:(CALayer*)l inContext:(CGContextRef)context
{
	// Fill in the background
	CGContextSetFillColorWithColor(context, graphBackgroundColor());
    // ## COLOR
    //CGContextSetFillColorWithColor(context, CreateDeviceRGBColor(1.0, 1.0, 1.0, 1.0));
	CGContextFillRect(context, self.layer.bounds);
	
    // Line for max value
    DrawHorizontalLine(context, 0.0, kGraphViewGraphOffsetY + kGraphViewAxisLabelSize.height / 2.0f, kGraphSegmentSize*1.0f);
    // Line for min value
    DrawHorizontalLine(context, 0.0, _height - kGraphViewGraphOffsetY - kGraphViewAxisLabelSize.height / 2.0f, kGraphSegmentSize*1.0f);
    // Line for 0
    DrawHorizontalLine(context, 0.0, _height / 2.0f, kGraphSegmentSize*1.0f);
    StrokeLines(context);
    
	// Draw the graph
	CGPoint lines[(kGraphSegmentSize-1)*2];
	int i;
    float offset = kGraphViewGraphOffsetY + kGraphViewAxisLabelSize.height / 2.0f;
    float resolution = (abs(self.maxY) + abs(self.maxY)) / (_height - offset*2.0f);
    
	// X
	for (i = 0; i < kGraphSegmentSize-1; ++i)
	{
		lines[i*2].x = i;
		lines[i*2+1].x = i + 1;
        lines[i*2].y = _height/2.0f - xHistory[i] / resolution;
        lines[i*2+1].y = _height/2.0f - xHistory[i+1] / resolution;
	}
	CGContextSetStrokeColorWithColor(context, graphXColor());
	CGContextStrokeLineSegments(context, lines, (kGraphSegmentSize-1)*2);
    
    // Y
	for (i = 0; i < kGraphSegmentSize-1; ++i)
	{
        lines[i*2].y = _height/2.0f - yHistory[i] / resolution;
        lines[i*2+1].y = _height/2.0f - yHistory[i+1] / resolution;
	}
	CGContextSetStrokeColorWithColor(context, graphYColor());
	CGContextStrokeLineSegments(context, lines, (kGraphSegmentSize-1)*2);
    
	// Z
	for (i = 0; i < kGraphSegmentSize-1; ++i)
	{
        lines[i*2].y = _height/2.0f - zHistory[i] / resolution;
        lines[i*2+1].y = _height/2.0f - zHistory[i+1] / resolution;
	}
	CGContextSetStrokeColorWithColor(context, graphZColor());
	CGContextStrokeLineSegments(context, lines, (kGraphSegmentSize-1)*2);
}


- (id)actionForLayer:(CALayer *)layer forKey :(NSString *)key
{
	// We disable all actions for the layer, so no content cross fades, no implicit animation on moves, etc.
	return [NSNull null];
}

// The accessibilityValue of this segment should be the x,y,z values last added.
- (NSString *)accessibilityValue
{
	return [NSString stringWithFormat:NSLocalizedString(@"graphSegmentFormat", @""), xHistory[index], yHistory[index], zHistory[index]];
}


@end
