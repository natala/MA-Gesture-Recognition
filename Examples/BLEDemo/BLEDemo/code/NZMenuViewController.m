//
//  NZMenuViewController.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 24/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "NZMenuViewController.h"
#import "NZClassificationController.h"
#import "NZClassifyTmpViewController.h"

@interface NZMenuViewController ()

@property (strong, nonatomic) NZClassificationController *classificationController;
@property (weak, nonatomic) NZTraningViewController *trainingVC;
@property (weak, nonatomic) NZClassifyViewController *classifyVC;
@property (weak, nonatomic) NZClassifyTmpViewController *classifyTmpVC;
#warning only temporary
@property NSNumber *numberOfSamples;
@property BOOL classifierTrained;
@property BOOL classify;

@end


@implementation NZMenuViewController
{
    NSArray *menuOptions;
    NSString *menuCellIdentifier;
}

@synthesize currentClassLabel = _currentClassLabel;
@synthesize classificationController = _classificationController;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
      // [self commonInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      //  [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    menuOptions = [NSArray arrayWithObjects:@"Train", @"Classify", @"My Casses", nil];
    menuCellIdentifier = @"MenuCellId";
    self.recordingData = false;
    self.classifierTrained = false;
    self.classify = false;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _classificationController = [[NZClassificationController alloc] init];
    self.numberOfSamples = [[NSNumber alloc] initWithInt:0];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"GO"]){
        NZClassifyTmpViewController *classifyVC = (NZClassifyTmpViewController *)[segue destinationViewController];
        classifyVC.delegate = self;
        self.classifyTmpVC = classifyVC;
        classifyVC.currentClassifiedLabel = self.classificationController.lastPredictedLabel;
    }

    if([segue.identifier isEqualToString:@"train"]){
        NZTraningViewController *trainVC =(NZTraningViewController *)[segue destinationViewController];
        trainVC.currentClassLable = self.currentClassLabel;
        trainVC.currentGestureType = 0;
        if (self.classificationController.state == RECORDING_SAMPLES) {
            trainVC.currentRecordControlButtonText = @"stop";
        } else trainVC.currentRecordControlButtonText = @"record";
        trainVC.currentNumberOfSamples = [self.classificationController numberOfDataSamples];
        trainVC.currentNumberOfClasses = [self.classificationController numberOfClasses];
        trainVC.currentClassifierTrained = self.classifierTrained;
        trainVC.currentTrainingOutcomeText = @"to be set!";
        trainVC.delegate = self;
        self.trainingVC = trainVC;
        //NSNumber *numSamples = [self.classificationController numberOfDataSamples];
        //[self updateNumberRecordedSamples:numSamples in:trainVC];
        //if ([self classifierTrained]) {
        //    trainVC.classifierTrainingStaus = @"trained";
        //} else {
        //    trainVC.classifierTrainingStaus = @"not trained";
        //}
    } else if ([segue.identifier isEqualToString:@"classify"]){
        NZClassifyViewController *classifyVC = (NZClassifyViewController *)[segue destinationViewController];
        classifyVC.delegate = self;
        self.classifyVC = classifyVC;
        if (self.classificationController.state == PREDICTING) {
            classifyVC.currentClassifyButtonLable = @"Stop Classifying";
            classifyVC.currentClassifiedLabel = self.classificationController.lastPredictedLabel;
        } else classifyVC.currentClassifyButtonLable = @"Classify";
        classifyVC.isPipelineTrained = self.classificationController.isTrained;
    }
}
/*
- (void)receivedData:(SensorData *)data
{
    //NSLog(@"menuViewConrroller has received data!!!");
    if (self.recordingData) {
        [ self.classificationController addData:data];
        int value = [self.numberOfSamples intValue];
        self.numberOfSamples = [NSNumber numberWithInt:value + 1];
        //to the appropriate things
        if (self.trainingVC) {
            //[self updateNumberOfRecordedSamples:[self.classificationController numberOfDataSamples] in:self.trainingVC];
        }
    } else if (self.classify){
        NSString *classLabel = [self.classificationController predict:data];
        [self updateClassifiedLable:self.classifyVC withLabel:classLabel];
        [self updateClassifiedLableTmp:self.classifyTmpVC withLabel:classLabel];
    }
    
}
*/
- (IBAction)trainButtonTaped:(id)sender {
}

- (IBAction)classifyButtonTaped:(id)sender {
}

- (IBAction)myClassesButtonTaped:(id)sender {
}


#pragma mark -
#pragma mark getters & setters
#pragma mark -
- (void)setCurrentClassLabel:(NSString *)currentClassLabel
{
    _currentClassLabel = currentClassLabel;
    [self.classificationController addClassLabel:currentClassLabel];
    //NSLog(@"adding class lable: %@", currentClassLabel);
}

- (NSString *)currentClassLabel
{
    if (!_currentClassLabel) {
        _currentClassLabel = @"default";
    }
    
    return _currentClassLabel;
}

#pragma mark -
#pragma mark managing classification controller TODO: define a protocol
#pragma mark -


#pragma mark -
#pragma mark NZTrainViewControllerDelegate
#pragma mark -

-(void)stopRecordingData
{
    self.recordingData = false;
}

-(void)startRecordingData
{
    self.recordingData = true;
}

-(void)newDataClassLabel:(NSString *) newClassLabel{
    self.currentClassLabel = newClassLabel;
}

/*-(void)updateNumberOfRecordedSamples:(NSNumber *)numberOfSamples in:(NZTraningViewController *)trainVC
{
   // [trainVC updateNumberOfSamples:numberOfSamples];
}*/

- (void)startTrainingClassifier
{
    NSLog(@"start training the classifier");
#warning start training the classifier, once done -> update the trainVC
/*    if ([self.classificationController trainClassifier]) {
        self.classifierTrained = true;
    } else {
        self.classifierTrained = false;
    }
    // once training doen
    [self updateClassifierStatusIn:self.trainingVC];
    [self updateInfo:@"precision and so on.... \n ...." aboutTrainingOutcomeIn:self.trainingVC];
 */
}

- (void)updateClassifierStatusIn:(NZTraningViewController *)trainingVC
{
    if (self.classifierTrained) {
        trainingVC.classifierTrainingStaus.text = @"trained";
    } else if (!self.classifierTrained) {
        trainingVC.classifierTrainingStaus.text = @"not trained";
    }
    trainingVC.trainClassifierButton.enabled = true;
}
- (void)updateInfo:(NSString *)info aboutTrainingOutcomeIn:(NZTraningViewController *)trainingVC
{
    trainingVC.trainingOutcomeText.text = info;
}

- (void)saveLabelledDataToCsvFile
{
    if (![self.classificationController saveLabelledDataToCSVFile]) {
        NSLog(@"couldn't save labelled data to csv file!!");
    }
}

#pragma mark -
#pragma mark NZTrainClassifyControllerDelegate
#pragma mark -

- (void)startClassifying
{
    self.classify = !self.classify;
}

- (void)updateClassifiedLable:(NZClassifyViewController *)classificationVC withLabel:(NSString *)classLabel{
    classificationVC.classifiedClassLabel.text = classLabel;
}

- (void)updateClassifiedLableTmp:(NZClassifyTmpViewController *)classificationVC withLabel:(NSString *)classLabel{
    classificationVC.classifiedClassLabel.text = classLabel;
}

@end
