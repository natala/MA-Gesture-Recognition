//
//  NZNotificationConstants.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 14/04/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "NZNotificationConstants.h"

// BLEDelegate
NSString * const NZDidReceiveSensorDataNotification                     = @"NZDidReceiveSensorDataNotification";
NSString * const NZDidConnectToBle = @"NZDidConnectToBleNotification";


// NZClassificationController
NSString * const NZDidFinishTrainingClassifierNotification              = @"NZDidFinishTrainingClassifierNotification";
NSString * const NZClassificationControllerAddedDataNotification        = @"NZClassificationControllerAddedDataNotification";
NSString * const NZClassificationControllerFinishedTrainingNotification = @"NZClassificationControllerFinishedTrainingNotification";
NSString * const NZClassificationControllerDidLoadSavedDataNotification     = @"NZClassificationControllerDidLoadSavedDataNotification";
NSString * const NZClassificationControllerDidAddClassLabel = @"NZClassificationControllerDidAddClassLabel";
NSString * const NZClassificationControllerDidPredictClassNotification = @"NZClassificationControllerDidPredictClassNotification";

// NZTrainingViewController
NSString * const NZTrainingVCDidAddClassLabelNotification               = @"NZTrainingVCDidAddClassLabelNotification";
NSString * const NZTrainingVCDidTapRecordButtonNotification             = @"NZTrainingVCDidTapRecordButtonNotification";
NSString * const NZTrainingVCDidTapSaveLabelledDataButtonNotification   = @"NZTrainingVCDidTapSaveLabelledDataButtonNotification";
NSString * const NZTrainingVCDidTapTrainClassifierButtonNotification    = @"NZTrainingVCDidTapTrainClassifierButtonNotification";

// NZClassifyViewController
NSString * const NZClassifyVCDidTapClassifyButtonNotification           = @"NZClassifyVCDidTapClassifyButtonNotification";

// NZMyClassesViewController
NSString * const NZLoadSavedDataTappedNotification  = @"NZLoadSavedDataTappedNotification";

// userInfo dictionary keyes
NSString * const NZSensorDataKey                                        = @"accelerometerData";
NSString * const NZStartStopButtonStateKey                              = @"startStopButtonState";
NSString * const NZNumOfRecordedDataKey                                 = @"numOfRecordedData";
NSString * const NZClassifierStatusKey                                  = @"classifierStatus";
NSString * const NZClassifierStatisticsKey                              = @"classifierStatistics";
NSString * const NZNumOfClassLabelsKey = @"NZNumOfClassLabels";
NSString * const NZIsTrainedKey = @"NZIsTarinedKey";
NSString * const NZPredictedClassLabelKey = @"NZPredictedClassLabelKey";