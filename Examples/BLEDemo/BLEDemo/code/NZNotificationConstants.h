//
//  NZNotificationConstants.h
//  BLEDemo
//
//  Created by Natalia Zarawska on 14/04/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import <Foundation/Foundation.h>

// BLEDelegate
extern NSString * const NZDidReceiveSensorDataNotification;
extern NSString * const NZDidConnectToBle;

// NZClassificationController
extern NSString * const NZDidFinishTrainingClassifierNotification;
extern NSString * const NZClassificationControllerAddedDataNotification;
extern NSString * const NZClassificationControllerFinishedTrainingNotification;
extern NSString * const NZClassificationControllerDidLoadSavedDataNotification;
extern NSString * const NZClassificationControllerDidAddClassLabel;
extern NSString * const NZClassificationControllerDidPredictClassNotification;

// NZTrainingViewController
extern NSString * const NZTrainingVCDidAddClassLabelNotification;
extern NSString * const NZTrainingVCDidTapRecordButtonNotification;
extern NSString * const NZTrainingVCDidTapSaveLabelledDataButtonNotification;
extern NSString * const NZTrainingVCDidTapTrainClassifierButtonNotification;

// NZClassifyViewController
extern NSString * const NZClassifyVCDidTapClassifyButtonNotification;

// NZMyClassesViewController
extern NSString * const NZLoadSavedDataTappedNotification;

// userInfo dictionary keyes
extern NSString * const NZAccelerationDataKey;
extern NSString * const NZOrientationDataKey;
extern NSString * const NZStartStopButtonStateKey;
extern NSString * const NZNumOfRecordedDataKey;
extern NSString * const NZClassifierStatusKey;
extern NSString * const NZClassifierStatisticsKey;
extern NSString * const NZNumOfClassLabelsKey;
extern NSString * const NZIsTrainedKey;
extern NSString * const NZPredictedClassLabelKey;
extern NSString * const NZSomeTextKey;