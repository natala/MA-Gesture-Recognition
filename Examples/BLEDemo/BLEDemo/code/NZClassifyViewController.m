//
//  NZClassifyViewController.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 13/04/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "NZClassifyViewController.h"

@interface NZClassifyViewController ()

@end

@implementation NZClassifyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)classifyButtonTapped:(id)sender {
    if (!self.delegate) {
        return;
    }
    [self.delegate startClassifying];
    UIButton *button = (UIButton *)sender;
    if ([button.currentTitle isEqual:@"Classify"]) {
        [button setTitle:@"Stop classifying" forState:UIControlStateNormal];
    } else {
        [button setTitle:@"Classify" forState:UIControlStateNormal];
    }
}
@end
