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
#import "BXHomeViewController.h"
#import "BXSettingsViewController.h"
#import "BXSyncingPopupViewController.h"
#import "BXStyling.h"
#import "BXBluetoothManager.h"

@interface BXDashboardViewController ()<BXBluetoothManagerDelegate>

// BLE
@property (strong, nonatomic) BXBluetoothManager *BLEManager;
@property (strong, nonatomic) BXConnectViewController *connectViewController;
@property (strong, nonatomic) NSMutableArray *devices;
@property (strong, nonatomic) NSString *lastUUID;
@property (nonatomic) BOOL isFindingLast;
@property (strong, nonatomic) BXSyncingPopupViewController *popupViewController;

// Segmented Pages
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) BXHomeViewController *homeViewController;
@property (strong, nonatomic) BXGraphViewController *graphViewController;
@property (strong, nonatomic) UISegmentedControl *pageViewSegmentedSwitcher;
@property (strong, nonatomic) NSMutableArray *pageViewChildren;

// Settings
@property (strong, nonatomic) BXSettingsViewController *settingsViewController;

// BLE Data
@property (strong, nonatomic) NSArray *message;
@property (nonatomic) int messageIndex;
@property (nonatomic) BOOL messageComplete;

// BLE Receive
@property (strong, nonatomic) NSMutableArray *receivedWorkout;
@property (nonatomic) int receivedCount;
@property (nonatomic) BOOL receivedComplete;

@end

NSString *const UUIDPrefKey = @"UUIDPrefKey";

@implementation BXDashboardViewController

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"Dashboard";
        self.navigationController.navigationBar.tintColor = [BXStyling lightColor];
        self.navigationController.navigationBar.barTintColor = [BXStyling lightColor];
        self.view.backgroundColor = [BXStyling lightColor];

        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SettingIcon"]
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(launchSettings)];

        _devices = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (_BLEManager == nil) {
        _BLEManager = [[BXBluetoothManager alloc] init];
        _BLEManager.uartDelegate = self;
    }

    _lastUUID = [[NSUserDefaults standardUserDefaults] objectForKey:UUIDPrefKey];

    [self scanForDevicesAndConnectLast:YES];
    [self setupPageView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self _installConstraints];

    CGSize viewSize = self.view.bounds.size;
    [_popupViewController.view setFrame:CGRectMake(0, 0, viewSize.width, viewSize.height)];
}

- (void)setupPageView {
    NSArray *pageTitles = [NSArray arrayWithObjects:@"Home", @"Graph", nil];
    _pageViewSegmentedSwitcher = [[UISegmentedControl alloc] initWithItems:pageTitles];
    [_pageViewSegmentedSwitcher addTarget:self action:@selector(switchPages:) forControlEvents:UIControlEventValueChanged];
    _pageViewSegmentedSwitcher.selectedSegmentIndex = 0;
    _pageViewSegmentedSwitcher.tintColor = [BXStyling darkColor];

    _homeViewController = [[BXHomeViewController alloc] init];
    _homeViewController.delegate = self;

    _graphViewController = [[BXGraphViewController alloc] init];

    _pageViewChildren = [[NSMutableArray alloc] init];
    [_pageViewChildren addObject:_homeViewController];
    [_pageViewChildren addObject:_graphViewController];
    for (int i = 0; i < _pageViewChildren.count; i++) {
        [(UIViewController<BXPageViewChildProtocol> *)_pageViewChildren[i] setPageIndex:i];
    }

    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];

    [_pageViewController.view setFrame:[self.view bounds]];
    [_pageViewController setViewControllers:[NSArray arrayWithObject:_pageViewChildren[0]]
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

    BXNavigationController *connectNavigationController = [[BXNavigationController alloc] initWithRootViewController:_connectViewController];

    [connectNavigationController setBarWithColor:[BXStyling headerBackgroundColor]];
    [connectNavigationController setBarStyleWithStyle:UIBarStyleDefault];
    [connectNavigationController setTitleAttributesWithAttributes:@{NSForegroundColorAttributeName: [BXStyling lightColor]}];

    [self.navigationController presentViewController:connectNavigationController
                                            animated:YES
                                          completion:^(void) {
                                            [self scanForDevicesAndConnectLast:NO];
                                          }];
}

