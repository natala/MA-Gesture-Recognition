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

@synthesize menuTableView;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
       [self commonInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    menuOptions = [NSArray arrayWithObjects:@"Train", @"Classify", @"My Casses", nil];
    menuCellIdentifier = @"MenuCellId";
}

- (void)viewWillLayoutSubviews
{
    //TODO doesn't work, figure out how to dinamically adjust the size of the view without subclassing or subclass
    [super viewWillLayoutSubviews];
    CGRect frame = menuTableView.frame;
    frame.size.height = MIN( menuTableView.rowHeight*[menuOptions count], self.view.frame.size.height);
    menuTableView.frame = frame;
    [self reloadInputViews];
    
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

@end
