//
//  BXDashboardViewController.m
//  Boxy
//
//  Created by Christian Le on 11/5/15.
//  Copyright © 2015 christianle. All rights reserved.
//

#import "BXDashboardViewController.h"
#import "BXGraphViewController.h"
#import "BXSyncViewController.h"
#import "BXStyling.h"
#import "BXPageViewChildProtocol.h"

@interface BXDashboardViewController ()

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) BXSyncViewController *syncViewController;
@property (strong, nonatomic) BXGraphViewController *graphViewController;
@property (strong, nonatomic) UISegmentedControl *pageViewSegmentedSwitcher;
@property (strong, nonatomic) NSMutableArray *pageViewChildren;

@end

@implementation BXDashboardViewController

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"Dashboard";
        self.navigationController.navigationBar.tintColor =
            [BXStyling lightColor];
        self.navigationController.navigationBar.barTintColor =
            [BXStyling lightColor];
        self.view.backgroundColor = [BXStyling lightColor];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupPageView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self _installConstraints];
}

- (void)setupPageView {
    NSArray *pageTitles = [NSArray arrayWithObjects:@"Sync", @"Graph", nil];
    _pageViewSegmentedSwitcher =
        [[UISegmentedControl alloc] initWithItems:pageTitles];
    [_pageViewSegmentedSwitcher addTarget:self
                                   action:@selector(switchPages:)
                         forControlEvents:UIControlEventValueChanged];
    _pageViewSegmentedSwitcher.selectedSegmentIndex = 0;
    _pageViewSegmentedSwitcher.tintColor = [BXStyling darkColor];

    _syncViewController = [[BXSyncViewController alloc] init];
    _syncViewController.delegate = self;

    _graphViewController = [[BXGraphViewController alloc] init];

    _pageViewChildren = [[NSMutableArray alloc] init];
    [_pageViewChildren addObject:_syncViewController];
    [_pageViewChildren addObject:_graphViewController];
    for (int i = 0; i < _pageViewChildren.count; i++) {
        [(UIViewController<BXPageViewChildProtocol> *)_pageViewChildren[i]
            setPageIndex:i];
    }

    _pageViewController = [[UIPageViewController alloc]
        initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
          navigationOrientation:
              UIPageViewControllerNavigationOrientationHorizontal
                        options:nil];

    [_pageViewController.view setFrame:[self.view bounds]];
    [_pageViewController
        setViewControllers:[NSArray arrayWithObject:_pageViewChildren[0]]
                 direction:UIPageViewControllerNavigationDirectionForward
                  animated:NO
                completion:nil];

    [self addChildViewController:_pageViewController];

    [self.view addSubview:_pageViewSegmentedSwitcher];
    [self.view addSubview:_pageViewController.view];

    [_pageViewController didMoveToParentViewController:self];
}

#pragma mark - Handle Bluetooth Data

- (void)handleReceivedData:(unsigned char *)data length:(int)length {
    NSData *d = [NSData dataWithBytes:data length:length];
    NSString *s =
        [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    NSLog(@"%@", s);

    [_graphViewController setDataCount:20 range:100.0];
    [_syncViewController updateData:s];
}

- (void)sendPeripheralRequest:(NSString *)request {
    if (request.length > 16) {
        request = [request substringToIndex:16];
    }
    [_ble write:[request dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark - Handle Page Switching

- (void)switchPages:(UISegmentedControl *)segmentedControl {
    NSInteger index = segmentedControl.selectedSegmentIndex;
    UIViewController *vc = _pageViewChildren[index];

    [_pageViewController
        setViewControllers:[NSArray arrayWithObject:vc]
                 direction:UIPageViewControllerNavigationDirectionForward
                  animated:NO
                completion:nil];
}

#pragma mark - Constraints

- (void)_installConstraints {
    self.view.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);

    [_pageViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_pageViewSegmentedSwitcher
        setTranslatesAutoresizingMaskIntoConstraints:NO];

    UIView *pageView = _pageViewController.view;
    NSDictionary *views =
        NSDictionaryOfVariableBindings(pageView, _pageViewSegmentedSwitcher);

    NSDictionary *metrics = @{ @"margin" : @(20) };

    [self.view
        addConstraints:
            [NSLayoutConstraint
                constraintsWithVisualFormat:
                    @"V:|-[pageView]-[_pageViewSegmentedSwitcher]-margin-|"
                                    options:0
                                    metrics:metrics
                                      views:views]];

    [self.view
        addConstraints:[NSLayoutConstraint
                           constraintsWithVisualFormat:@"H:|-[pageView]-|"
                                               options:0
                                               metrics:metrics
                                                 views:views]];

    [self.view addConstraints:
                   [NSLayoutConstraint
                       constraintsWithVisualFormat:
                           @"H:|-margin-[_pageViewSegmentedSwitcher]-margin-|"
                                           options:0
                                           metrics:metrics
                                             views:views]];

    [self.view
        addConstraint:[NSLayoutConstraint
                          constraintWithItem:_pageViewSegmentedSwitcher
                                   attribute:NSLayoutAttributeHeight
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:nil
                                   attribute:NSLayoutAttributeNotAnAttribute
                                  multiplier:0
                                    constant:35.0]];
}

@end
