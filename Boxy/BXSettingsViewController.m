//
//  BXTwitterSignInViewController.m
//  Boxy
//
//  Created by Christian Le on 11/16/15.
//  Copyright © 2015 christianle. All rights reserved.
//

@import SSKeychain;

#import "BXSettingsViewController.h"
#import "BXStyling.h"

@interface BXSettingsViewController ()<STTwitterAPIOSProtocol>

@property (strong, nonatomic) UITextField *twitterLogin;
@property (strong, nonatomic) UITextField *twitterPassword;
@property (strong, nonatomic) UIButton *twitterButton;
@property (nonatomic) BOOL shouldHideTwitterLogin;

@end

NSString *const TwitterString = @"Twitter";
NSString *const TwitterLogin = @"TwitterLogin";
NSString *const TwitterKey = @"AMMIgdq6BmnZSZPxgryF2P3Gd";
NSString *const TwitterSecret =
    @"ZkumQqABuoqG6WgbLQZVoSvJqgTQ4ACcet0jOqCIYC6tWL2YHi";

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

        [self loginToTwitter];

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

        [self.view addSubview:_twitterLogin];
        [self.view addSubview:_twitterPassword];
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

- (void)loginToTwitter {
    self.twitter = [STTwitterAPI twitterAPIOSWithFirstAccountAndDelegate:self];
}

#pragma mark - Selectors

- (void)dismissModal {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signInToTwitter {
    [self loginToTwitter];
}

#pragma mark - STTwiterAPIOSProtocol

- (void)twitterAPI:(STTwitterAPI *)twitterAPI
    accountWasInvalidated:(ACAccount *)invalidatedAccount {
    NSLog(@"%@", invalidatedAccount);
}

#pragma mark - Constraints

- (void)_installConstraints {
    self.view.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);

    _twitterButton.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *views = NSDictionaryOfVariableBindings(_twitterButton);

    NSDictionary *metrics = @{ @"margin" : @(20) };

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
