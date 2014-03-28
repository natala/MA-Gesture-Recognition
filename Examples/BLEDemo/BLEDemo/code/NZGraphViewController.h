//
//  NZGraphViewController.h
//  BLEDemo
//
//  Created by Natalia Zarawska on 28/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SensorData.h"

@interface NZGraphViewController : UIViewController

- (void)updateWIthData:(SensorData*) accelerometerData;

@end
