//
//  BXSyncViewController.h
//  Boxy
//
//  Created by Christian Le on 11/10/15.
//  Copyright © 2015 christianle. All rights reserved.
//

@import UIKit;

#import "BXPageViewChildProtocol.h"
#import "BXDashboardBLEDelegate.h"

@interface BXSyncViewController : UIViewController<BXPageViewChildProtocol>

@property (assign) id<BXDashboardBLEDelegate> delegate;
@property (nonatomic) int pageIndex;

- (void)updateData:(NSString *)data;

@end
