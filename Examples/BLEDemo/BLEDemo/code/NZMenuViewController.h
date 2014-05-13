//
//  NZMenuViewController.h
//  BLEDemo
//
//  Created by Natalia Zarawska on 24/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SensorData.h"
#import "NZTraningViewController.h"
#import "NZClassifyViewController.h"

@interface NZMenuViewController : UIViewController //<NZTraningViewControllerDelegate, NZClassifyViewControllerDelegate>

@property BOOL recordingData;
@property (weak, nonatomic) NSString *currentClassLabel;

//@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
- (IBAction)trainButtonTaped:(id)sender;
- (IBAction)classifyButtonTaped:(id)sender;
- (IBAction)myClassesButtonTaped:(id)sender;

//- (void)receivedData:(SensorData *)data;

@end
