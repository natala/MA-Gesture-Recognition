//
//  NZGestureRecognitionPipeline.h
//  BLEDemo
//
//  Created by Natalia Zarawska on 13/04/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRT.h"

@interface NZGestureRecognitionPipeline : NSObject <NSCoding>

@property (strong) NSString *pipelineName;

- (void)setClassifier:(NSString *)classifier;
- (BOOL)train:(GRT::LabelledClassificationData &)labelledData;
- (BOOL)test:(GRT::LabelledClassificationData &)testData;
- (int)predict:(GRT::VectorDouble &)data;
- (void)setUpPipeline;

- (BOOL)isTrained;

- (BOOL)savePipelineTo:(NSString *)name;
- (BOOL)loadPipelineFrom:(NSString *)name;

@end