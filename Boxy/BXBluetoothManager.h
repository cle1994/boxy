//
//  BluetoothManager.h
//  Boxy
//
//  Created by Christian Le on 12/6/15.
//  Copyright © 2015 christianle. All rights reserved.
//

@import Foundation;
@import CoreBluetooth;

@protocol BXBluetoothManagerDelegate

- (void)didDeviceConnectWithPeripheral:(NSString *)peripheralName;
- (void)didDeviceDisconnect;
- (void)didDiscoverUARTService:(CBService *)uartService;
- (void)didDiscoverRXCharacteristic:(CBCharacteristic *)rxCharacteristic;
- (void)didDiscoverTXCharacteristic:(CBCharacteristic *)txCharacteristic;
- (void)didReceiveTXNotification:(NSData *)data;
- (void)didError:(NSString *)errorMessage;
- (void)didFindNewPeripherals:(NSMutableArray *)newPeripherals;

@end

@interface BXBluetoothManager : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

- (void)disconnectDevice;
- (void)writeRXValue:(NSString *)value;
- (void)connectDevice:(CBPeripheral *)peripheral;
- (BOOL)isConnectedToPeripheral;
- (int)scanForPeripherals:(BOOL)enable;
- (NSMutableArray *)getFoundPeripherals;

@property (nonatomic, assign) id<BXBluetoothManagerDelegate> uartDelegate;
@property (strong, nonatomic, setter=setBluetoothCentralManager:) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *bluetoothPeripheral;
@property (strong, nonatomic) CBUUID *UART_Service_UUID;
@property (strong, nonatomic) CBUUID *UART_RX_Characteristic_UUID;
@property (strong, nonatomic) CBUUID *UART_TX_Characteristic_UUID;
@property (strong, nonatomic) CBCharacteristic *uartRXCharacteristic;
@property (strong, nonatomic) CBCharacteristic *uartTXCharacteristic;

@end
