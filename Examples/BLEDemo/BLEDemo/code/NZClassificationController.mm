//
//  NZClassificationController.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 06/04/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "NZClassificationController.h"
#import "GRT.h"
#import "NZGestureRecognitionPipeline.h"

#define kPipelineKey            @"Pipeline"
//#define kPipelineFile         @"pipeline.plist"
#define kPipelineFile           @"pipeline.txt"
#define kLabelledDataFile       @"labelledData.csv"

@interface NZClassificationController ()

@property (strong, nonatomic) NSMutableArray *classLabels;
@property (strong, nonatomic) NZGestureRecognitionPipeline *pipeline;

@end

@implementation NZClassificationController

@synthesize classLabels = _classLabels;


//GRT::GestureRecognitionPipeline pipeline;
GRT::LabelledClassificationData labelledData;

- (id)init
{
    self = [super init];
    if (self) {
        //pipeline = GRT::GestureRecognitionPipeline();
        _pipeline = [[NZGestureRecognitionPipeline alloc] init];
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
    [self.pipeline setClassifier:@"SVM"];
    
    // 3. Train the pipeline using the training data
    if( ![self.pipeline train:labelledData] ){
        NSLog(@"ERROR: Failed to train the pipeline!");
        return false;
    }
    
    // 4. Test the pipeline using the test data
    if( ![self.pipeline test:testData] ){
        NSLog( @"ERROR: Failed to test the pipeline!");
        return false;
    }
    
    //save pipeline to file
    if (![self savePipeline]){
        NSLog(@"error saving pipeline to file!");
        return false;
    }

    //load it from file again
    /*if (![self loadPipeline]){
        NSLog(@"error loading pipeline from file!");
        return false;
    }*/
    
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
    return true;
    
}

- (void)setUpPipeline
{
    [self.pipeline setUpPipeline];
}

- (NSString *)predict:(SensorData *)data
{
    GRT::VectorDouble grtData = [NZClassificationController SensorDataToGrtFormat:data];
    int predictedLable = [self.pipeline predict:grtData];
    if (predictedLable == -1) {
        return @"unknown";
    }
    if (predictedLable > [self.classLabels count]) {
        return @"unknown";
    }
    NSString *classLabel = [self.classLabels objectAtIndex:(predictedLable-1)];
    return classLabel;
}

- (BOOL)saveLabelledDataToCSVFile
{
     NSString *path = [[self documentPath] stringByAppendingPathComponent:kLabelledDataFile];
    return labelledData.saveDatasetToCSVFile([path UTF8String]);
}

- (BOOL)loadLabelledDataFromCSVFile
{
    NSString *path = [[self documentPath] stringByAppendingPathComponent:kLabelledDataFile];
    return labelledData.loadDatasetFromCSVFile([path UTF8String]);
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
    uint classLabelNumber = (uint)([self.classLabels count]);
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

-(BOOL)classifyierIsTrained
{
    return [self.pipeline isTrained];
}

#pragma mark -
#pragma mark Helpers
#pragma mark -

// convert sensor data to a GRT compatible format
+ (GRT::VectorDouble)SensorDataToGrtFormat:(SensorData *)data{
    GRT::VectorDouble sample = GRT::VectorDouble(3);
    sample[0] = (uint)[[[NSNumber alloc] initWithInteger:data.x.value] unsignedIntegerValue];
    sample[1] = (uint)[[[NSNumber alloc] initWithInteger:data.y.value] unsignedIntegerValue];
    sample[3] = (uint)[[[NSNumber alloc] initWithInteger:data.z.value] unsignedIntegerValue];
    /*
    sample[0] = (int)data.x.value;
    sample[1] = (int)data.y.value;
    sample[3] = (int)data.z.value;
     */
    return sample;
}

// writing to file
- (NSString *)documentPath
{
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                               NSUserDomainMask, YES);
    
    NSString *documentsPath = [searchPaths objectAtIndex:0];
    return documentsPath;
    /*NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    //NSString *path = [url.path stringByAppendingPathComponent:kPipelineFile];
    return url;*/
}

- (BOOL)savePipeline
{
    if (!self.pipeline) {
        return false;
    }
    NSString *path = [[self documentPath] stringByAppendingPathComponent:kPipelineFile];
    /*
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.pipeline forKey:kPipelineKey];
    [archiver finishEncoding];
    [data writeToFile:path atomically:YES];
    //[archiver release];
    //[data release];
    return true;
     */
    return [self.pipeline savePipelineTo:path];
}

- (BOOL)loadPipeline
{
    NSString *dataPath = [self documentPath];
    NSString *path = [[self documentPath] stringByAppendingPathComponent:kPipelineFile];
    return[ self.pipeline loadPipelineFrom:path];
    /*NSData *codedData = [[NSData alloc] initWithContentsOfFile:path];//autorelease];
    if (codedData == nil){
        return nil;
    }
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
    self.pipeline = [unarchiver decodeObjectForKey:kPipelineKey];
    [unarchiver finishDecoding];
    if (self.pipeline) {
        return true;
    }
    return false;*/
}

@end