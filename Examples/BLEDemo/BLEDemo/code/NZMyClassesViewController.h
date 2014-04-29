//
//  NZMyClassesViewController.h
//  BLEDemo
//
//  Created by Natalia Zarawska on 24/04/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NZMyClassesViewController : UIViewController

- (IBAction)loadDataButtonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *loadedDataText;


@end
