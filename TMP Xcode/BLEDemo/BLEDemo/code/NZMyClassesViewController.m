//
//  NZMyClassesViewController.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 24/04/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "NZMyClassesViewController.h"
#import "NZNotificationConstants.h"

@interface NZMyClassesViewController ()

@end

@implementation NZMyClassesViewController

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controllerDidLoadSavedData:) name:NZClassificationControllerDidLoadSavedDataNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loadDataButtonTapped:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NZLoadSavedDataTappedNotification object:nil];
}

#pragma mark -
#pragma mark Respond to notifications
#pragma mark -

- (void)controllerDidLoadSavedData:(NSNotification *)notification
{
    NSNumber *numSamples = [[notification userInfo] objectForKey:NZNumOfRecordedDataKey];
    NSNumber *numClasses = [[notification userInfo] objectForKey:NZNumOfClassLabelsKey];
    NSString *trained = [[notification userInfo] objectForKey:NZIsTrainedKey];
    NSString *text = @"number of classes: ";
    text = [text stringByAppendingString:[NSString stringWithFormat:@"%d", numClasses.integerValue]];
    text = [text stringByAppendingString:@"   number of samples: "];
    text = [text stringByAppendingString:[NSString stringWithFormat:@"%d", numSamples.integerValue]];
    text = [text stringByAppendingString:@"   Classifier is trained: "];
    text = [text stringByAppendingString:trained];
    self.loadedDataText.text = text;
}

@end
