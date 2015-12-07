//
//  BluetoothManager.m
//  Boxy
//
//  Created by Christian Le on 12/6/15.
//  Copyright © 2015 christianle. All rights reserved.
//

#import "BXBluetoothManager.h"

static NSString *const uartServiceUUIDString = @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
static NSString *const uartTXCharacteristicUUIDString = @"6E400003-B5A3-F393-E0A9-E50E24DCCA9E";
static NSString *const uartRXCharacteristicUUIDString = @"6E400002-B5A3-F393-E0A9-E50E24DCCA9E";

@interface BXBluetoothManager ()

@property (strong, nonatomic) NSMutableArray *peripherals;

@end

@implementation BXBluetoothManager
@synthesize uartDelegate = _uartDelegate;
@synthesize centralManager = _centralManager;

- (id)init {
    if (self = [super init]) {
        self.UART_Service_UUID = [CBUUID UUIDWithString:uartServiceUUIDString];
        self.UART_TX_Characteristic_UUID = [CBUUID UUIDWithString:uartTXCharacteristicUUIDString];
        self.UART_RX_Characteristic_UUID = [CBUUID UUIDWithString:uartRXCharacteristicUUIDString];

        _peripherals = [[NSMutableArray alloc] init];

        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        [_centralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES }];
    }
    return self;
}

- (void)setUartDelegate:(id<BXBluetoothManagerDelegate>)uartDelegate {
    _uartDelegate = uartDelegate;
}

- (void)setBluetoothCentralManager:(CBCentralManager *)centralManager {
    if (centralManager) {
        _centralManager = centralManager;
        _centralManager.delegate = self;
    }
}

- (BOOL)isConnectedToPeripheral {
    if (self.bluetoothPeripheral) {
        return YES;
    }
    return NO;
}

- (void)connectDevice:(CBPeripheral *)peripheral {
    if (peripheral) {
        self.bluetoothPeripheral = peripheral;
        self.bluetoothPeripheral.delegate = self;
        [_centralManager connectPeripheral:peripheral options:nil];
    }
}

- (void)disconnectDevice {
    if (self.bluetoothPeripheral) {
        [_centralManager cancelPeripheralConnection:self.bluetoothPeripheral];
        self.bluetoothPeripheral = nil;
    }
}

- (void)writeRXValue:(NSString *)value {
    if (self.uartRXCharacteristic) {
        // Use CBCharacteristicWriteWithoutResponse if nothing is written to Arduino
        CBCharacteristicWriteType writeType = CBCharacteristicWriteWithResponse;
        [self.bluetoothPeripheral writeValue:[value dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.uartRXCharacteristic type:writeType];

        NSLog(@"writing command: %@ to UART peripheral: %@", value, self.bluetoothPeripheral.name);
    }
}

- (int)scanForPeripherals:(BOOL)enable {
    if (_centralManager.state != CBCentralManagerStatePoweredOn) {
        return -1;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      if (enable) {
          NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
          [_centralManager scanForPeripheralsWithServices:nil options:options];
      } else {
          [_centralManager stopScan];
      }
    });

    return 1;
}

- (NSMutableArray *)getFoundPeripherals {
    return _peripherals;
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"centralManagerDidUpdateState");
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary<NSString *, id> *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    dispatch_async(dispatch_get_main_queue(), ^{
      // Add the sensor to the list and reload deta set
      if (![_peripherals containsObject:peripheral] && (peripheral.name != nil)) {
          [_peripherals addObject:peripheral];
          NSLog(@"Found %@", peripheral.name);
          [_uartDelegate didFindNewPeripherals:_peripherals];
      }
    });
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Did connect to peripheral %@", peripheral.name);
    [_uartDelegate didDeviceConnectWithPeripheral:peripheral.name];
    [self.bluetoothPeripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Did disconnect from peripheral %@", peripheral.name);
    [_uartDelegate didDeviceDisconnect];
    self.bluetoothPeripheral = nil;
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Did fail to connect to peripheral %@", peripheral.name);
    [_uartDelegate didDeviceDisconnect];
    self.bluetoothPeripheral = nil;
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!error) {
        NSLog(@"%lu services discovered", (unsigned long)[peripheral.services count]);
        for (CBService *uartService in peripheral.services) {
            NSLog(@"Service discovered: %@", uartService.UUID);
            if ([uartService.UUID isEqual:self.UART_Service_UUID]) {
                NSLog(@"UART service found");
                [_uartDelegate didDiscoverUARTService:uartService];
                [self.bluetoothPeripheral discoverCharacteristics:nil forService:uartService];
            }
        }
    } else {
        NSLog(@"Error discovering services on device: %@", self.bluetoothPeripheral.name);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (!error) {
        if ([service.UUID isEqual:self.UART_Service_UUID]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID isEqual:self.UART_TX_Characteristic_UUID]) {
                    NSLog(@"UART TX characteritsic found: %@", characteristic);
                    [_uartDelegate didDiscoverTXCharacteristic:characteristic];
                    [self.bluetoothPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                } else if ([characteristic.UUID isEqual:self.UART_RX_Characteristic_UUID]) {
                    NSLog(@"UART RX characteristic found: %@", characteristic);
                    [_uartDelegate didDiscoverRXCharacteristic:characteristic];
                    self.uartRXCharacteristic = characteristic;
                }
            }
        }
    } else {
        NSLog(@"Error discovering characteristic on device: %@", self.bluetoothPeripheral.name);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        if (characteristic.value.length != 0) {
            [_uartDelegate didReceiveTXNotification:characteristic.value];
        }
    } else {
        NSLog(@"Error updating UART value");
    }
}

@end
