//
//  BXSyncViewController.m
//  Boxy
//
//  Created by Christian Le on 11/10/15.
//  Copyright © 2015 christianle. All rights reserved.
//

@import QuartzCore;

#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"
#import "BXSyncViewController.h"
#import "BXDashboardBLEDelegate.h"
#import "BXStyling.h"

@interface BXSyncViewController ()

@property (strong, nonatomic) UILabel *helloCountView;
@property (strong, nonatomic) UIButton *syncButton;
@property (nonatomic, strong) FLAnimatedImageView *syncIcon;

@end

@implementation BXSyncViewController
@synthesize delegate;

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"Sync";
        self.navigationController.navigationBar.tintColor =
            [BXStyling lightColor];
        self.navigationController.navigationBar.barTintColor =
            [BXStyling lightColor];

        _syncButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_syncButton setEnabled:YES];
        [_syncButton addTarget:self
                        action:@selector(syncPeripheralData)
              forControlEvents:UIControlEventTouchUpInside];

        _syncIcon = [[FLAnimatedImageView alloc] init];
        _syncIcon.contentMode = UIViewContentModeScaleAspectFill;
        _syncIcon.clipsToBounds = YES;

        NSURL *url = [[NSBundle mainBundle] URLForResource:@"loading"
                                             withExtension:@"gif"];
        NSData *gifData = [NSData dataWithContentsOfURL:url];
        FLAnimatedImage *animatedImage =
            [FLAnimatedImage animatedImageWithGIFData:gifData];
        _syncIcon.animatedImage = animatedImage;

        [_syncButton addSubview:_syncIcon];

        _helloCountView = [[UILabel alloc] init];
        _helloCountView.textAlignment = NSTextAlignmentCenter;
        _helloCountView.font = [UIFont systemFontOfSize:25];
        _helloCountView.backgroundColor = [BXStyling lightColor];
        _helloCountView.textColor = [BXStyling darkColor];

        [self.view addSubview:_helloCountView];
        [self.view addSubview:_syncButton];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self _installConstraints];
}

- (void)updateData:(NSString *)data {
    [_syncButton setEnabled:YES];
    [_syncIcon stopAnimating];
    [_helloCountView setText:data];
}

#pragma mark - Sync Data

- (void)syncPeripheralData {
    [_syncButton setEnabled:NO];
    [_syncIcon startAnimating];
    [self.delegate sendPeripheralRequest:@"d"];
}

#pragma mark - Constraints

- (void)_installConstraints {
    self.view.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);

    [_syncButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_helloCountView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_syncIcon setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSDictionary *views =
        NSDictionaryOfVariableBindings(_helloCountView, _syncButton);

    NSDictionary *metrics = @{ @"margin" : @(20) };

    [self.view
        addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                                               @"V:|-margin-[_syncButton]-"
                                           @"margin-[_helloCountView]-margin-|"
                                                               options:0
                                                               metrics:metrics
                                                                 views:views]];

    [self.view addConstraints:[NSLayoutConstraint
                                  constraintsWithVisualFormat:
                                      @"H:|-margin-[_helloCountView]-margin-|"
                                                      options:0
                                                      metrics:metrics
                                                        views:views]];

    [self.view addConstraints:[NSLayoutConstraint
                                  constraintsWithVisualFormat:
                                      @"H:|-margin-[_syncButton]-margin-|"
                                                      options:0
                                                      metrics:metrics
                                                        views:views]];

    [self.view addConstraint:[NSLayoutConstraint
                                 constraintWithItem:_syncButton
                                          attribute:NSLayoutAttributeHeight
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:_syncButton
                                          attribute:NSLayoutAttributeWidth
                                         multiplier:1
                                           constant:0]];

    NSDictionary *animatedButtonViews =
        NSDictionaryOfVariableBindings(_syncIcon);

    [_syncButton
        addConstraints:[NSLayoutConstraint
                           constraintsWithVisualFormat:@"V:|-[_syncIcon]-|"
                                               options:0
                                               metrics:nil
                                                 views:animatedButtonViews]];

    [_syncButton
        addConstraints:[NSLayoutConstraint
                           constraintsWithVisualFormat:@"H:|-[_syncIcon]-|"
                                               options:0
                                               metrics:nil
                                                 views:animatedButtonViews]];

    [_syncButton addConstraint:[NSLayoutConstraint
                                   constraintWithItem:_syncIcon
                                            attribute:NSLayoutAttributeWidth
                                            relatedBy:NSLayoutRelationEqual
                                               toItem:_syncIcon
                                            attribute:NSLayoutAttributeHeight
                                           multiplier:1.0
                                             constant:0]];
    
    if (!_syncButton.enabled) {
        [_syncIcon startAnimating];
    } else {
        [_syncIcon stopAnimating];
    }
}

@end
