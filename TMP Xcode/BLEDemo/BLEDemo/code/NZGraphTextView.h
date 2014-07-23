//
//  NZGraphTextView.h
//  BLEDemo
//
//  Created by Natalia Zarawska on 20/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

// We use a seperate view to draw the text for the graph so that we can layer the segment layers below it
// which gives the illusion that the numbers are draw over the graph, and hides the fact that the graph drawing
// for each segment is incomplete until the segment is filled.

#import <UIKit/UIKit.h>

@interface NZGraphTextView : UIView

@property (nonatomic) float maxAxisY;
@property (nonatomic) float minAxisY;

- (id)initWithFrame:(CGRect)frame maxAxisY:(float) maxAxisY minAxisY:(float) minAxisY;

@end
