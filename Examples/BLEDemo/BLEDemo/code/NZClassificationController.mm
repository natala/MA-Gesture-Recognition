//
//  NZClassificationController.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 06/04/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "NZClassificationController.h"
#import "GRT.h"

@interface NZClassificationController ()
@end

@implementation NZClassificationController

GRT::GestureRecognitionPipeline *pipeline;
-(void)addData:(SensorData *)data
{
    NSLog(@"GRT adding data");
}

@end