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

@synthesize classNameTextField;

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
    CGRect frame = self.view.frame;
    frame.size.height = frame.size.height*2.0;
    self.scrollView.contentSize = frame.size;
    
    // subscribe
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addedLabelledData:) name:NZClassificationControllerAddedDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateClassifierStatus:) name:NZClassificationControllerFinishedTrainingNotification object:nil];
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
        //[self.delegate stopRecordingData];
#warning disable edidting parameters while recording
        [self.recordControlButton setTitle:@"record" forState:UIControlStateNormal];
       // self.recordControlButton.titleLabel.text = @"record";
    } else {
        NSLog(@"start recording");
        msg = @"start";
        //[self.delegate startRecordingData];
        [self.recordControlButton setTitle:@"stop" forState:UIControlStateNormal];
       // self.recordControlButton.titleLabel.text = @"stop";
    }
    
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:msg, NZStartStopButtonStateKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NZTrainingVCDidTapRecordButtonNotification object:self userInfo:dic];

}

- (void)updateNumberOfSamples:(NSNumber *)numberOfSamples
{
    self.numberOfSamples.text = [numberOfSamples stringValue];
}

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
    [self updateNumberOfSamples:num];
}

- (void)updateClassifierStatus:(NSNotification *)notification
{
    self.classifierTrainingStaus.text = [[notification userInfo] objectForKey:NZClassifierStatusKey];
    self.trainingOutcomeText.text = [[notification userInfo] objectForKey:NZClassifierStatisticsKey];
    self.trainClassifierButton.enabled = true;
}

@end
