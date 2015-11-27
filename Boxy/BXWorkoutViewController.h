//
//  BXWorkoutViewController.h
//  Boxy
//
//  Created by Christian Le on 11/25/15.
//  Copyright © 2015 christianle. All rights reserved.
//

@import UIKit;

#import "BXHomeWorkoutViewController.h"

@interface BXWorkoutViewController : UIViewController

@property (strong, nonatomic) id<BXHomeWorkoutViewControllerDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *workouts;

@end
