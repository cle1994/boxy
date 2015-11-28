//
//  BXHomeViewController.m
//  Boxy
//
//  Created by Christian Le on 11/25/15.
//  Copyright © 2015 christianle. All rights reserved.
//

#import "BXHomeViewController.h"
#import "BXHomeWorkoutViewController.h"
#import "BXStyling.h"

@interface BXHomeViewController ()<BXHomeViewControllerDelegate>

@property (strong, nonatomic) BXHomeWorkoutViewController *currentWorkoutView;
@property (strong, nonatomic) BXHomeWorkoutViewController *previousWorkoutView;

@end

@implementation BXHomeViewController

- (instancetype)init {
    if (self = [super init]) {
        NSMutableArray *currentWorkout = [[NSMutableArray alloc] init];
        [currentWorkout addObject:@{ @"title": @"Squat", @"weight": @(200), @"sets": @(4), @"reps": @(12) }];
        [currentWorkout addObject:@{ @"title": @"OH Press", @"weight": @(150), @"sets": @(3), @"reps": @(8) }];
        [currentWorkout addObject:@{ @"title": @"Deadlift", @"weight": @(250), @"sets": @(3), @"reps": @(3) }];

        NSMutableArray *previousWorkout = [[NSMutableArray alloc] init];
        [previousWorkout addObject:@{ @"title": @"Squat", @"weight": @(200), @"sets": @(4), @"reps": @(12) }];
        [previousWorkout addObject:@{ @"title": @"Bench", @"weight": @(200), @"sets": @(3), @"reps": @(3) }];
        [previousWorkout addObject:@{ @"title": @"Row", @"weight": @(250), @"sets": @(3), @"reps": @(10) }];

        _currentWorkoutView = [[BXHomeWorkoutViewController alloc] initWithAction:BXHomeActionTypeCurrent AndTitle:@"Next Workout" AndWorkouts:currentWorkout];
        _currentWorkoutView.delegate = self;
        self.currentWorkout = currentWorkout;

        _previousWorkoutView =
            [[BXHomeWorkoutViewController alloc] initWithAction:BXHomeActionTypeTwitter AndTitle:@"Previous Workout" AndWorkouts:previousWorkout];
        _previousWorkoutView.delegate = self;
        self.previousWorkout = previousWorkout;

        [self addChildViewController:_currentWorkoutView];
        [self.view addSubview:_currentWorkoutView.view];
        [_currentWorkoutView didMoveToParentViewController:self];

        [self addChildViewController:_previousWorkoutView];
        [self.view addSubview:_previousWorkoutView.view];
        [_previousWorkoutView didMoveToParentViewController:self];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGSize viewSize = self.view.bounds.size;
    CGFloat currentWorkoutHeight = [_currentWorkoutView getViewHeight];
    CGFloat previousWorkoutHeight = [_previousWorkoutView getViewHeight];

    _currentWorkoutView.view.frame = CGRectMake(0, 0, viewSize.width, currentWorkoutHeight);
    _previousWorkoutView.view.frame = CGRectMake(0, currentWorkoutHeight, viewSize.width, previousWorkoutHeight);
}

- (void)updateWorkoutsOnView {
    _currentWorkoutView.workouts = _currentWorkout;
    _previousWorkoutView.workouts = _previousWorkout;
}

#pragma mark - BXHomeViewControllerDelegate

- (void)sendToTwitter:(NSString *)message {
    [self.delegate postToTwitter:message];
}

- (void)layoutSubviews {
    [self.view setNeedsLayout];
}

- (void)sendWorkout:(NSArray *)workout {
    [self.delegate sendWorkout:workout];
}

@end
