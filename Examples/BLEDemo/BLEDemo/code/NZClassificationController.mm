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
#import "NZNotificationConstants.h"
#import "NZConstants.h"
#import "NZClassificationConstants.h"

#define kPipelineKey            @"Pipeline"
#define kClassesFile            @"classes.plist"
#define kPipelineFile           @"pipeline.txt"
#define kLabelledDataFile       @"labelledData.csv"

@interface NZClassificationController ()

@property (strong, nonatomic) NSMutableArray *classLabels;

@property (strong, nonatomic) NZGestureRecognitionPipeline *pipeline;

// last object = most recent object (fifo)
@property (nonatomic) NSMutableArray *sensorDataArray;
@property (nonatomic) NSMutableArray *predictions;

typedef enum staticDynamicPrediction {
    UNDEFINED   = 0,
    POSE        = 1,
    GESTURE     = 2
} StaticDynamicPrediction;

@end

@implementation NZClassificationController
@synthesize classLabels = _classLabels;

//GRT::GestureRecognitionPipeline pipeline;
#pragma mark -
#pragma mark variables
#pragma mark -
GRT::LabelledClassificationData labelledData;
//int windowSize = 20;
GRT::MovingAverageFilter avgFilter(kFilterWindowSize,kSampleDimension);
int indexLastPose = -1;
int indexLastGesture = -1;
StaticDynamicPrediction lastPrediction = UNDEFINED;


#pragma mark -
#pragma mark methods
#pragma mark -
- (id)init
{
    self = [super init];
    if (self) {
        //pipeline = GRT::GestureRecognitionPipeline();
        _pipeline = [[NZGestureRecognitionPipeline alloc] init];
        labelledData = GRT::LabelledClassificationData(3);
        _state = ClassifierControllerStates::INITIAL_STATE;
        
        self.sensorDataArray = [[NSMutableArray alloc] init];
        self.predictions = [[NSMutableArray alloc] init];
        
        // subscribe
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveData:) name:NZDidReceiveSensorDataNotification object:nil];
       /* [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateState:) name:NZClassifyVCDidTapClassifyButtonNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateState:) name:NZTrainingVCDidTapRecordButtonNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trainClassifier:) name:NZTrainingVCDidTapTrainClassifierButtonNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadSavedData:) name:NZLoadSavedDataTappedNotification object:nil];
        */
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
    [self addSensorData:data];
    
    GRT::MatrixDouble grtSamples;
    [self convertSensorDataArray:self.sensorDataArray toGrtMtrix:grtSamples];
    
    // 2. comoute standard deviation and set a threshold
    GRT::VectorDouble stdDev;
    [NZClassificationController stdDeviation:stdDev of:self.sensorDataArray];
    
    double stdDev3 = sqrt(stdDev[0]*stdDev[0] + stdDev[1]*stdDev[1] + stdDev[2]*stdDev[2]);
    
   // NSLog(@"STD of the vector:%f", stdDev[2]);
    StaticDynamicPrediction prediction;
    if (stdDev3 > kStdDeviationTh) {
        prediction = GESTURE;
        //self.lastPredictedLabel = @"GESTURE";
    } else {
        //self.lastPredictedLabel = @"POSE";
        prediction = POSE;
    }

    [self addPrediction:(prediction)];
    
    self.lastPredictedLabel = [self predict];
    
    NSString * info = [NSString stringWithFormat:@"Standard Deviation:\r%f\r%f\r%f \r-> %f\r\rThreshold: %f", stdDev[0], stdDev[1], stdDev[2], stdDev3,kStdDeviationTh];
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:self.lastPredictedLabel, NZPredictedClassLabelKey, info, NZSomeTextKey, nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NZClassificationControllerDidPredictClassNotification object:self userInfo:dic];
}

/*
- (void)addData:(SensorData *)data
{
    if ([self.classLabels count] == 0) {
        NSLog(@"Couldn't define the class label of the sample!!");
        return;
    }
    NSString *label = (NSString *)[self.classLabels lastObject];
    [self addData:data withLabel:label];
    NSNumber *num = [[NSNumber alloc] initWithInt:labelledData.getNumSamples()];
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys: num, NZNumOfRecordedDataKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NZClassificationControllerAddedDataNotification object:self userInfo:dic];
}*/

- (BOOL)train
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
    return true;
}

- (void)setUpPipeline
{
    [self.pipeline setUpPipeline];
}

/*
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
  
}*/

