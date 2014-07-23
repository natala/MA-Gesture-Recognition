//
//  NZMainViewController.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 26/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "NZMainViewController.h"
#import "SKSlideViewController.h"

@interface NZMainViewController ()

@end

@implementation NZMainViewController

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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"SlideVC"]){
        SKSlideViewController *slideController=(SKSlideViewController *)[segue destinationViewController];
       // UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
       //                                                          bundle:[NSBundle mainBundle]];
       // UIViewController<SKSlideViewDelegate> *mainVC = (UIViewController<SKSlideViewDelegate>*)[mainStoryboard
       //                                                    instantiateViewControllerWithIdentifier: @"MainVC"];
        //UIViewController<SKSlideViewDelegate> *viewContainer = [mainVC.childViewControllers objectAtIndex:0];
        
        //[slideController setSlideViewControllerUsingMainViewController:mainVC leftViewController:viewContainer rightViewController:viewContainer];
        [slideController setStoryBoardIDForMainController:@"MainVC" leftController:@"LeftVC" rightController:@"LeftVC"];
        [slideController reloadControllers];
    }
}

- (IBAction)startTapped:(id)sender {
    
    [self performSegueWithIdentifier:@"SlideVC" sender:sender];
}
@end
