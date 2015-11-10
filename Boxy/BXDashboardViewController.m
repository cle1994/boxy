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

        [self setupPageView];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (_pageViewChildren.count == 0) {
        [self setupPageView];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGSize viewSize = self.view.bounds.size;
    CGFloat segmentControlHeight = 70.0;
    CGSize segmentControlInset = CGSizeMake(20, 20);

    [_pageViewController.view
        setFrame:CGRectMake(0, 0, viewSize.width,
                            viewSize.height - segmentControlHeight)];
    [_pageViewSegmentedSwitcher
        setFrame:CGRectMake(segmentControlInset.width,
                            viewSize.height - segmentControlHeight +
                                segmentControlInset.height,
                            viewSize.width - (2 * segmentControlInset.width),
                            segmentControlHeight -
                                (2 * segmentControlInset.height))];
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
    NSDictionary *views = NSDictionaryOfVariableBindings(
        _graphViewController.view, _pageViewSegmentedSwitcher);
    _graphViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    _pageViewSegmentedSwitcher.translatesAutoresizingMaskIntoConstraints = NO;
}

@end
