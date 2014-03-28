//
//  NZMenuViewController.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 24/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "NZMenuViewController.h"

@interface NZMenuViewController ()

@end


@implementation NZMenuViewController
{
    NSArray *menuOptions;
    NSString *menuCellIdentifier;
}

//@synthesize menuTableView;

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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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

- (IBAction)trainButton:(id)sender {
}
- (IBAction)trainButtonTaped:(id)sender {
}

- (IBAction)classifyButtonTaped:(id)sender {
}

- (IBAction)myClassesButtonTaped:(id)sender {
}

- (IBAction)showMpuDataTaped:(id)sender {
}
@end
