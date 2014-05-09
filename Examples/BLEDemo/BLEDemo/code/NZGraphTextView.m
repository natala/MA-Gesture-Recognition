//
//  NZGraphTextView.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 20/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "NZGraphTextView.h"
#import "NZGraphViewHelper.h"
#import "NZConstants.h"

@implementation NZGraphTextView


- (id)initWithFrame:(CGRect)frame maxAxisY:(float)maxAxisY minAxisY:(float)minAxisY
{
    self = [super initWithFrame:frame];
    if (self) {
        _maxAxisY = maxAxisY;
        _minAxisY = minAxisY;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
    NSLog(@"%@", context);
	
	// Fill in the background
	//CGContextSetFillColorWithColor(context, graphBackgroundColor());
    //## COLOR
    CGContextSetFillColorWithColor(context, CreateDeviceRGBColor(0.0, 0.0, 1.0, 1.0));
	CGContextFillRect(context, self.bounds);
	
	//CGContextTranslateCTM(context, 0.0, 56.0);
    
	// Draw the grid lines
	//DrawGridlines(context, 26.0, 6.0);
    // Draw the grid lines
    // Draw the text
	UIFont *systemFont = [UIFont systemFontOfSize:8.0];
	[[UIColor whiteColor] set];
    float height = self.frame.size.height;
    
    // Line for min value
    DrawHorizontalLine(context, kGraphViewAxisLabelSize.width, kGraphViewGraphOffsetY + kGraphViewAxisLabelSize.height / 2.0f , kGraphViewAxisLineWidth);
	// Line for max value
    DrawHorizontalLine(context, kGraphViewAxisLabelSize.width, height - kGraphViewGraphOffsetY - kGraphViewAxisLabelSize.height / 2.0f, kGraphViewAxisLineWidth);
    // Line for 0 value
    DrawHorizontalLine(context, kGraphViewAxisLabelSize.width, height / 2.0f, kGraphViewAxisLineWidth);
    StrokeLines(context);
    
    NSString * topValue     = [NSString stringWithFormat:@"%d",(int)(self.maxAxisY/*/kNormalizationAxisY*/)];
    NSString * zero         = [NSString stringWithFormat:@"%d", 0];
    NSString * bottomValue  = [NSString stringWithFormat:@"%d",(int)(self.minAxisY/*/kNormalizationAxisY*/)];
    
    CGRect rect1 = CGRectMake(0.0, kGraphViewGraphOffsetY*1.5f, kGraphViewAxisLabelSize.width, kGraphViewAxisLabelSize.height);
    [topValue drawInRect:rect1 withFont:systemFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentRight];
    rect1 = CGRectMake(0.0, height/2.0f - kGraphViewGraphOffsetY, kGraphViewAxisLabelSize.width, kGraphViewAxisLabelSize.height);
    [zero drawInRect:rect1 withFont:systemFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentRight];
    rect1 = CGRectMake(0.0, height - kGraphViewGraphOffsetY/2.0f - kGraphViewAxisLabelSize.height, kGraphViewAxisLabelSize.width, kGraphViewAxisLabelSize.height);
    [bottomValue drawInRect:rect1 withFont:systemFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentRight];
}

@end
