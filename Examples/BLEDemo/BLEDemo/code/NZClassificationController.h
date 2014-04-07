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

@property NSString *datasetName;


- (void)addData: (SensorData *)data;

@end    