//
//  NZTabBarController.h
//  BLEDemo
//
//  Created by Natalia Zarawska on 28/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEDiscovery.h"
#import "BLEService.h"
#import "SensorData.h"

@interface NZTabBarController : UITabBarController <BLEDiscoveryDelegate, BLEServiceDelegate, BLEServiceDataDelegate>

@property (strong, nonatomic) SensorData *accelerometerData;

@end
