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

@property (strong, nonatomic) BXHomeWorkoutViewController *currentWorkout;
@property (strong, nonatomic) BXHomeWorkoutViewController *previousWorkout;

@end

@implementation BXHomeViewController

- (instancetype)init {
    if (self = [super init]) {
        _currentWorkout = [[BXHomeWorkoutViewController alloc] initWithAction:BXHomeActionTypeCurrent AndTitle:@"Next Workout"];
        _currentWorkout.delegate = self;

        _previousWorkout = [[BXHomeWorkoutViewController alloc] initWithAction:BXHomeActionTypeTwitter AndTitle:@"Previous Workout"];
        _previousWorkout.delegate = self;

        [self addChildViewController:_currentWorkout];
        [self.view addSubview:_currentWorkout.view];
        [_currentWorkout didMoveToParentViewController:self];

        [self addChildViewController:_previousWorkout];
        [self.view addSubview:_previousWorkout.view];
        [_previousWorkout didMoveToParentViewController:self];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGSize viewSize = self.view.bounds.size;
    CGFloat currentWorkoutHeight = [_currentWorkout getViewHeight];
    CGFloat previousWorkoutHeight = [_previousWorkout getViewHeight];

    _currentWorkout.view.frame = CGRectMake(0, 0, viewSize.width, currentWorkoutHeight);
    _previousWorkout.view.frame = CGRectMake(0, currentWorkoutHeight, viewSize.width, previousWorkoutHeight);
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
