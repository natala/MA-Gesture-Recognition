//
//  NZTraningViewController.h
//  BLEDemo
//
//  Created by Natalia Zarawska on 06/04/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

@class NZTraningViewController;

@protocol NZTraningViewControllerDelegate <NSObject>

@required
- (void)stopRecordingData;
- (void)startRecordingData;
- (void)newDataClassLabel:(NSString *) newClassLabel;
//- (void)updateNumberOfRecordedSamples:(NSNumber *)numberOfSamples in:(NZTraningViewController *)trainVC;

- (void)startTrainingClassifier;
- (void)updateClassifierStatusIn:(NZTraningViewController *)trainingVC;
- (void)updateInfo:(NSString *)info aboutTrainingOutcomeIn:(NZTraningViewController *)trainingVC;
- (void)saveLabelledDataToCsvFile;

@end


#import <UIKit/UIKit.h>
#import "NZMenuViewController.h"

@interface NZTraningViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) id<NZTraningViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *classNameTextField;
@property (retain, nonatomic) NSString *currentClassLable;

@property (weak, nonatomic) IBOutlet UISegmentedControl *gestureType;
@property (nonatomic) BOOL currentGestureType;

@property (weak, nonatomic) IBOutlet UIButton *recordControlButton;
@property (nonatomic, strong) NSString *currentRecordControlButtonText;

@property (weak, nonatomic) IBOutlet UILabel *numberOfSamples;
@property (strong, nonatomic) NSNumber *currentNumberOfSamples;
#warning update number of classes
@property (weak, nonatomic) IBOutlet UILabel *numberOfClasses;
@property (strong, nonatomic) NSNumber *currentNumberOfClasses;


#pragma mark -
#pragma mark classifier info
#pragma mark -
@property (weak, nonatomic) IBOutlet UILabel *classifierTrainingStaus;
@property (nonatomic) BOOL currentClassifierTrained;
@property (weak, nonatomic) IBOutlet UIButton *trainClassifierButton;
@property (weak, nonatomic) IBOutlet UITextView *trainingOutcomeText;
@property (strong, nonatomic) NSString *currentTrainingOutcomeText;

- (IBAction)trainClassifierButtonTapped:(id)sender;

- (IBAction)saveLabelledDataButtonTapped:(id)sender;

- (IBAction)recordControlButtonTapped:(id)sender;
//- (void)updateNumberOfSamples:(NSNumber *)numberOfSamples;
@end
