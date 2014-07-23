//
//  NZLeftSlideViewController.h
//  BLEDemo
//
//  Created by Natalia Zarawska on 26/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKSlideViewController.h"

@interface NZLeftSlideViewController : UIViewController <SKSlideViewDelegate>

@property (weak, nonatomic) SKSlideViewController *slideController;

@end
