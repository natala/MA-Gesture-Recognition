//
//  NZMenuViewController.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 24/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "NZMenuViewController.h"
#import "NZTraningViewController.h"
#import "NZClassificationController.h"

@interface NZMenuViewController ()

@property (strong, nonatomic) NZClassificationController *classificationController;

@end


@implementation NZMenuViewController
{
    NSArray *menuOptions;
    NSString *menuCellIdentifier;
}

@synthesize currentClassLabel = _currentClassLabel;

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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _classificationController = [[NZClassificationController alloc] init];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [menuOptions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:menuCellIdentifier];
    }
    cell.textLabel.text = [menuOptions objectAtIndex:indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

#pragma UITableViewDelegate
 */

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"train"]){
        NZTraningViewController *trainVC =(NZTraningViewController *)[segue destinationViewController];
        trainVC.menuVC = self;
        trainVC.currentClassLable = self.currentClassLabel;
    }
}

- (void)receivedData:(SensorData *)data
{
  // TODO
}

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



@end
