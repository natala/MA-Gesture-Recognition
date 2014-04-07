//
//  NZTraningViewController.h
//  BLEDemo
//
//  Created by Natalia Zarawska on 06/04/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NZMenuViewController.h"

@interface NZTraningViewController : UIViewController <UITextFieldDelegate>

//@property NZClassificationController *classificationController;
@property (weak, nonatomic) NZMenuViewController *menuVC;

@property (retain, nonatomic) NSString *currentClassLable;

@property (weak, nonatomic) IBOutlet UITextField *classNameTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gestureType;
@property (weak, nonatomic) IBOutlet UIButton *recordControlButton;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSamples;
@end
