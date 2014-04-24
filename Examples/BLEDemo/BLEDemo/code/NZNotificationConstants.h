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

// NZTrainingViewController
extern NSString * const NZTrainingVCDidAddClassLabelNotification;
extern NSString * const NZTrainingVCDidTapRecordButtonNotification;
extern NSString * const NZTrainingVCDidTapSaveLabelledDataButtonNotification;
extern NSString * const NZTrainingVCDidTapTrainClassifierButtonNotification;

// NZClassifyViewController
extern NSString * const NZClassifyVCDidTapClassifyButtonNotification;

// userInfo dictionary keyes
extern NSString * const NZSensorDataKey;
extern NSString * const NZStartStopButtonStateKey;
extern NSString * const NZNumOfRecordedDataKey;
extern NSString * const NZClassifierStatusKey;
extern NSString * const NZClassifierStatisticsKey;