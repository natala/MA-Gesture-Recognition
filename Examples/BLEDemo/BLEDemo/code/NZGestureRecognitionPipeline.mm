//
//  NZGestureRecognitionPipeline.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 13/04/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "NZGestureRecognitionPipeline.h"
#import <fstream>
#import <string>
#import <sstream>
#import <iostream>

@interface NZGestureRecognitionPipeline ()

@property NSString *fileHeader;

@end

@implementation NZGestureRecognitionPipeline

GRT::GestureRecognitionPipeline pipeline;

- (id)init
{
    self = [super init];
    if ( self ) {
        pipeline = GRT::GestureRecognitionPipeline();
        _pipelineName = @"test pipeline";
        self.fileHeader = @"GRT_PIPELINE_FILE_V1.0";
    }
    return self;
}

- (void)setClassifier:(NSString *)classifier
{
    if ([classifier isEqualToString:@"SVM"]) {
        pipeline.setClassifier(GRT::SVM());
    } else {
        pipeline.setClassifier(GRT::KNN());
    }
}

- (void)setUpPipeline
{
    // add filter
    GRT::HighPassFilter filter = GRT::HighPassFilter(0.1, 1, 3);
    pipeline.addPreProcessingModule(filter);
    
    // add Feature extractors
    GRT::ZeroCrossingCounter zeroCrossing = GRT::ZeroCrossingCounter(30, 0.1, 3);
    //pipeline.addFeatureExtractionModule(zeroCrossing);
}

- (BOOL)train:(GRT::LabelledClassificationData &)labelledData
{
    if( !pipeline.train( labelledData ) ){
        NSLog(@"ERROR: Failed to train the pipeline!");
        return false;
    }
    return true;
}

