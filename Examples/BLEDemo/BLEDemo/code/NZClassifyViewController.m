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

- (void)updadePredictedLabel:(NSNotification *)notification
{
    self.currentClassifiedLabel = [[notification userInfo] objectForKey:NZPredictedClassLabelKey];
    self.infoLabel.text = [[notification userInfo] objectForKey:NZSomeTextKey];
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

@end
