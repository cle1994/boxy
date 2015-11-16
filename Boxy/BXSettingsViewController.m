//
//  BXTwitterSignInViewController.m
//  Boxy
//
//  Created by Christian Le on 11/16/15.
//  Copyright © 2015 christianle. All rights reserved.
//

#import "BXSettingsViewController.h"
#import "BXStyling.h"

@interface BXSettingsViewController ()

@property (strong, nonatomic) UIButton *twitterButton;

@end

@implementation BXSettingsViewController

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"Settings";
        self.view.backgroundColor = [BXStyling lightColor];

        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                 target:self
                                 action:@selector(dismissModal)];
        [self.navigationItem.leftBarButtonItem
            setTintColor:[BXStyling blackColor]];

        _twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_twitterButton setTitle:@"Sign In to Twitter"
                        forState:UIControlStateNormal];
        [_twitterButton setTitleColor:[BXStyling primaryColor]
                             forState:UIControlStateNormal];
        [_twitterButton setTitleColor:[BXStyling mediumColor]
                             forState:UIControlStateSelected];
        [_twitterButton setTitleColor:[BXStyling mediumColor]
                             forState:UIControlStateFocused];
        [_twitterButton addTarget:self
                           action:@selector(signInToTwitter)
                 forControlEvents:UIControlEventTouchUpInside];

        [self.view addSubview:_twitterButton];
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

#pragma mark - Selectors

- (void)dismissModal {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signInToTwitter {
    NSLog(@"Twitter");
}

#pragma mark - Constraints

- (void)_installConstraints {
    self.view.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);

    _twitterButton.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *views = NSDictionaryOfVariableBindings(_twitterButton);

    NSDictionary *metrics = @{ @"margin" : @(30) };

    [self.view addConstraints:[NSLayoutConstraint
                                  constraintsWithVisualFormat:
                                      @"H:|-margin-[_twitterButton]-margin-|"
                                                      options:0
                                                      metrics:metrics
                                                        views:views]];

    [self.view addConstraints:[NSLayoutConstraint
                                  constraintsWithVisualFormat:
                                      @"V:|-margin-[_twitterButton]-margin-|"
                                                      options:0
                                                      metrics:metrics
                                                        views:views]];
}

@end
