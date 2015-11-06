//
//  BXConnectViewController.m
//  Boxy
//
//  Created by Christian Le on 11/5/15.
//  Copyright © 2015 christianle. All rights reserved.
//

#import "BXConnectViewController.h"
#import "BXStyling.h"

@implementation BXConnectViewController

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"Available Connections";
        self.view.backgroundColor = [BXStyling lightColor];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

@end
