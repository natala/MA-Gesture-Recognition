//
//  NZGraphViewController.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 28/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "NZGraphViewController.h"
#import "NZGraphView.h"
#import "NZConstants.h"

@interface NZGraphViewController ()

@property (weak, nonatomic) IBOutlet NZGraphView *graphView;
@property (weak, nonatomic) IBOutlet NZGraphView *orientationView;

@end

@implementation NZGraphViewController

BOOL loaded = false;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.graphView.normalizeFactor = kNormalizationAxisY;
    self.graphView.maxAxisY = kMaxAxisY;
    self.graphView.minAxisY = kMinAxisY;
    self.orientationView.normalizeFactor = kOrientationNormalizationFactor;
    self.orientationView.maxAxisY = kOrientationMaxAxisY;
    self.orientationView.minAxisY = kOrientationMinAxisY;
    
    /*CGRect rect = [self.graphView layer].bounds;
    rect.size.height = kSegmentHeight;
    [self.graphView layer].bounds = rect;
    rect = [self.orientationView layer].bounds;
    rect.size.height = kSegmentHeight;
    [self.orientationView layer].bounds = rect;
     */
    loaded = true;
	// Do any additional setup after loading the view.
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateWithacceleration:(SensorData *)acceleration andOrientation:(SensorData *)orientation
{
    if (!loaded) {
        return;
    }
    if (acceleration) {
        [self.graphView addData:acceleration];
    }
    if (orientation) {
        [self.orientationView addData:orientation];
    }
}

@end
