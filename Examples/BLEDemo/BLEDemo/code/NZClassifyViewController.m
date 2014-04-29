//
//  NZClassifyViewController.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 13/04/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "NZClassifyViewController.h"
#import "NZNotificationConstants.h"

@interface NZClassifyViewController ()

@end

@implementation NZClassifyViewController
@synthesize currentClassifiedLabel = _currentClassifiedLabel;
@synthesize currentClassifyButtonLable = _currentClassifyButtonLable;

//bool pipelineTrained = false;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pipelineDidFinishTraning:) name:NZClassificationControllerFinishedTrainingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updadePredictedLabel:) name:NZClassificationControllerDidPredictClassNotification object:nil];
    self.classifiedClassLabel.text = self.currentClassifiedLabel;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)classifyButtonTapped:(id)sender {
    // first check if the pipeline is trained
    if (!self.isPipelineTrained) {
        self.currentClassifiedLabel = @"classifier is not trained!";
        return;
    }
    UIButton *button = (UIButton *)sender;
    NSString *msg;
    if ([button.currentTitle isEqual:@"Classify"]) {
        [button setTitle:@"Stop classifying" forState:UIControlStateNormal];
        msg = @"start";
    } else {
        [button setTitle:@"Classify" forState:UIControlStateNormal];
        msg = @"stop";
    }
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:msg, NZStartStopButtonStateKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NZClassifyVCDidTapClassifyButtonNotification object:self userInfo:dic];
}

#pragma mark -
#pragma mark Respond to Notifications
#pragma mark -

- (void)pipelineDidFinishTraning:(NSNotification *)notification
{
    if ([[[notification userInfo] objectForKey:NZClassifierStatusKey] isEqualToString:@"trained"]) {
        self.isPipelineTrained = true;
    } else self.isPipelineTrained = false;
}

- (void)updadePredictedLabel:(NSNotification *)notification
{
    self.currentClassifiedLabel = [[notification userInfo] objectForKey:NZPredictedClassLabelKey];
}

#pragma mark - 
#pragma mark Getters & Setters
#pragma mark -
- (void)setCurrentClassifiedLabel:(NSString *)currentClassifiedLabel
{
    _currentClassifiedLabel = currentClassifiedLabel;
    self.classifiedClassLabel.text = currentClassifiedLabel;
}

- (NSString *)currentClassifiedLabel
{
    if (!_currentClassifiedLabel) {
        _currentClassifiedLabel = @"___";
    }
    return _currentClassifiedLabel;
}

- (void)setCurrentClassifyButtonLable:(NSString *)currentClassifyButtonLable
{
    _currentClassifiedLabel = currentClassifyButtonLable;
    [self.classifyButton setTitle:currentClassifyButtonLable forState:UIControlStateNormal];
}

- (NSString *)currentClassifyButtonLable
{
    if (!_currentClassifiedLabel) {
        _currentClassifiedLabel = @"Classify";
    }
    return _currentClassifyButtonLable;
}

@end
