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

@property (strong, nonatomic) NSMutableArray *classLabels;

@end

@implementation NZClassificationController

@synthesize classLabels = _classLabels;


GRT::GestureRecognitionPipeline *pipeline;

- (id)init
{
    self = [super init];
    if (self) {
        pipeline = new GRT::GestureRecognitionPipeline();
    }
    return self;
}

- (void)addData:(SensorData *)data withLabel:(NSString *)classLabel
{
    NSLog(@"GRT adding data with label: %@", classLabel);
}

- (void)addData:(SensorData *)data
{
    NSLog(@"GRT addinf data with label: %@", [self.classLabels objectAtIndex:[self.classLabels count]-2]);
}

#pragma mark -
#pragma mark getters & setters
#pragma mark -

- (NSMutableArray *)classLabels
{
    if (!_classLabels) {
        _classLabels = [[NSMutableArray alloc] initWithObjects:/*@"default",*/ nil] ;
    }
    return _classLabels;
}

- (void)addClassLabel:(NSString *)classLabel
{
    //TODO: check if not same being added;
    [self.classLabels addObject:classLabel];
    NSLog(@"number of classes: %d", [self.classLabels count]);
}

@end