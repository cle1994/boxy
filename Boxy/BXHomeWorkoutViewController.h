//
//  BXHomeCurrentWorkoutViewController.h
//  Boxy
//
//  Created by Christian Le on 11/25/15.
//  Copyright © 2015 christianle. All rights reserved.
//

@import UIKit;

#import "BXHomeViewController.h"

typedef NS_ENUM(NSInteger, BXHomeActionType) { BXHomeActionTypeNone, BXHomeActionTypeTwitter, BXHomeActionTypeCurrent };

@protocol BXHomeWorkoutViewControllerDelegate<NSObject>

- (void)updateCurrentWorkoutAtIndexPath:(NSIndexPath *)indexPath;
- (void)refreshCurrentWorkout;

@end

@interface BXHomeWorkoutViewController : UIViewController<BXHomeWorkoutViewControllerDelegate>

@property (strong, nonatomic) id<BXHomeViewControllerDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *workouts;

- (instancetype)initWithAction:(BXHomeActionType)action AndTitle:(NSString *)title AndWorkouts:(NSMutableArray *)workouts;
- (CGFloat)getViewHeight;

@end
