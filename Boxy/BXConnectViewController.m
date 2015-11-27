//
//  BXConnectViewController.m
//  Boxy
//
//  Created by Christian Le on 11/5/15.
//  Copyright © 2015 christianle. All rights reserved.
//

#import "BXConnectViewController.h"
#import "BXSyncingPopupViewController.h"
#import "BXStyling.h"
#import "BLE.h"

@interface BXConnectViewController ()<UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) BXSyncingPopupViewController *popupViewController;
@property (strong, nonatomic) UITableView *availableDevicesTableView;
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UISwitch *useLastConnectedSwitch;
@property (strong, nonatomic) UILabel *useLastConnectedLabel;
@property (nonatomic) BOOL isFindingLast;

@end

static NSString *BXAvailablePeripheralCellIdentifier = @"BXAvailablePeripheralCellIdentifier";

@implementation BXConnectViewController
@synthesize devices = _devices;

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"Available Peripherals";
        self.view.backgroundColor = [BXStyling lightColor];

        self.navigationItem.leftBarButtonItem =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModal)];

        [self.navigationItem.leftBarButtonItem setTintColor:[BXStyling lightColor]];

        self.navigationItem.rightBarButtonItem =
            [[UIBarButtonItem alloc] initWithTitle:@"Scan" style:UIBarButtonItemStylePlain target:self action:@selector(scanForDevices)];

        [self.navigationItem.rightBarButtonItem setTintColor:[BXStyling lightColor]];

        _availableDevicesTableView = [[UITableView alloc] init];
        _headerView = [[UIView alloc] init];
        _useLastConnectedLabel = [[UILabel alloc] init];
        _useLastConnectedSwitch = [[UISwitch alloc] init];

        _availableDevicesTableView.delegate = self;
        _availableDevicesTableView.dataSource = self;

        [_useLastConnectedSwitch setTintColor:[BXStyling secondaryColor]];
        [_useLastConnectedSwitch setOnTintColor:[BXStyling primaryColor]];
        [_useLastConnectedSwitch addTarget:self action:@selector(toggleUseLastConnection:) forControlEvents:UIControlEventValueChanged];
        [_useLastConnectedSwitch setOn:NO];

        _useLastConnectedLabel.text = @"Use Last Connected Peripheral";
        _useLastConnectedLabel.textColor = [BXStyling darkColor];

        _isFindingLast = NO;

        [_headerView addSubview:_useLastConnectedLabel];
        [_headerView addSubview:_useLastConnectedSwitch];
        [_headerView setBackgroundColor:[BXStyling lightColor]];
        [_headerView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60)];

        _availableDevicesTableView.tableHeaderView = _headerView;

        [self.view addSubview:_availableDevicesTableView];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self _installConstraints];
    CGSize viewSize = self.view.bounds.size;

    [_availableDevicesTableView setFrame:CGRectMake(0, 0, viewSize.width, viewSize.height)];

    [_popupViewController.view setFrame:CGRectMake(0, 0, viewSize.width, viewSize.height)];
}

- (void)stopSyncingAnimation {
    if (_popupViewController) {
        [_popupViewController closePopup];
    }
}

#pragma mark - Setters/Getters

- (void)setDevices:(NSMutableArray *)devices {
    if (devices != nil) {
        _devices = devices;
        [_availableDevicesTableView reloadData];
    } else {
        NSLog(@"Modal received nil devices");
    }
}

#pragma mark - Selectors

- (void)dismissModal {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Device Scanning

- (void)scanForDevices {
    [self.delegate scanForDevicesAndConnectLast:_isFindingLast];
}

- (void)toggleUseLastConnection:(UISwitch *)paramSender {
    if ([paramSender isOn]) {
        _isFindingLast = YES;
        NSLog(@"The switch is turned on.");
    } else {
        _isFindingLast = NO;
        NSLog(@"The switch is turned off.");
    }
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    CBPeripheral *peripheral;

    cell = [tableView dequeueReusableCellWithIdentifier:BXAvailablePeripheralCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BXAvailablePeripheralCellIdentifier];
    }

    peripheral = self.devices[indexPath.row];

    [cell.textLabel setText:peripheral.name];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [self.delegate connectToDeviceAtIndex:indexPath.row];

    _popupViewController = [[BXSyncingPopupViewController alloc] init];
    [self addChildViewController:_popupViewController];
    [self.view addSubview:_popupViewController.view];

    [_popupViewController didMoveToParentViewController:self];
    [_popupViewController shouldAnimate:YES];
}

#pragma mark - Constraints

- (void)_installConstraints {
    _headerView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);

    _useLastConnectedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _useLastConnectedSwitch.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *views = NSDictionaryOfVariableBindings(_useLastConnectedLabel, _useLastConnectedSwitch);

    NSDictionary *metrics = @{ @"margin": @(30) };

    [_headerView
        addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[_useLastConnectedLabel]-" @"margin-[_useLastConnectedSwitch]-margin-|"
                                                               options:0
                                                               metrics:metrics
                                                                 views:views]];

    [_headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_useLastConnectedLabel]-|" options:0 metrics:metrics views:views]];

    [_headerView addConstraint:[NSLayoutConstraint constraintWithItem:_useLastConnectedSwitch
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_headerView
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1
                                                             constant:0]];

    [_headerView addConstraint:[NSLayoutConstraint constraintWithItem:_useLastConnectedSwitch
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1
                                                             constant:51]];
}

@end
