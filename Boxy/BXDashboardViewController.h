//
//  BXDashboardViewController.h
//  Boxy
//
//  Created by Christian Le on 11/5/15.
//  Copyright © 2015 christianle. All rights reserved.
//

@import UIKit;

#import "BLE.h"
#import "BXDashboardBLEDelegate.h"

@interface BXDashboardViewController : UIViewController <BXDashboardBLEDelegate>

@property (strong, nonatomic) BLE *ble;

- (void)handleReceivedData:(unsigned char *)data length:(int)length;

@end
