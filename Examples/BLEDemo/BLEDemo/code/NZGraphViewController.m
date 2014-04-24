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
    CGRect rect = [self.view layer].bounds;
    rect.size.height = 180.0;
    loaded = true;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateWithData:(SensorData*) accelerometerData
{
    if (loaded) {
        [self.graphView addData:accelerometerData];
    }
}

@end
