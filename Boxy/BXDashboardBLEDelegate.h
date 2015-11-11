//
//  BXDashboardBLEDelegate.h
//  Boxy
//
//  Created by Christian Le on 11/10/15.
//  Copyright © 2015 christianle. All rights reserved.
//

@import Foundation;

@protocol BXDashboardBLEDelegate<NSObject>

- (void)sendPeripheralRequest:(NSString *)request;

@end
