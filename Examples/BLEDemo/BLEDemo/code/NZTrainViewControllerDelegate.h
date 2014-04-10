//
//  NZTrainViewControllerDelegate.h
//  BLEDemo
//
//  Created by Natalia Zarawska on 09/04/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NZTraningViewController.h"

@protocol NZTrainViewControllerDelegate <NSObject>

@required

-(void)stopRecodingData;
-(void)startRecordingData;
-(void)newDataClassLabel:(NSString *) newClassLabel;
//-(void)updateNumberOfRecordedSamples:(NSNumber *)numberOfSamples in:(NZTraningViewController *)trainVC;

@end
