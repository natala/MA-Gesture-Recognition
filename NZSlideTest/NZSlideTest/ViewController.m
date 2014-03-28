//
//  ViewController.m
//  NZSlideTest
//
//  Created by Natalia Zarawska on 26/03/14.
//  Copyright (c) 2014 Natalia Zarawska. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()



@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    int c = [[self childViewControllers] count];
    UIViewController *vc = [[self childViewControllers] objectAtIndex:0];
    [vc.view setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0] ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"embededContainer"]) {
        UIViewController * childViewController = (UIViewController *) [segue destinationViewController];
         UI* alertView = childViewController.view;
        // do something with the AlertView's subviews here...
    }
}
*/
@end
