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
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UISwitch *useLastConnectedSwitch;
@property (strong, nonatomic) UILabel *useLastConnectedLabel;
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

        self.navigationItem.rightBarButtonItem =
            [[UIBarButtonItem alloc] initWithTitle:@"Scan"
                                             style:UIBarButtonItemStylePlain
                                            target:self
                                            action:@selector(scanForDevices)];

        [self.navigationItem.rightBarButtonItem
            setTintColor:[BXStyling lightColor]];

        _ble = [[BLE alloc] init];

        _availableDevicesTableView = [[UITableView alloc] init];
        _headerView = [[UIView alloc] init];
        _useLastConnectedLabel = [[UILabel alloc] init];
        _useLastConnectedSwitch = [[UISwitch alloc] init];
        _devices = [NSMutableArray new];
        _isFindingLast = NO;

        CGFloat headerHeight = 60;
        CGFloat headerInset = 25;
        CGSize buttonSize = CGSizeMake(51, 31);
        CGSize viewSize = self.view.bounds.size;

        [_useLastConnectedSwitch
            setFrame:CGRectMake(viewSize.width - headerInset - buttonSize.width,
                                (headerHeight - buttonSize.height) / 2,
                                buttonSize.width, buttonSize.height)];
        [_useLastConnectedSwitch setTintColor:[BXStyling secondaryColor]];
        [_useLastConnectedSwitch setOnTintColor:[BXStyling primaryColor]];
        [_useLastConnectedSwitch addTarget:self
                                    action:@selector(toggleUseLastConnection:)
                          forControlEvents:UIControlEventValueChanged];
        
        [_useLastConnectedLabel
            setFrame:CGRectMake(headerInset, 0,
                                viewSize.width - (headerInset * 2) -
                                    buttonSize.width,
                                headerHeight)];
        _useLastConnectedLabel.text = @"Use Last Connected Device";
        _useLastConnectedLabel.textColor = [BXStyling darkColor];

        [_headerView addSubview:_useLastConnectedLabel];
        [_headerView addSubview:_useLastConnectedSwitch];
        [_headerView setBackgroundColor:[BXStyling lightColor]];
        [_headerView setFrame:CGRectMake(0, 0, self.view.bounds.size.width,
                                         headerHeight)];
        _availableDevicesTableView.tableHeaderView = _headerView;

        [self.view addSubview:_availableDevicesTableView];
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

- (void)viewDidLayoutSubviews {
    CGSize viewSize = self.view.bounds.size;
    //    CGFloat footerHeight = viewSize.height * (1/5);

    //    [_headerView setFrame:CGRectMake(0, 0, viewSize.width, footerHeight)];
    [_availableDevicesTableView
        setFrame:CGRectMake(0, 0, viewSize.width, viewSize.height)];
}

//- (void)_installConstraints {
//    NSDictionary *views =
//        NSDictionaryOfVariableBindings(_availableDevicesTableView);
//    _availableDevicesTableView.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.view addConstraints:[NSLayoutConstraint
//                                  constraintsWithVisualFormat:
//                                      @"V:|-_availableDevicesTableView-|"
//                                                      options:0
//                                                      metrics:nil
//                                                        views:views]];
//    [self.view addConstraints:[NSLayoutConstraint
//                                  constraintsWithVisualFormat:
//                                      @"H:|-_availableDevicesTableView-|"
//                                                      options:0
//                                                      metrics:nil
//                                                        views:views]];
//}

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

- (void)toggleUseLastConnection:(UISwitch *)paramSender {
    
    if ([paramSender isOn]){
        _isFindingLast = YES;
        NSLog(@"The switch is turned on.");
    } else {
        _isFindingLast = NO;
        NSLog(@"The switch is turned off.");
    }
    
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