- (BOOL)isPose
{
    if (kPoseMinLength==0) {
        return false;
    }
    int numPredictions = [self.predictions count];
    NSArray *subArray = [self.predictions subarrayWithRange:NSMakeRange(numPredictions-kPoseMinLength, kPoseMinLength)];
    NSCountedSet *set = [NSCountedSet setWithArray:subArray];
    int res = [set countForObject:[NSNumber numberWithInt:POSE]];
    if (res/kPoseMinLength >= kPostProcessingTh) {
        return true;
    }
    return false;
}

#warning merge with -isPose method
- (BOOL)isGesture
{
    if (kGestureMinLength==0) {
        return false;
    }
    int numPredictions = [self.predictions count];
    NSArray *subArray = [self.predictions subarrayWithRange:NSMakeRange(numPredictions-kGestureMinLength, kGestureMinLength)];
    NSCountedSet *set = [NSCountedSet setWithArray:subArray];
    int res = [set countForObject:[NSNumber numberWithInt:GESTURE]];
    if (res/kGestureMinLength >= kPostProcessingTh) {
        return true;
    }
    return false;
}

- (NSString *)predict
{
    NSUInteger numPrediction = [self.predictions count];
    
    if (numPrediction < kPoseMinLength) {
        lastPrediction = UNDEFINED;
        return @"UNDEFINED";
    }
    
#warning bad code!!
    if (numPrediction < kGestureMinLength && numPrediction >= kPoseMinLength) {
            if ([self isPose]) {
                lastPrediction = POSE;
                indexLastPose = numPrediction-1;
                return @"POSE";
            } else {
                lastPrediction = UNDEFINED;
                if (indexLastPose >= 0) {
                    indexLastPose--;
                }
                return @"UNDEFINED";
            }
    }
    if (lastPrediction == UNDEFINED || lastPrediction == GESTURE) {
        if ([self isGesture]) {
            lastPrediction = GESTURE;
            indexLastGesture = numPrediction-1;
            if (indexLastPose >= 0) {
                indexLastPose--;
            }
            return @"GESTURE";
        }
    }
    if ([self isPose]) {
        lastPrediction = POSE;
        indexLastPose = numPrediction-1;
        if (indexLastGesture >= 0) {
            indexLastGesture--;
        }
        return @"POSE";
    }
    
    lastPrediction = UNDEFINED;
    if (indexLastGesture >= 0) {
        indexLastGesture--;
    }
    if (indexLastPose >= 0) {
        indexLastPose--;
    }
    return @"UNDEFINED";
}

- (BOOL)saveLabelledDataToCSVFile
{
     NSString *path = [[self documentPath] stringByAppendingPathComponent:kLabelledDataFile];
    BOOL res = labelledData.saveDatasetToCSVFile([path UTF8String]);
    NSLog(@"saving labelled data to CSV file: %d", res);
    [self saveClassLabels];
    return res;}

- (BOOL)loadLabelledDataFromCSVFile
{
    NSString *path = [[self documentPath] stringByAppendingPathComponent:kLabelledDataFile];
    [self loadClassLabels];
    bool res = labelledData.loadDatasetFromCSVFile([path UTF8String]);
    if (res) {
       /* NSString *loadedData = @"classes: ";
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys: num, NZNumOfRecordedDataKey, nil];
        [NSNotificationCenter defaultCenter] postNotificationName:NZClassificationControllerDidLoadSavedDataNotification object:self userInfo:<#(NSDictionary *)#>
        */
    }
    return res;
}

- (BOOL)loadClassLabels
{
    NSString *path = [[self documentPath] stringByAppendingPathComponent:kClassesFile];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return false;
    }
    NSData *plistData = [NSData dataWithContentsOfFile:path];
    NSError *error;
    NSArray *plist = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:NULL error:&error];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in plist){
        NSString *label = dic[@"label"];
        [array addObject:label];
    }
    self.classLabels = array;
}

- (BOOL)saveClassLabels
{
    // 1. create the property list
    NSMutableArray *plist = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.classLabels count] ; i++) {
        [plist addObject:@{@"id": [NSNumber numberWithInt:i],
                                     @"label": [self.classLabels objectAtIndex:i]}];
    }
    
    // 2. serialize the property list
    NSError *error;
    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:plist format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    
    // 3. stote the serialized data
    NSString *path = [[self documentPath] stringByAppendingPathComponent:kClassesFile];
    if (plistData) {
        [plistData writeToFile:path atomically:YES];
        return true;
    }
    return false;
    
}