- (void)syncPeripheral {
    [self sendPeripheralRequest:@"D"];
}

- (void)launchSettings {
    _settingsViewController = [[BXSettingsViewController alloc] init];

    BXNavigationController *settingsNavigationController = [[BXNavigationController alloc] initWithRootViewController:_settingsViewController];

    [settingsNavigationController setBarWithColor:[BXStyling headerBackgroundColor]];
    [settingsNavigationController setBarStyleWithStyle:UIBarStyleDefault];
    [settingsNavigationController setTitleAttributesWithAttributes:@{NSForegroundColorAttributeName: [BXStyling lightColor]}];

    [self.navigationController presentViewController:settingsNavigationController
                                            animated:YES
                                          completion:^(void) {
                                            [self scanForDevicesAndConnectLast:NO];
                                          }];
}

#pragma mark - BluetoothManagerDelegate

- (void)didDeviceConnectWithPeripheral:(NSString *)peripheralName {
    _lastUUID = [self getUUIDStringForPeripheral:_BLEManager.bluetoothPeripheral];
    [[NSUserDefaults standardUserDefaults] setObject:_lastUUID forKey:UUIDPrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self updateNavigationWithPeripheralStatus:YES];

    if ([self presentedViewController] != nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didDeviceDisconnect {
    [self updateNavigationWithPeripheralStatus:NO];
}

- (void)didDiscoverUARTService:(CBService *)uartService {
}

- (void)didDiscoverRXCharacteristic:(CBCharacteristic *)rxCharacteristic {
}

- (void)didDiscoverTXCharacteristic:(CBCharacteristic *)txCharacteristic {
}

- (void)didReceiveTXNotification:(NSData *)data {
    NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", s);
    if ([[s substringToIndex:1] isEqualToString:@"A"] && ![[s substringToIndex:2] isEqualToString:@"AT"]) {
        int ack = [[s substringFromIndex:1] intValue];
        _messageIndex = ack + 1;

        if (ack == [_message count] - 1) {
            _messageComplete = YES;
            _messageIndex = 0;
            [_BLEManager writeRXValue:@"F"];
        } else {
            [_BLEManager writeRXValue:_message[_messageIndex]];
        }
    } else if ([[s substringToIndex:1] isEqualToString:@"S"] || [[s substringToIndex:1] isEqualToString:@"C"]) {
        if ([[s substringToIndex:1] isEqualToString:@"S"]) {
            _receivedWorkout = [[NSMutableArray alloc] init];
            _receivedCount = [[s substringWithRange:NSMakeRange(1, 1)] intValue];
            _receivedComplete = NO;
        } else if ([[s substringToIndex:1] isEqualToString:@"C"]) {
            if ([[s substringWithRange:NSMakeRange(1, 1)] intValue] == _receivedCount) {
                _receivedComplete = YES;
            }
        }

        s = [s substringFromIndex:3];
        NSString *tmp = @"";
        NSString *title = @"";
        int weight = 0;
        int sets = 0;
        int reps = 0;
        int counter = 0;
        for (int i = 0; i < [s length]; i++) {
            NSString *ch = [s substringWithRange:NSMakeRange(i, 1)];
            if ([ch isEqualToString:@"-"]) {
                if (counter == 0) {
                    if ([tmp isEqualToString:@"S"]) {
                        title = @"Squats";
                    } else if ([tmp isEqualToString:@"O"]) {
                        title = @"OH Press";
                    } else if ([tmp isEqualToString:@"D"]) {
                        title = @"Deadlift";
                    } else if ([tmp isEqualToString:@"B"]) {
                        title = @"Benchpress";
                    } else if ([tmp isEqualToString:@"R"]) {
                        title = @"Row";
                    }
                } else if (counter == 1) {
                    weight = [tmp intValue];
                } else if (counter == 2) {
                    sets = [tmp intValue];
                } else if (counter == 3) {
                    reps = [tmp intValue];
                }
                tmp = @"";
                counter++;

                if (counter == 4) {
                    counter = 0;
                    [_receivedWorkout addObject:@{ @"title": title, @"weight": @(weight), @"sets": @(sets), @"reps": @(reps) }];
                    if (_receivedComplete) {
                        _homeViewController.previousWorkout = _receivedWorkout;
                        [_homeViewController updateWorkoutsOnView];
                    }
                }
            } else {
                tmp = [tmp stringByAppendingString:ch];
            }
        }
    }

    [_graphViewController setDataCount:20 range:100.0];
}

- (void)didError:(NSString *)errorMessage {
    NSLog(@"%@", errorMessage);
}

- (void)didFindNewPeripherals:(NSMutableArray *)newPeripherals {
    _devices = newPeripherals;
}

- (NSString *)getUUIDStringForPeripheral:(CBPeripheral *)peripheral {
    return peripheral.identifier.UUIDString;
}

#pragma mark - Device Scanning

- (void)scanForDevicesAndConnectLast:(BOOL)last {
    NSLog(@"Scanning for devices...");

    _isFindingLast = last;

    if ([_BLEManager scanForPeripherals:YES]) {
        [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    }
}

- (void)connectionTimer:(NSTimer *)timer {
    NSLog(@"Checking if devices found...");
    [_BLEManager scanForPeripherals:NO];

    if ([self presentedViewController] != nil) {
        NSLog(@"Sending devices to modal...");
        NSLog(@"%@", _devices);
        [_connectViewController setDevices:_devices];
    }

    [self updateNavigationWithPeripheralStatus:[_BLEManager isConnectedToPeripheral]];
}

- (void)connectToDeviceAtIndex:(NSInteger)index {
    [_BLEManager connectDevice:_devices[index]];
}

#pragma mark - Dashboard Delegate

- (void)sendPeripheralRequest:(NSString *)request {
    if (request.length > 20) {
        request = [request substringToIndex:20];
    }
    [_BLEManager writeRXValue:request];
}

- (void)sendWorkout:(NSArray *)workout {
    _message = workout;
    _messageIndex = 0;
    _messageComplete = false;
    [_BLEManager writeRXValue:_message[0]];
}

- (void)postToTwitter:(NSString *)message {
    NSLog(@"%@", _settingsViewController.twitter);
    if (_settingsViewController.twitter) {
        [_settingsViewController.twitter postStatusUpdate:message
            inReplyToStatusID:nil
            latitude:nil
            longitude:nil
            placeID:nil
            displayCoordinates:nil
            trimUser:nil
            successBlock:^(NSDictionary *status) {
              NSLog(@"Posting Success");
            }
            errorBlock:^(NSError *error) {
              NSLog(@"Posting Error");
            }];
    }
}

#pragma mark - Handle Navigation Updates

- (void)updateNavigationWithPeripheralStatus:(BOOL)status {
    if (status) {
        self.navigationItem.rightBarButtonItem =
            [[UIBarButtonItem alloc] initWithTitle:@"Sync" style:UIBarButtonItemStylePlain target:self action:@selector(syncPeripheral)];
    } else {
        self.navigationItem.rightBarButtonItem =
            [[UIBarButtonItem alloc] initWithTitle:@"Connect" style:UIBarButtonItemStylePlain target:self action:@selector(connectPeripheral)];
    }

    [self.navigationItem.rightBarButtonItem setTintColor:[BXStyling lightColor]];
}

#pragma mark - Handle Page Switching

- (void)switchPages:(UISegmentedControl *)segmentedControl {
    NSInteger index = segmentedControl.selectedSegmentIndex;
    UIViewController *vc = _pageViewChildren[index];

    [_pageViewController setViewControllers:[NSArray arrayWithObject:vc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

#pragma mark - Constraints

- (void)_installConstraints {
    self.view.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);

    [_pageViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_pageViewSegmentedSwitcher setTranslatesAutoresizingMaskIntoConstraints:NO];

    UIView *pageView = _pageViewController.view;
    NSDictionary *views = NSDictionaryOfVariableBindings(pageView, _pageViewSegmentedSwitcher);

    NSDictionary *metrics = @{ @"margin": @(20) };

    [self.view
        addConstraints:
            [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[pageView]-[_pageViewSegmentedSwitcher]-margin-|" options:0 metrics:metrics views:views]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[pageView]-|" options:0 metrics:metrics views:views]];

    [self.view addConstraints:
                   [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[_pageViewSegmentedSwitcher]-margin-|" options:0 metrics:metrics views:views]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_pageViewSegmentedSwitcher
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:0
                                                           constant:35.0]];
}

@end
