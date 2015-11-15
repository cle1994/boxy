//
//  BXDashboardViewController.h
//  Boxy
//
//  Created by Christian Le on 11/5/15.
//  Copyright © 2015 christianle. All rights reserved.
//

@import UIKit;

#import "BXDashboardBLEDelegate.h"
#import "BXConnectViewController.h"

@interface BXDashboardViewController : UIViewController <BXDashboardBLEDelegate, BXConnectViewControllerDelegate>

@end
