//
//  BXSyncingPopupViewController.m
//  Boxy
//
//  Created by Christian Le on 11/12/15.
//  Copyright © 2015 christianle. All rights reserved.
//

#import "BXSyncingPopupViewController.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"
#import "BXStyling.h"

@interface BXSyncingPopupViewController ()

@property (nonatomic, strong) FLAnimatedImageView *syncIcon;
@property (nonatomic) BOOL shouldAnimate;

@end

@implementation BXSyncingPopupViewController

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"Sync";
        self.navigationController.navigationBar.tintColor = [BXStyling lightColor];
        self.navigationController.navigationBar.barTintColor = [BXStyling lightColor];

        self.view.backgroundColor = [[BXStyling lightColor] colorWithAlphaComponent:0.95];

        _shouldAnimate = NO;

        _syncIcon = [[FLAnimatedImageView alloc] init];
        _syncIcon.contentMode = UIViewContentModeScaleAspectFill;
        _syncIcon.clipsToBounds = YES;

        NSURL *url = [[NSBundle mainBundle] URLForResource:@"loading" withExtension:@"gif"];
        NSData *gifData = [NSData dataWithContentsOfURL:url];
        FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:gifData];
        _syncIcon.animatedImage = animatedImage;

        UIGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [singleTapRecognizer setCancelsTouchesInView:NO];
        [self.view addGestureRecognizer:singleTapRecognizer];

        [self.view addSubview:_syncIcon];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self _installConstraints];
    [self animate];
}

- (void)shouldAnimate:(BOOL)animate {
    _shouldAnimate = animate;
}

- (void)animate {
    if (_shouldAnimate) {
        [_syncIcon startAnimating];
    } else {
        [_syncIcon stopAnimating];
    }
}

- (void)closePopup {
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

#pragma mark - Gesture Recognizers

- (void)handleSingleTap:(UITapGestureRecognizer *)sender {
    [self closePopup];
}

#pragma mark - Constraints

- (void)_installConstraints {
    self.view.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);

    [_syncIcon setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_syncIcon
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0.7
                                                           constant:0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_syncIcon
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_syncIcon
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_syncIcon
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_syncIcon
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0]];
}

@end
