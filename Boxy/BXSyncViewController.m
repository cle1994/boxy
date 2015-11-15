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

@end

@implementation BXSyncViewController

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"Sync";
        self.navigationController.navigationBar.tintColor =
            [BXStyling lightColor];
        self.navigationController.navigationBar.barTintColor =
            [BXStyling lightColor];

        _helloCountView = [[UILabel alloc] init];
        _helloCountView.textAlignment = NSTextAlignmentCenter;
        _helloCountView.font = [UIFont systemFontOfSize:25];
        _helloCountView.backgroundColor = [BXStyling lightColor];
        _helloCountView.textColor = [BXStyling darkColor];

        [self.view addSubview:_helloCountView];
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
    [_helloCountView setText:data];
}

#pragma mark - Constraints

- (void)_installConstraints {
    self.view.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);

    [_helloCountView setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSDictionary *views = NSDictionaryOfVariableBindings(_helloCountView);

    NSDictionary *metrics = @{ @"margin" : @(20) };

    [self.view addConstraints:[NSLayoutConstraint
                                  constraintsWithVisualFormat:
                                      @"V:|-margin-[_helloCountView]-margin-|"
                                                      options:0
                                                      metrics:metrics
                                                        views:views]];

    [self.view addConstraints:[NSLayoutConstraint
                                  constraintsWithVisualFormat:
                                      @"H:|-margin-[_helloCountView]-margin-|"
                                                      options:0
                                                      metrics:metrics
                                                        views:views]];
}

@end
