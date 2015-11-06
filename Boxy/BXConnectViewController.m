//
//  BXConnectViewController.m
//  Boxy
//
//  Created by Christian Le on 11/5/15.
//  Copyright © 2015 christianle. All rights reserved.
//

#import "BXConnectViewController.h"
#import "BXDashboardViewController.h"
#import "BXStyling.h"
#import "BLE.h"

@interface BXConnectViewController ()<BLEDelegate, UITableViewDataSource,
                                      UITableViewDelegate,
                                      UINavigationControllerDelegate>

@property (strong, nonatomic) BLE *ble;
@property (strong, nonatomic)
    BXDashboardViewController *dashboardViewController;
@property (strong, nonatomic) UITableView *availableDevicesTableView;
@property (strong, nonatomic) NSMutableArray *devices;
@property (strong, nonatomic) NSString *lastUUID;
@property (nonatomic) BOOL isFindingLast;

@end

NSString *const UUIDPrefKey = @"UUIDPrefKey";
static NSString *BXAvailablePeripheralCellIdentifier =
    @"BXAvailablePeripheralCellIdentifier";

@implementation BXConnectViewController

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"Available Connections";
        self.view.backgroundColor = [BXStyling lightColor];

        _ble = [[BLE alloc] init];

        _availableDevicesTableView = [[UITableView alloc] init];
        _devices = [NSMutableArray new];
        _isFindingLast = NO;

        [self.view addSubview:_availableDevicesTableView];
        [self _installConstraints];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [_ble controlSetup];
    _ble.delegate = self;

    _lastUUID =
        [[NSUserDefaults standardUserDefaults] objectForKey:UUIDPrefKey];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scanForDevices];
}

- (void)_installConstraints {
    NSDictionary *views =
        NSDictionaryOfVariableBindings(_availableDevicesTableView);
    _availableDevicesTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint
                                  constraintsWithVisualFormat:
                                      @"V:|-_availableDevicesTableView-|"
                                                      options:0
                                                      metrics:nil
                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint
                                  constraintsWithVisualFormat:
                                      @"H:|-_availableDevicesTableView-|"
                                                      options:0
                                                      metrics:nil
                                                        views:views]];
}

#pragma Scan for Devices

- (void)scanForDevices {
    if (_ble.activePeripheral) {
        if (_ble.activePeripheral.state == CBPeripheralStateConnected) {
            [[_ble CM] cancelPeripheralConnection:[_ble activePeripheral]];
            return;
        }
    }

    if (_ble.peripherals) {
        _ble.peripherals = nil;
    }

    [NSTimer scheduledTimerWithTimeInterval:(float)3.0
                                     target:self
                                   selector:@selector(connectionTimer:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)connectionTimer:(NSTimer *)timer {
    if (_ble.peripherals.count > 0) {
        if (_isFindingLast) {
            for (int i = 0; i < _ble.peripherals.count; i++) {
                CBPeripheral *peripheral = [_ble.peripherals objectAtIndex:i];
                NSString *peripheralUUID =
                    [self getUUIDStringForPeripheral:peripheral];
                if (!peripheralUUID ||
                    [peripheralUUID isKindOfClass:[NSNull class]]) {
                    if ([_lastUUID isEqualToString:peripheralUUID]) {
                        [_ble connectPeripheral:peripheral];
                    }
                }
            }
        } else {
            [_devices removeAllObjects];

            for (int i = 0; i < _ble.peripherals.count; i++) {
                CBPeripheral *peripheral = [_ble.peripherals objectAtIndex:i];
                NSString *peripheralUUID =
                    [self getUUIDStringForPeripheral:peripheral];
                if (!peripheralUUID ||
                    [peripheralUUID isKindOfClass:[NSNull class]]) {
                    [_devices addObject:peripheral];
                }
            }
        }
    }

    [_availableDevicesTableView reloadData];
}

#pragma UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return _devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    CBPeripheral *peripheral;

    cell = [tableView
        dequeueReusableCellWithIdentifier:BXAvailablePeripheralCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]
              initWithStyle:UITableViewCellStyleDefault
            reuseIdentifier:BXAvailablePeripheralCellIdentifier];
    }

    peripheral = _devices[indexPath.row];

    [cell.textLabel setText:peripheral.name];
    return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (_ble.isConnected) {
        [[_ble CM] cancelPeripheralConnection:[_ble activePeripheral]];
    }
    [_ble connectPeripheral:_devices[indexPath.row]];
}

#pragma BLE Delegate

- (void)bleDidConnect {
    _lastUUID = [self getUUIDStringForPeripheral:_ble.activePeripheral];
    [[NSUserDefaults standardUserDefaults] setObject:_lastUUID
                                              forKey:UUIDPrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    _dashboardViewController = [[BXDashboardViewController alloc] init];
    _dashboardViewController.ble = self.ble;

    [self.navigationController pushViewController:_dashboardViewController
                                         animated:YES];
}

- (void)bleDidDisconnect {
    [self.navigationController popToRootViewControllerAnimated:true];
}

- (void)bleDidReceiveData:(unsigned char *)data length:(int)length {
    if (_dashboardViewController ||
        ![_dashboardViewController isKindOfClass:[NSNull class]]) {
        [_dashboardViewController handleReceivedData:data length:length];
    }
}

- (void)bleDidUpdateRSSI:(NSNumber *)rssi {
}

- (NSString *)getUUIDStringForPeripheral:(CBPeripheral *)peripheral {
    return peripheral.identifier.UUIDString;
}

@end
