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

typedef enum classifierControllerStates {
    INITIAL_STATE       = 0,
    RECORDING_SAMPLES   = 1,
    PREDICTING          = 2
} ClassifierControllerStates;

@property (strong, nonatomic) NSString *datasetName;
@property ClassifierControllerStates state;
@property (strong, nonatomic) NSString *lastPredictedLabel;

- (void)addAcceleration:(SensorData *)acceleration andOrientation:(SensorData *)orientation withLabel:(NSString *)classLabel;

// adds data with the label that is at the and of the classLabels
- (void)addAcceleration:(SensorData *)acceleration andOrientation:(SensorData *)orientation;
- (void)addClassLabel:(NSString *)classLabel;
- (BOOL)saveClassLabels;
- (BOOL)loadClassLabels;

// returns true if managed to train classifier, fals if training failed
//- ()trainClassifier;

- (void)setUpPipeline;

//- (NSString *)predict:(SensorData *)data;
- (NSString *)predictUsingAcceleration:(SensorData *)acceleration andOrientation:(SensorData *)orientation;

- (BOOL)saveLabelledDataToCSVFile;
- (BOOL)loadLabelledDataFromCSVFile;

- (NSNumber *)numberOfDataSamples;
- (NSNumber *)numberOfClasses;
- (NSDictionary *)numberOfSamplesPerClass;
- (BOOL)isTrained;

@end    