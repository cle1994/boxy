//
//  BXDashboardViewController.m
//  Boxy
//
//  Created by Christian Le on 11/5/15.
//  Copyright © 2015 christianle. All rights reserved.
//

#import "BXDashboardViewController.h"
#import "BXStyling.h"

@interface BXDashboardViewController ()

@end

@implementation BXDashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)handleReceivedData:(unsigned char *)data length:(int)length {
    int i = 0;
    while (i < length) {
        NSLog(@"%c", data[i]);
    }
}

@end