- (BOOL)test:(GRT::LabelledClassificationData &)testData
{
    // 4. Test the pipeline using the test data
    if( !pipeline.test( testData ) ){
        NSLog( @"ERROR: Failed to test the pipeline!");
        return false;
    }
    
    // 5. Print some stats about the testing
    NSLog(@"Test Accuracy: %f", pipeline.getTestAccuracy());
    
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

- (int)predict:(GRT::VectorDouble &)data
{
    if (!pipeline.getTrained()) {
        return -1;
    }
    pipeline.predict(data);
    return pipeline.getPredictedClassLabel();
}

- (BOOL)isTrained
{
    return pipeline.getTrained();
}

- (BOOL)savePipelineTo:(NSString *)name
{
    NSLog(@"TO BE IMPLEMENTED! Saveing pipeline to file %@", name);
    return pipeline.savePipelineToFile([name UTF8String]);

    /*
     // 3.a save pipeline to file
     if( !pipeline.savePipelineToFile( "HelloWorldPipeline" ) ){
     cout << "ERROR: Failed to save the pipeline!\n";
     return false;
     }
    */
}

- (BOOL)loadPipelineFrom:(NSString *)name
{
    NSLog(@"TO BE IMPLEMENTED! Loading pipeline from file %@", name);
    if (!pipeline.loadPipelineFromFile([name UTF8String])) {
        NSLog(@"couldn't load pipeline");
        return false;
    }
    return true;
    /*
     // 3.b load it from file again
     if( !pipeline.loadPipelineFromFile( "HelloWorldPipeline" ) ){
     cout << "ERROR: Failed to load the pipeline!\n";
     return false;
     }
     */
}

#pragma mark -
#pragma NSCoding
#pragma mark -

#define kFileHeader @"FileHeader"
#define kPipelineMode @"PipelineMode"
#define kNumPreprocessingModules @"NumPreprocessingModules"
#define kNumFeatureExtractionModules @"NumFeatureExtractionModules"
#define kNumPostprocessingModules @"NumPostprocessingModules"
#define kTrained @"Trained"
#define kPreProcessingType @"PreProcessingType"
#define kFeatureExtractionType @"FeatureExtractionType"
// set to @"" if not set
#define kClassifierType @"ClassifierType"
// set to @"" if not set
#define kRegressifierType @"RegressifierType"
#define kPostProcessingType @"PostProcessingType"
#define kPreProcessingModule @"PreProcessingModule"


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    // TODO: impelement encoding of the pipeline
    [aCoder encodeObject:self.pipelineName forKey:@"name"];
    
    //Write the pipeline header info
    [aCoder encodeObject:self.fileHeader forKey:kFileHeader];
    
    NSString *tmpString = [NSString stringWithCString:pipeline.getPipelineModeAsString().c_str() encoding:[NSString defaultCStringEncoding]];
    [aCoder encodeObject:tmpString forKey:kPipelineMode];
    
    [aCoder encodeInt:pipeline.getNumPreProcessingModules() forKey:kNumPreprocessingModules];
    [aCoder encodeInt:pipeline.getNumFeatureExtractionModules() forKey:kNumFeatureExtractionModules];
    [aCoder encodeInt:pipeline.getNumPostProcessingModules() forKey:kNumPostprocessingModules];
    [aCoder encodeBool:pipeline.getTrained() forKey:kTrained];

    //Write the module datatype names
    // "PreProcessingModuleDatatypes:";
    NSString *keyString = kPreProcessingType;
    for(uint i=0; i< pipeline.getNumPreProcessingModules(); i++){
        tmpString = [NSString stringWithCString:pipeline.getPreProcessingModule(i)->getPreProcessingType().c_str() encoding:[NSString defaultCStringEncoding]];
        [aCoder encodeObject:tmpString forKey:[keyString stringByAppendingString:[NSString stringWithFormat:@"%d", i]]];
    }

    //"FeatureExtractionModuleDatatypes:";
    keyString = kFeatureExtractionType;
    for(uint i=0; i< pipeline.getNumFeatureExtractionModules(); i++){
        tmpString = [NSString stringWithCString:pipeline.getFeatureExtractionModule(i)->getFeatureExtractionType().c_str() encoding:[NSString defaultCStringEncoding]];
        [aCoder encodeObject:tmpString forKey:[keyString stringByAppendingString:[NSString stringWithFormat:@"%d", i]]];
    }

  
    switch( pipeline.getPipelineModeFromString( pipeline.getPipelineModeAsString() ) ){
        case GRT::GestureRecognitionPipeline::PIPELINE_MODE_NOT_SET:
            [aCoder encodeObject:@"" forKey:kClassifierType];
            [aCoder encodeObject:@"" forKey:kRegressifierType];
        case GRT::GestureRecognitionPipeline::CLASSIFICATION_MODE:
            [aCoder encodeObject:@"" forKey:kRegressifierType];
            if( pipeline.getIsClassifierSet() ){
                tmpString = [NSString stringWithCString:pipeline.getClassifier()->getClassifierType().c_str() encoding:[NSString defaultCStringEncoding]];
                [aCoder encodeObject:tmpString forKey:kClassifierType];
            } else {
                [aCoder encodeObject:@"CLASSIFIER_NOT_SET" forKey:kClassifierType];
            }
            break;
        case GRT::GestureRecognitionPipeline::REGRESSION_MODE:
            [aCoder encodeObject:@"" forKey:kClassifierType];
            if( pipeline.getIsRegressifierSet()){
                tmpString = [NSString stringWithCString:pipeline.getRegressifier()->getRegressifierType().c_str() encoding:[NSString defaultCStringEncoding]];
                [aCoder encodeObject:tmpString forKey:kRegressifierType];
            } else {
                [aCoder encodeObject:@"REGRESSIFIER_NOT_SET" forKey:kRegressifierType];
            }
            break;
        default:
            break;
    }
    
    // "PostProcessingModuleDatatypes"
    keyString = kPostProcessingType;
    for(uint i=0; i< pipeline.getNumPostProcessingModules(); i++){
        tmpString = [NSString stringWithCString:pipeline.getPostProcessingModule(i)->getPostProcessingType().c_str() encoding:[NSString defaultCStringEncoding]];
        [aCoder encodeObject:tmpString forKey:[keyString stringByAppendingString:[NSString stringWithFormat:@"%d", i]]];
    }
    
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                               NSUserDomainMask, YES);
    
    NSString *documentsPath = [searchPaths objectAtIndex:0];
    
    std::string respath( [ documentsPath UTF8String ] ) ;
    std::string fpath = respath + "/" + "save.txt" ;
    NSString *fpathNS = [NSString stringWithCString:fpath.c_str() encoding:[NSString defaultCStringEncoding]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fpathNS]) { // if file is not exist, create it.
        NSString *helloStr = @"hello world";
        NSError *error;
       // [helloStr writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
    std::fstream file = std::fstream();
    std::stringstream ss;
    file.open(fpath.c_str());
    if (file.is_open()) {
        NSLog(@"opened! :D");
    }
    //Write the preprocessing module data as into a single string
    keyString = kPreProcessingModule;
    for (uint i = 0; i < pipeline.getNumPreProcessingModules(); i++) {
        
        // TODO: check if I have to open the fstream before I write to it
        pipeline.getPreProcessingModule(i)->saveSettingsToFile(file);
        ss << (file.rdbuf());
        NSString *moduleSettings = [NSString stringWithCString:ss.str().c_str() encoding:[NSString defaultCStringEncoding]];
        [aCoder encodeObject:moduleSettings forKey:[keyString stringByAppendingString:[NSString stringWithFormat:@"%d", i]]];
        NSLog(@"%@", moduleSettings);
    }
    file.close();
    
    /*
    for(UINT i=0; i<getNumPreProcessingModules(); i++){
        file << "PreProcessingModule_" << Util::intToString(i+1) << endl;
        if( !preProcessingModules[i]->saveSettingsToFile( file ) ){
            errorLog << "Failed to write preprocessing module " << i << " settings to file!" << endl;
            file.close();
            return false;
        }
    }
    */
    
    //Write the feature extraction module data to the file
    // TODO
    /*
    for(UINT i=0; i<getNumFeatureExtractionModules(); i++){
        file << "FeatureExtractionModule_" << Util::intToString(i+1) << endl;
        if( !featureExtractionModules[i]->saveSettingsToFile( file ) ){
            errorLog << "Failed to write feature extraction module " << i << " settings to file!" << endl;
            file.close();
            return false;
        }
    }
    */
    
    // TODO
    /*
    switch( pipelineMode ){
        case PIPELINE_MODE_NOT_SET:
            break;
        case CLASSIFICATION_MODE:
            if( getIsClassifierSet() ){
                if( !classifier->saveModelToFile( file ) ){
                    errorLog << "Failed to write classifier model to file!" << endl;
                    file.close();
                    return false;
                }
            }
            break;
        case REGRESSION_MODE:
            if( getIsRegressifierSet() ){
                if( !regressifier->saveModelToFile( file ) ){
                    errorLog << "Failed to write regressifier model to file!" << endl;
                    file.close();
                    return false;
                }
            }
            break;
        default:
            break;
    }
    */
    
    //Write the post processing module data to the file
    // TODO:
    /*
    for(UINT i=0; i<getNumPostProcessingModules(); i++){
        file << "PostProcessingModule_" << Util::intToString(i+1) << endl;
        if( !postProcessingModules[i]->saveSettingsToFile( file ) ){
            errorLog <<"Failed to write post processing module " << i << " settings to file!" << endl;
            file.close();
            return false;
        }
    }
     */
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [[NZGestureRecognitionPipeline alloc] init];
    self.fileHeader = [aDecoder decodeObjectForKey:kFileHeader];
    self.pipelineName = [aDecoder decodeObjectForKey:@"name"];
    NSString *pipelineMode = [aDecoder decodeObjectForKey:kPipelineMode];
    std::string *pipelineModeString = new string([pipelineMode UTF8String]);
    ;
    pipeline.setPipelineMode(GRT::GestureRecognitionPipeline::PipelineModes(pipeline.getPipelineModeFromString( *pipelineModeString )));
    
    // TODO: use when setting preprocessing modes
    //[aCoder encodeInt:pipeline.getNumPreProcessingModules() forKey:kNumPreprocessingModules];
    //[aCoder encodeInt:pipeline.getNumFeatureExtractionModules() forKey:kNumFeatureExtractionModules];
    //[aCoder encodeInt:pipeline.getNumPostProcessingModules() forKey:kNumPostprocessingModules];
    pipeline.setTrained( [aDecoder decodeObjectForKey:kTrained] );
    // TODO: set up the pipeline properly
    return self;
}

@end
