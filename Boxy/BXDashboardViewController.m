//
//  BXDashboardViewController.m
//  Boxy
//
//  Created by Christian Le on 11/5/15.
//  Copyright © 2015 christianle. All rights reserved.
//

#import "BXDashboardViewController.h"
#import "BXNavigationController.h"
#import "BXPageViewChildProtocol.h"
#import "BXGraphViewController.h"
#import "BXSyncViewController.h"
#import "BXSettingsViewController.h"
#import "BXSyncingPopupViewController.h"
#import "BXStyling.h"
#import "BLE.h"

@interface BXDashboardViewController ()<BLEDelegate>

// BLE
@property (strong, nonatomic) BLE *ble;
@property (strong, nonatomic) BXConnectViewController *connectViewController;
@property (strong, nonatomic) NSMutableArray *devices;
@property (strong, nonatomic) NSString *lastUUID;
@property (nonatomic) BOOL isFindingLast;
@property (strong, nonatomic) BXSyncingPopupViewController *popupViewController;

// Segmented Pages
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) BXSyncViewController *syncViewController;
@property (strong, nonatomic) BXGraphViewController *graphViewController;
@property (strong, nonatomic) UISegmentedControl *pageViewSegmentedSwitcher;
@property (strong, nonatomic) NSMutableArray *pageViewChildren;

// Settings
@property (strong, nonatomic) BXSettingsViewController *settingsViewController;

@end

NSString *const UUIDPrefKey = @"UUIDPrefKey";

@implementation BXDashboardViewController

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"Dashboard";
        self.navigationController.navigationBar.tintColor =
            [BXStyling lightColor];
        self.navigationController.navigationBar.barTintColor =
            [BXStyling lightColor];
        self.view.backgroundColor = [BXStyling lightColor];

        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"SettingIcon"]
                    style:UIBarButtonItemStylePlain
                   target:self
                   action:@selector(launchSettings)];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (_ble == nil) {
        _ble = [[BLE alloc] init];
        _ble.delegate = self;
        [_ble controlSetup];
    }

    _lastUUID =
        [[NSUserDefaults standardUserDefaults] objectForKey:UUIDPrefKey];

    [self scanForDevicesAndConnectLast:YES];

    [self setupPageView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self _installConstraints];

    CGSize viewSize = self.view.bounds.size;
    [_popupViewController.view
        setFrame:CGRectMake(0, 0, viewSize.width, viewSize.height)];
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

#pragma mark - Selector

- (void)connectPeripheral {
    _connectViewController = [[BXConnectViewController alloc] init];
    _connectViewController.delegate = self;

    BXNavigationController *connectNavigationController =
        [[BXNavigationController alloc]
            initWithRootViewController:_connectViewController];

    [connectNavigationController setBarWithColor:[BXStyling primaryColor]];
    [connectNavigationController setBarStyleWithStyle:UIBarStyleDefault];
    [connectNavigationController setTitleAttributesWithAttributes:@{
        NSForegroundColorAttributeName : [BXStyling blackColor]
    }];

    [self.navigationController
        presentViewController:connectNavigationController
                     animated:YES
                   completion:^(void) {
                     [self scanForDevicesAndConnectLast:NO];
                   }];
}

- (void)syncPeripheral {
    [self sendPeripheralRequest:@"d"];
    [self addChildViewController:_popupViewController];
    [self.view addSubview:_popupViewController.view];

    [_popupViewController didMoveToParentViewController:self];

    [_popupViewController shouldAnimate:YES];
}

- (void)launchSettings {
    NSLog(@"Settings");

    _settingsViewController = [[BXSettingsViewController alloc] init];

    BXNavigationController *settingsNavigationController =
        [[BXNavigationController alloc]
            initWithRootViewController:_settingsViewController];

    [settingsNavigationController setBarWithColor:[BXStyling primaryColor]];
    [settingsNavigationController setBarStyleWithStyle:UIBarStyleDefault];
    [settingsNavigationController setTitleAttributesWithAttributes:@{
        NSForegroundColorAttributeName : [BXStyling blackColor]
    }];

    [self.navigationController
        presentViewController:settingsNavigationController
                     animated:YES
                   completion:^(void) {
                     [self scanForDevicesAndConnectLast:NO];
                   }];
}

