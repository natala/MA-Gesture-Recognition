//
//  NZGraphView.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 20/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "NZGraphView.h"
#import "NZGraphViewSegment.h"
#import "NZGraphTextView.h"
#import "NZGraphViewHelper.h"
#import "NZConstants.h"

@implementation NZGraphView

@synthesize visibilityFrame;

//••@synthesize segments, current, text;

// Designated initializer
/*- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self != nil)
	{
		[self commonInit];
	}
	return self;
}*/

// Designated initializer
- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	if (self != nil)
	{
        _maxAxisY = kMaxAxisY;
        _minAxisY = kMinAxisY;
		[self commonInit];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame maxAxisY:(float)maxAxisY minAxisY:(float)minAxisY
{
    self = [super initWithFrame:frame];
    if (self) {
        _maxAxisY = maxAxisY;
        _minAxisY = minAxisY;
        visibilityFrame = frame;
        
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
	
    // Create the text view and add it as a subview. We keep a weak reference
	// to that view afterwards for laying out the segment layers.
    CGRect frame = CGRectMake(0.0, 0.0, kGraphViewLeftAxisWidth, self.frame.size.height);
    _text = [[NZGraphTextView alloc] initWithFrame:frame maxAxisY:self.maxAxisY minAxisY:self.minAxisY];
	[self addSubview:self.text];
	
	// Create a mutable array to store segments, which is required by -addSegment
	_segments = [[NSMutableArray alloc] init];
    
	// Create a new current segment, which is required by -addX:y:z and other methods.
	// This is also a weak reference (we assume that the 'segments' array will keep the strong reference).
	self.current = [self addSegment];
}

- (void)addX:(float)x y:(float)y z:(float)z
{
	// First, add the new acceleration value to the current segment
	if ([self.current addX:x y:y z:z])
	{
		// If after doing that we've filled up the current segment, then we need to
		// determine the next current segment
		[self recycleSegment];
		// And to keep the graph looking continuous, we add the acceleration value to the new segment as well.
		[self.current addX:x y:y z:z];
	}
	// After adding a new data point, we need to advance the x-position of all the segment layers by 1 to
	// create the illusion that the graph is advancing.
	for (NZGraphViewSegment *s in self.segments)
	{
		CGPoint position = s.layer.position;
		position.x += 1.0;
		s.layer.position = position;
	}
}

- (void)addData:(SensorData *)accelerometerData
{
    SensorDataValue *x = accelerometerData.x;
    SensorDataValue *y = accelerometerData.y;
    SensorDataValue *z = accelerometerData.z;
    
    //NSLog(@"%f, %f, %f", x.value*1.0f, y.value*1.0f, z.value*1.0f);
    
    [self addX:x.value y:y.value z:z.value];
}

// The initial position of a segment that is meant to be displayed on the left side of the graph.
// This positioning is meant so that a few entries must be added to the segment's history before it becomes
// visible to the user. This value could be tweaked a little bit with varying results, but the X coordinate
// should never be larger than 16 (the center of the text view) or the zero values in the segment's history
// will be exposed to the user.
//
//#define kSegmentInitialPosition CGPointMake(14.0, 56.0);
//#define kSegmentInitialPosition CGPointMake(0.0, 0.0);

- (NZGraphViewSegment *)addSegment
{
	// Create a new segment and add it to the segments array.
    CGRect frame = CGRectMake(kGraphViewLeftAxisWidth-kGraphSegmentSize-1, 0.0, kGraphSegmentSize-1, self.frame.size.height);
    NZGraphViewSegment *segment = [[NZGraphViewSegment alloc] initWithFrame:frame];
	// We add it at the front of the array because -recycleSegment expects the oldest segment
	// to be at the end of the array. As long as we always insert the youngest segment at the front
	// this will be true.
	[self.segments insertObject:segment atIndex:0];
    // this is now a weak reference
	
	// Ensure that newly added segment layers are placed after the text view's layer so that the text view
	// always renders above the segment layer.
	[self.layer insertSublayer:segment.layer below:self.text.layer];
	// Position it properly (see the comment for kSegmentInitialPosition)
	//segment.layer.position = kSegmentInitialPosition;
    NSLog(@"self.layer.position: %f, %f", self.layer.position.x, self.layer.position.y);
    NSLog(@"segment.layer.position: %f, %f", segment.layer.position.x, segment.layer.position.y);
   // segment.layer.position = kSegmentInitialPosition;
	
	return segment;
}

- (void)recycleSegment
{
	// We start with the last object in the segments array, as it should either be visible onscreen,
	// which indicates that we need more segments, or pushed offscreen which makes it eligable for recycling.
	NZGraphViewSegment *last = [self.segments lastObject];
    CGRect rect = CGRectMake(0.0f, 0.0f, /*self.visibilityFrame.size.width*/self.frame.size.width - kGraphViewAxisLineWidth, self.visibilityFrame.size.height);
	if ([last isVisibleInRect:rect])
	{
		// The last segment is still visible, so create a new segment, which is now the current segment
		self.current = [self addSegment];
	}
	else
	{
		// The last segment is no longer visible, so we reset it in preperation to be recycled.
		[last reset];
		// Position it properly (see the comment for kSegmentInitialPosition)
		//last.layer.position = kSegmentInitialPosition;
        [last resetLayer];
		// Move the segment from the last position in the array to the first position in the array
		// as it is now the youngest segment.
		[self.segments insertObject:last atIndex:0];
		[self.segments removeLastObject];
		// And make it our current segment
		self.current = last;
	}
}

// The graph view itself exists only to draw the background and gridlines. All other content is drawn either into
// the GraphTextView or into a layer managed by a GraphViewSegment.
- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	// Fill in the background
	//CGContextSetFillColorWithColor(context, graphBackgroundColor());
    //## COLOR
    CGContextSetFillColorWithColor(context, CreateDeviceRGBColor(0.0, 1.0, 0.0, 1.0));
	CGContextFillRect(context, self.bounds);
	
	//CGFloat width = self.bounds.size.width;
	//CGContextTranslateCTM(context, 0.0, 56.0);
    
	// Draw the grid lines
	// DrawGridlines(context, 0.0, width);
    
    // Line for max value
    DrawHorizontalLine(context, 0.0, kGraphViewGraphOffsetY + kGraphViewAxisLabelSize.height / 2.0f , self.bounds.size.width);
	// Line for min value
    DrawHorizontalLine(context, 0.0, self.bounds.size.height - kGraphViewGraphOffsetY - kGraphViewAxisLabelSize.height / 2.0f, self.bounds.size.width);
    // Line for 0
    DrawHorizontalLine(context, 0.0, self.bounds.size.height / 2.0f, self.bounds.size.width);
    StrokeLines(context);
}

// Return an up-to-date value for the graph.
- (NSString *)accessibilityValue
{
	if (self.segments.count == 0)
	{
		return nil;
	}
	
	// Let the GraphViewSegment handle its own accessibilityValue;
	NZGraphViewSegment *graphViewSegment = self.segments[0];
	return [graphViewSegment accessibilityValue];
}

-(void) setFrame:(CGRect)frame{
    [super setFrame:frame];
    
    frame = CGRectMake(0.0, 0.0, kGraphViewLeftAxisWidth, self.frame.size.height);
    self.text.frame = frame;
    
    frame = CGRectMake(kGraphViewLeftAxisWidth, 0.0, self.frame.size.width - kGraphViewLeftAxisWidth, self.frame.size.height);
    //TODO: update also the segments
  /*  for (int i = [self.segments count]; i < [self.segments count]; i++) {
        if ([[self.segments objectAtIndex:i] isKindOfClass:[NZGraphViewSegment class]]) {
            NZGraphViewSegment *segement = [self.segments objectAtIndex:i];
            segement.frame = frame;
        }
    }*/
}

-(void) setMaxAxisY:(float)maxAxisY{
    self.maxAxisY = maxAxisY;
    [self.text setNeedsDisplay];
}

-(void) setMinAxisY:(float)minAxisY{
    self.text.minAxisY = minAxisY;
    [self.text setNeedsDisplay];
}


@end
