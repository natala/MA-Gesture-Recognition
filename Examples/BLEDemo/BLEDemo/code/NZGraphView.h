//
//  NZGraphView.h
//  BLEDemo
//
//  Created by Natalia Zarawska on 20/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SensorData.h"

@class NZGraphTextView;
@class NZGraphViewSegment;

@interface NZGraphView : UIView

@property (nonatomic, strong) NSMutableArray *segments;
@property (nonatomic, unsafe_unretained) NZGraphViewSegment *current;
@property (nonatomic) NZGraphTextView *text;
@property (nonatomic) float maxAxisY;
@property (nonatomic) float minAxisY;
@property (nonatomic) CGRect visibilityFrame;


- (id)initWithFrame:(CGRect)frame maxAxisY:(float)maxAxisY minAxisY:(float)minAxisY;
- (void)addX:(float)x y:(float)y z:(float)z;
- (void)addData:(SensorData*) accelerometerData;

/*-(void) start;
-(void) stop;
 */

@end
