//
//  NZClassificationController.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 06/04/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "NZClassificationController.h"
#import "GRT.h"

@interface NZClassificationController ()

@property (strong, nonatomic) NSMutableArray *classLabels;

@end

@implementation NZClassificationController

@synthesize classLabels = _classLabels;


GRT::GestureRecognitionPipeline pipeline;
GRT::LabelledClassificationData labelledData;

- (id)init
{
    self = [super init];
    if (self) {
        pipeline = GRT::GestureRecognitionPipeline();
        labelledData = GRT::LabelledClassificationData(3);
    }
    return self;
}

- (void)addData:(SensorData *)data withLabel:(NSString *)classLabel
{
    NSLog(@"GRT adding data with label: %@", classLabel);
    // get the class as number
    NSInteger classIndex = [self.classLabels indexOfObject:classLabel];
    if (NSNotFound == classIndex) {
        NSLog(@"faild to add sample to the classification manager, lable: %@ not found!!!", classLabel);
    } else {
        // the classLabel for GRT can not be 0 so add 1
        classIndex++;
        // add the sample and chek if succeeded
        if (!labelledData.addSample((uint)classIndex, [NZClassificationController SensorDataToGrtFormat:data])) {
            NSLog(@"failed to add sample to labelledData, error in GRT lib");
        }
    }
    
}

- (void)addData:(SensorData *)data
{
    if ([self.classLabels count] == 0) {
        NSLog(@"Couldn't define the class label of the sample!!");
        return;
    }
    NSString *label = (NSString *)[self.classLabels lastObject];
    [self addData:data withLabel:label];
}

- (BOOL)trainClassifier
{
    // 1. Partition the training data into a training dataset and a test dataset. 80 means that 80% of the data will be used for the training data and 20% will be returned as the test dataset
    GRT::LabelledClassificationData testData = labelledData.partition(80);
    
    // 2. Create a new Gesture Recognition Pipeline using an Adaptive Naive Bayes Classifier
    pipeline.setClassifier( GRT::ANBC() );
    
    // 3. Train the pipeline using the training data
    if( !pipeline.train( labelledData ) ){
        NSLog(@"ERROR: Failed to train the pipeline!");
        return false;
    }
    
    // 4. Test the pipeline using the test data
    if( !pipeline.test( testData ) ){
        NSLog( @"ERROR: Failed to test the pipeline!");
        return false;
    }
    
    // 5. Print some stats about the testing
    NSLog(@"Test Accuracy: %d", pipeline.getTestAccuracy());
    
    /*
    cout << "Precision: ";
    for(UINT k=0; k<pipeline.getNumClassesInModel(); k++){
        UINT classLabel = pipeline.getClassLabels()[k];
        cout << "\t" << pipeline.getTestPrecision(classLabel);
    }cout << endl;
    
    cout << "Recall: ";
    for(UINT k=0; k<pipeline.getNumClassesInModel(); k++){
        UINT classLabel = pipeline.getClassLabels()[k];
        cout << "\t" << pipeline.getTestRecall(classLabel);
    }cout << endl;
    
    cout << "FMeasure: ";
    for(UINT k=0; k<pipeline.getNumClassesInModel(); k++){
        UINT classLabel = pipeline.getClassLabels()[k];
        cout << "\t" << pipeline.getTestFMeasure(classLabel);
    }cout << endl;
    
    Matrix< double > confusionMatrix = pipeline.getTestConfusionMatrix();
    cout << "ConfusionMatrix: \n";
    for(UINT i=0; i<confusionMatrix.getNumRows(); i++){
        for(UINT j=0; j<confusionMatrix.getNumCols(); j++){
            cout << confusionMatrix[i][j] << "\t";
        }cout << endl;
    }
    */
    
}

#pragma mark -
#pragma mark getters & setters
#pragma mark -

- (NSMutableArray *)classLabels
{
    if (!_classLabels) {
        _classLabels = [[NSMutableArray alloc] initWithObjects:/*@"default",*/ nil] ;
    }
    return _classLabels;
}

- (void)addClassLabel:(NSString *)classLabel
{
    //TODO: check if not same being added;
    [self.classLabels addObject:classLabel];
    uint classLabelNumber = (uint)([self.classLabels count]-1);
    labelledData.addClass(classLabelNumber);
    NSLog(@"number of classes: %ud", [self.classLabels count]);
}

- (NSNumber *)numberOfDataSamples
{
#warning later labelledData->getNumSamplesPerClass();
    int num = labelledData.getNumSamples();
    NSNumber *nsNumber = [[NSNumber alloc] initWithInt:num];
    return nsNumber;
}

#pragma mark -
#pragma mark Helpers
#pragma mark -

// convert sensor data to a GRT compatible format
+ (GRT::VectorDouble)SensorDataToGrtFormat:(SensorData *)data{
    GRT::VectorDouble sample = GRT::VectorDouble(3);
    sample[0] = (int)data.x.value;
    sample[1] = (int)data.y.value;
    sample[3] = (int)data.z.value;
    return sample;
}

@end