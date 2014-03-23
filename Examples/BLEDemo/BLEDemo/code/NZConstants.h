//
//  NZConstants.h
//  BLEDemo
//
//  Created by Natalia Zarawska on 20/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef NZ_CONSTANTS
#define NZ_CONSTANTS

#define kUpdateFrequency        60.0
#define kLocalizedPause         NSLocalizedString(@"Pause","pause taking samples")
#define kLocalizedResume        NSLocalizedString(@"Resume","resume taking samples")
#define kSegmentSize            33
#define kGraphViewLeftAxisWidth 42.0
#define kGraphSegmentSize       33


extern CGSize   const kGraphViewAxisLabelSize;
//the distance between min and max axis labes
extern float    const kGraphViewGraphOffsetY;
extern float    const kGraphViewAxisLineWidth;

//defines the positon and size of the GraphView within the View Controller
extern CGRect   const kGraphViewPosition;
extern int      const kMaxAxisY;
extern int      const kMinAxisY;
extern int      const kNormalizationAxisY;

#endif