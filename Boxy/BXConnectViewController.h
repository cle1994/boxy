//
//  BXConnectViewController.h
//  Boxy
//
//  Created by Christian Le on 11/5/15.
//  Copyright © 2015 christianle. All rights reserved.
//

@import UIKit;

@protocol BXConnectViewControllerDelegate <NSObject>

- (void)scanForDevicesAndConnectLast:(BOOL)last;
- (void)connectToDeviceAtIndex:(NSInteger)index;

@end

@interface BXConnectViewController : UIViewController

@property (strong, nonatomic) id<BXConnectViewControllerDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *devices;

- (void)stopSyncingAnimation;

@end
