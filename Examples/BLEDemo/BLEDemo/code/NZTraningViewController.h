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
- (void)updateNumberOfRecordedSamples:(NSNumber *)numberOfSamples in:(NZTraningViewController *)trainVC;

- (void)startTrainingClassifier;
- (void)updateClassifierStatusIn:(NZTraningViewController *)trainingVC;
- (void)updateInfo:(NSString *)info aboutTrainingOutcomeIn:(NZTraningViewController *)trainingVC;

@end

#import <UIKit/UIKit.h>
#import "NZMenuViewController.h"

@interface NZTraningViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) id<NZTraningViewControllerDelegate> delegate;

@property (retain, nonatomic) NSString *currentClassLable;

@property (weak, nonatomic) IBOutlet UITextField *classNameTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gestureType;
@property (weak, nonatomic) IBOutlet UIButton *recordControlButton;

@property (weak, nonatomic) IBOutlet UILabel *numberOfSamples;
#warning update number of classes
@property (weak, nonatomic) IBOutlet UILabel *numberOfClasses;


#pragma mark -
#pragma mark classifier info
#pragma mark -
@property (weak, nonatomic) IBOutlet UILabel *classifierTrainingStaus;
@property (weak, nonatomic) IBOutlet UIButton *trainClassifierButton;
@property (weak, nonatomic) IBOutlet UITextView *trainingOutcomeText;

- (IBAction)trainClassifierButtonTapped:(id)sender;


- (IBAction)recordControlButtonTapped:(id)sender;
- (void)updateNumberOfSamples:(NSNumber *)numberOfSamples;
@end