#pragma mark -
#pragma mark getters & setters
#pragma mark -

- (void)addSensorData:(SensorData *)sensorData
{
    //1. filer it
    GRT::VectorDouble vec(3);
    vec[0] = sensorData.x.value;
    vec[1] = sensorData.y.value;
    vec[2] = sensorData.z.value;
    
    vec = avgFilter.filter(vec);
    sensorData.x.value = vec[0];
    sensorData.y.value = vec[1];
    sensorData.z.value = vec[2];
    
    if ([self.sensorDataArray count] >= kStorredSamplesMaxLegth) {
        [self.sensorDataArray removeObjectAtIndex:0];
    }
    [self.sensorDataArray addObject:sensorData];
}

- (void)addPrediction:(StaticDynamicPrediction)prediction
{
    if ([self.predictions count] >= kStorredSamplesMaxLegth) {
        [self.predictions removeObjectAtIndex:0];
    }
    [self.predictions addObject:[NSNumber numberWithInt:prediction ]];
}

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
  //  NSLog(@"number of classes: %ud", [self.classLabels count]);
   // NSNumber *num = [NSNumber alloc] initWithInt:self.pipeline.numb
    [[NSNotificationCenter defaultCenter] postNotificationName:NZClassificationControllerDidAddClassLabel object:self];
}

- (NSNumber *)numberOfDataSamples
{
#warning later labelledData->getNumSamplesPerClass();
    int num = labelledData.getNumSamples();
    NSNumber *nsNumber = [[NSNumber alloc] initWithInt:num];
    return nsNumber;
}

- (NSNumber *)numberOfClasses
{
    int num = labelledData.getNumClasses();
    NSNumber *nsNumber = [[NSNumber alloc] initWithInt:num];
    return nsNumber;
}

- (NSDictionary *)numberOfSamplesPerClass
{
    return nil;
}

-(BOOL)isTrained
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
    
   // NSLog( @"sample: %u %u, %u", sample[0], sample[1], sample[2] );
   // NSLog( @"sensorData: %u, %u, %u", (data.x.value+1.0)*32767, (data.y.value+1.0)*32767, (data.z.value+1.0)*32767 );
          
    /*
    sample[0] = (int)data.x.value;
    sample[1] = (int)data.y.value;
    sample[3] = (int)data.z.value;
     */
    return sample;
}

+ (void)mean:(GRT::VectorDouble&)means of:(NSArray *)sensorData
{
    if (![sensorData count]) {
        return;
    }
    means = GRT::VectorDouble(3);
    means[0] = 0;
    means[1] = 0;
    means[2] = 0;
    for (SensorData *data in sensorData){
        means[0] = means[0] + data.x.value;
        means[1] = means[1] + data.y.value;
        means[2] = means[2] + data.z.value;
    }
    
    means[0] /= [sensorData count];
    means[1] /= [sensorData count];
    means[2] /= [sensorData count];

}

+ (void)stdDeviation:(GRT::VectorDouble&)stdDev of:(NSArray*)sensorData
{
    if (![sensorData count]) {
        return;
    }
    
    stdDev = GRT::VectorDouble(3);
    
    GRT::VectorDouble means;
    [NZClassificationController mean:means of:sensorData];
    
/*    NSLog(@"MEANS:");
    for (int i = 0; i < 3; i++) {
        NSLog(@"%f", means[i]);
    }
 */
    GRT::VectorDouble sumOfSquareDifferences(3);
    sumOfSquareDifferences[0] = 0;
    sumOfSquareDifferences[1] = 0;
    sumOfSquareDifferences[2] = 0;
    
    for (SensorData *data in sensorData) {
        
        GRT::VectorDouble difference(3);
    
        difference[0] = data.x.value - means[0];
        difference[1] = data.y.value - means[1];
        difference[2] = data.z.value - means[2];
        
        sumOfSquareDifferences[0] += difference[0]*difference[0];
        sumOfSquareDifferences[1] += difference[1]*difference[1];
        sumOfSquareDifferences[2] += difference[2]*difference[2];
        
    }
    GRT::VectorDouble res(3);
    stdDev[0] = sqrt(sumOfSquareDifferences[0]/[sensorData count]);
    stdDev[1] = sqrt(sumOfSquareDifferences[1]/[sensorData count]);
    stdDev[2] = sqrt(sumOfSquareDifferences[2]/[sensorData count]);
    
    
   /* NSLog(@"STD DEV:");
    for (int i = 0; i < 3; i++) {
        NSLog(@"%d: %f", i, stdDev[i]);
    }
    NSLog(@"______");
    */
}

