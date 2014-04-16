//
//  NZClassificationController.h
//  BLEDemo
//
//  Created by Natalia Zarawska on 06/04/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SensorData.h"

@interface NZClassificationController : NSObject

@property (strong, nonatomic) NSString *datasetName;

- (void)addData:(SensorData *)data withLabel:(NSString *)classLabel;

// adds data with the label that is at the and of the classLabels
- (void)addData:(SensorData *)data;
- (void)addClassLabel:(NSString *)classLabel;

// returns true if managed to train classifier, fals if training failed
//- ()trainClassifier;

- (void)setUpPipeline;

- (NSString *)predict:(SensorData *)data;

- (BOOL)saveLabelledDataToCSVFile;
- (BOOL)loadLabelledDataFromCSVFile;

- (NSNumber *)numberOfDataSamples;
- (NSNumber *)numberOfClasses;
- (NSDictionary *)numberOfSamplesPerClass;
- (BOOL)isTrained;

@end    