#pragma mark - BLE Delegate

- (void)bleDidConnect {
    _lastUUID = [self getUUIDStringForPeripheral:_ble.activePeripheral];
    [[NSUserDefaults standardUserDefaults] setObject:_lastUUID
                                              forKey:UUIDPrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self updateNavigationWithPeripheralStatus:NO];

    if ([self presentedViewController] != nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)bleDidDisconnect {
    [self updateNavigationWithPeripheralStatus:NO];
}

- (void)bleDidReceiveData:(unsigned char *)data length:(int)length {
    NSData *d = [NSData dataWithBytes:data length:length];
    NSString *s =
        [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    NSLog(@"%@", s);

    [_graphViewController setDataCount:20 range:100.0];
    [_syncViewController updateData:s];
}

- (void)bleDidUpdateRSSI:(NSNumber *)rssi {
}

- (NSString *)getUUIDStringForPeripheral:(CBPeripheral *)peripheral {
    return peripheral.identifier.UUIDString;
}

#pragma mark - Device Scanning

- (void)scanForDevicesAndConnectLast:(BOOL)last {
    NSLog(@"Scanning for devices...");

    _isFindingLast = last;

    if (_ble.activePeripheral) {
        if (_ble.activePeripheral.state == CBPeripheralStateConnected) {
            [[_ble CM] cancelPeripheralConnection:[_ble activePeripheral]];
            return;
        }
    }

    if (_ble.peripherals) {
        _ble.peripherals = nil;
    }

    [_ble findBLEPeripherals:3];

    [NSTimer scheduledTimerWithTimeInterval:(float)3.0
                                     target:self
                                   selector:@selector(connectionTimer:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)connectionTimer:(NSTimer *)timer {
    NSLog(@"Checking if devices found...");

    if (_ble.peripherals.count > 0) {
        [_devices removeAllObjects];

        if (_isFindingLast) {
            for (int i = 0; i < _ble.peripherals.count; i++) {
                CBPeripheral *peripheral = [_ble.peripherals objectAtIndex:i];
                NSString *peripheralUUID =
                    [self getUUIDStringForPeripheral:peripheral];
                if (peripheralUUID ||
                    ![peripheralUUID isKindOfClass:[NSNull class]]) {
                    if ([_lastUUID isEqualToString:peripheralUUID]) {
                        [_ble connectPeripheral:peripheral];
                    }
                }
            }
        } else {
            for (int i = 0; i < _ble.peripherals.count; i++) {
                CBPeripheral *peripheral = [_ble.peripherals objectAtIndex:i];
                NSString *peripheralUUID =
                    [self getUUIDStringForPeripheral:peripheral];
                if (peripheralUUID ||
                    ![peripheralUUID isKindOfClass:[NSNull class]]) {
                    [_devices addObject:peripheral];
                }
            }
        }
    }

    if ([self presentedViewController] != nil) {
        NSLog(@"Sending devices to modal...");
        [_connectViewController setDevices:_devices];
    }

    [self updateNavigationWithPeripheralStatus:_ble.isConnected];
}

- (void)connectToDeviceAtIndex:(NSInteger)index {
    if (_ble.isConnected) {
        [[_ble CM] cancelPeripheralConnection:[_ble activePeripheral]];
    }

    [_ble connectPeripheral:_devices[index]];
}

#pragma mark - Handle Bluetooth Data
- (void)sendPeripheralRequest:(NSString *)request {
    if (request.length > 16) {
        request = [request substringToIndex:16];
    }
    [_ble write:[request dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark - Handle Navigation Updates

- (void)updateNavigationWithPeripheralStatus:(BOOL)status {
    if (status) {
        self.navigationItem.rightBarButtonItem =
            [[UIBarButtonItem alloc] initWithTitle:@"Sync"
                                             style:UIBarButtonItemStylePlain
                                            target:self
                                            action:@selector(syncPeripheral)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
            initWithTitle:@"Connect"
                    style:UIBarButtonItemStylePlain
                   target:self
                   action:@selector(connectPeripheral)];
    }

    [self.navigationItem.rightBarButtonItem
        setTintColor:[BXStyling lightColor]];
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