- (void)convertSensorDataArray:(NSArray*)array toGrtMtrix:(GRT::MatrixDouble&)matrix
{
   /* matrix = GRT::MatrixDouble(kFilterWindowSize,3);
    for (int i = 0; i < [self.sensorDataArray count]; i++) {
        GRT::VectorDouble vec = [NZClassificationController SensorDataToGrtFormat:[self.sensorDataArray objectAtIndex:i]];
        matrix[i][0] =  vec[0];
        matrix[i][1] =  vec[1];
        matrix[i][2] =  vec[2];
    }
    for (int i = [self.sensorDataArray count]; i < windowSize; i++) {
        for (int j = 0; j < 3; j++) {
            matrix[i][j] = 0.0;
        }
    }
    */
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
    return [self.pipeline savePipelineTo:path];
}

- (BOOL)loadPipeline
{
    //NSString *dataPath = [self documentPath];
    NSString *path = [[self documentPath] stringByAppendingPathComponent:kPipelineFile];
    return[ self.pipeline loadPipelineFrom:path];
}

#pragma mark - 
#pragma mark Responding to Notifications
#pragma mark -

- (void)didReceiveData:(NSNotification *)notification
{
    // 1. if state = record => add data to labelledData
    // 2. if state = classify & and trained = true => predict
    // 3. otherwise dont do anything
    
    if (self.state == ClassifierControllerStates::INITIAL_STATE) {
        //don't do anything with the data
        return;
    }
    SensorData *sensorData = [[notification userInfo] valueForKey:NZSensorDataKey];
    if (self.state == ClassifierControllerStates::RECORDING_SAMPLES) {
        [self addData:sensorData];
    } else if (self.state == ClassifierControllerStates::PREDICTING) {
        self.lastPredictedLabel = [self predict:sensorData];
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:self.lastPredictedLabel, NZPredictedClassLabelKey, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NZClassificationControllerDidPredictClassNotification object:self userInfo:dic];
    }
}

- (void)updateState:(NSNotification *)notification
{
    // 1. check weather the notification comes forom the record or classify button
    // 2. change the state accordingly (remember to check if the classifier is trained)
    NSString *msg = [[notification userInfo] objectForKey:NZStartStopButtonStateKey];
    if ([[notification name] isEqualToString:NZClassifyVCDidTapClassifyButtonNotification]) {
        if ([msg isEqualToString:@"stop"] && (self.state == ClassifierControllerStates::PREDICTING)) {
            self.state = ClassifierControllerStates::INITIAL_STATE;
        } else if ([msg isEqualToString:@"start"] && [self isTrained]) {
            self.state = ClassifierControllerStates::PREDICTING;
        }
    } else if ([[notification name] isEqualToString:NZTrainingVCDidTapRecordButtonNotification]) {
        if ([msg isEqualToString:@"stop"] && (self.state == ClassifierControllerStates::RECORDING_SAMPLES)) {
            self.state = ClassifierControllerStates::INITIAL_STATE;
        } else if ([msg isEqualToString:@"start"]) {
            self.state = ClassifierControllerStates::RECORDING_SAMPLES;
        }
    }
}

- (void)trainClassifier:(NSNotification *)notification
{
    NSString *msg;
    if ([self train]) {
        msg = @"YES";
    } else msg = @"NO";
    NSString *classifierStats = [self.pipeline statistics];
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:msg, NZClassifierStatusKey,classifierStats, NZClassifierStatisticsKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NZClassificationControllerFinishedTrainingNotification object:self userInfo:dic];
}

- (void)loadSavedData:(NSNotification *)notification
{
    if ([self loadPipeline] && [self loadLabelledDataFromCSVFile]){
        NSNumber *numOfSamples = [self numberOfDataSamples];
        NSNumber *numOfClasses = [self numberOfClasses];
        NSString *trained = [[NSString alloc] initWithFormat:@"%c", self.pipeline.isTrained] ;
        
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:numOfClasses, NZNumOfClassLabelsKey, numOfSamples, NZNumOfRecordedDataKey, trained, NZIsTrainedKey, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NZClassificationControllerDidLoadSavedDataNotification object:self userInfo:dic];
    }
}

@end