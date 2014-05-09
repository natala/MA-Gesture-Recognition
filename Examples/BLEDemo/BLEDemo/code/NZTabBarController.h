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


/*! \brief linear acceleration in 3 dimensions
 *
 */
@property (strong, nonatomic) SensorData *accelerometerData;

/*! \brief orientation in 3 dimensions
 *
 */
@property (strong, nonatomic) SensorData *orientationData;

@end
