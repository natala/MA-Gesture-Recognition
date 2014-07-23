//
//  NZTraningViewController.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 06/04/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "NZTraningViewController.h"
#import "NZNotificationConstants.h"

@interface NZTraningViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end


@implementation NZTraningViewController

@synthesize currentRecordControlButtonText = _currentRecordControlButtonText;

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
    // set the text field delegate to manage the input thext
    self.classNameTextField.delegate = self;
    [self.classNameTextField setText:self.currentClassLable];
    self.gestureType.selectedSegmentIndex = self.currentGestureType;
    [self.recordControlButton setTitle:self.currentRecordControlButtonText forState:UIControlStateNormal];
    self.numberOfClasses.text = [NSString stringWithFormat:@"%d", [self.currentNumberOfClasses integerValue]];
    self.numberOfSamples.text = [NSString stringWithFormat:@"%d", [self.currentNumberOfSamples integerValue]];
    if (self.currentClassifierTrained) {
        self.classifierTrainingStaus.text = @"trained";
    } else {
        self.classifierTrainingStaus.text = @"not trained";
    }
    self.trainingOutcomeText.text = self.currentTrainingOutcomeText;
    
    CGRect frame = self.view.frame;
    frame.size.height = frame.size.height*2.0;
    self.scrollView.contentSize = frame.size;
    
    // subscribe
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addedLabelledData:) name:NZClassificationControllerAddedDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateClassifierStatus:) name:NZClassificationControllerFinishedTrainingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addedClassLabel:) name:NZClassificationControllerDidAddClassLabel object:nil];
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

- (IBAction)trainClassifierButtonTapped:(id)sender {
    self.classifierTrainingStaus.text = @" . . .";
    UIButton *button = (UIButton *)sender;
    button.enabled = !button.enabled;
    [[NSNotificationCenter defaultCenter] postNotificationName:NZTrainingVCDidTapTrainClassifierButtonNotification object:self];
    //[self.delegate startTrainingClassifier];
}

- (IBAction)saveLabelledDataButtonTapped:(id)sender {
    
    [self.delegate saveLabelledDataToCsvFile];
}

- (IBAction)recordControlButtonTapped:(id)sender {
    NSString *msg;
    if ( [self.recordControlButton.titleLabel.text isEqualToString:@"stop"] ) {
        NSLog(@"stop recording");
        msg= @"stop";
        [self.delegate stopRecordingData];
#warning disable edidting parameters while recording
        self.currentRecordControlButtonText = @"record";
        //[self.recordControlButton setTitle:@"record" forState:UIControlStateNormal];
    } else {
        NSLog(@"start recording");
        msg = @"start";
        //[self.delegate startRecordingData];
        self.currentRecordControlButtonText = @"stop";
        //[self.recordControlButton setTitle:@"stop" forState:UIControlStateNormal];
       // self.recordControlButton.titleLabel.text = @"stop";
    }
    
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:msg, NZStartStopButtonStateKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NZTrainingVCDidTapRecordButtonNotification object:self userInfo:dic];

}
/*
- (void)updateNumberOfSamples:(NSNumber *)numberOfSamples
{
    self.numberOfSamples.text = [numberOfSamples stringValue];
}*/

#pragma mark -
#pragma mark UITextFieldDelegate
#pragma mark -

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // NSLog(@"textFieldShouldReturn");
    [self.delegate newDataClassLabel:textField.text];
    [self.view endEditing:YES];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // NSLog(@"textFieldShouldBeginEditing");
    textField.text = nil;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
   // NSLog(@"textFieldDidBeginEditing");
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
   // NSLog(@"textFieldDidEndEditing");
}

#pragma mark - 
#pragma mark Responding to Notifications
#pragma mark -

- (void)addedLabelledData:(NSNotification *)notification
{
    NSNumber *num = [[notification userInfo] objectForKey:NZNumOfRecordedDataKey];
    self.currentNumberOfSamples = num;
   // self.currentNumberOfSamples = [[NSNumber alloc] initWithInt:10];
 //   [self updateNumberOfSamples:num];
}

- (void)updateClassifierStatus:(NSNotification *)notification
{
    NSString *msg = [[notification userInfo] objectForKey:NZClassifierStatusKey];
    if ([msg isEqualToString:@"YES"]) {
        self.currentClassifierTrained = true;
    } else {
        self.currentClassifierTrained = false;
    }
    self.currentTrainingOutcomeText = [[notification userInfo] objectForKey:NZClassifierStatisticsKey];
    self.trainClassifierButton.enabled = true;
}

- (void)addedClassLabel:(NSNotification *)notification
{
    NSNumber *num = [[notification userInfo] objectForKey:NZNumOfClassLabelsKey];
    self.currentNumberOfClasses = num;
}

#pragma mark - 
#pragma mark Getters & Setters
#pragma mark -

// @synthesize classNameTextField = _classNameTextField;
- (void)setCurrentClassLable:(NSString *)currentClassLable
{
    _currentClassLable = currentClassLable;
    self.classNameTextField.text = currentClassLable;
}

// @synthesize gestureType = _gestureType;
- (void)setCurrentGestureType:(BOOL)currentGestureType
{
    _currentGestureType = currentGestureType;
    if (currentGestureType) {
        self.gestureType.selectedSegmentIndex = 1;
    } else {
        self.gestureType.selectedSegmentIndex = 0;
    }
}

// @synthesize recordControlButton = _recordControlButton;
- (void)setCurrentRecordControlButtonText:(NSString *)currentRecordControlButtonText
{
    _currentRecordControlButtonText = currentRecordControlButtonText;
    [self.recordControlButton setTitle:currentRecordControlButtonText forState:UIControlStateNormal];
}

- (NSString *)currentRecordControlButtonText
{
    if (!_currentRecordControlButtonText) {
        _currentRecordControlButtonText = @"record";
    }
    return _currentRecordControlButtonText;
}

// @synthesize numberOfSamples = _numberOfSamples;
- (void)setCurrentNumberOfSamples:(NSNumber *)currentNumberOfSamples
{
    _currentNumberOfSamples = currentNumberOfSamples;
    self.numberOfSamples.text = [NSString stringWithFormat:@"%d", [currentNumberOfSamples integerValue] ];
}

// @synthesize numberOfClasses = _numberOfClasses;
- (void)setCurrentNumberOfClasses:(NSNumber *)currentNumberOfClasses
{
    _currentNumberOfClasses = currentNumberOfClasses;
    [self.numberOfClasses setText:[NSString stringWithFormat:@"%d", [currentNumberOfClasses integerValue] ]];
}

// @synthesize classifierTrainingStaus = _classifierTrainingStaus;
- (void)setCurrentClassifierTrained:(BOOL)currentClassifierTrained
{
    _currentClassifierTrained = currentClassifierTrained;
    if (currentClassifierTrained) {
        [self.classifierTrainingStaus setText:@"trained"];
    } else {
        [self.classifierTrainingStaus setText:@"not trained"];
    }
}

// @synthesize trainingOutcomeText = _trainingOutcomeText;
- (void)setCurrentTrainingOutcomeText:(NSString *)currentTrainingOutcomeText
{
    _currentTrainingOutcomeText = currentTrainingOutcomeText;
    [self.trainingOutcomeText setText:currentTrainingOutcomeText];
}

@end
