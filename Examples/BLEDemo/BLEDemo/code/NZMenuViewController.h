//
//  NZMenuViewController.h
//  BLEDemo
//
//  Created by Natalia Zarawska on 24/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NZMenuViewController : UIViewController //<UITableViewDataSource, UITableViewDelegate>

//@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
- (IBAction)trainButtonTaped:(id)sender;
- (IBAction)classifyButtonTaped:(id)sender;
- (IBAction)myClassesButtonTaped:(id)sender;
- (IBAction)showMpuDataTaped:(id)sender;



@end
