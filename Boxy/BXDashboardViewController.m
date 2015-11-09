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

@property (strong, nonatomic) UILabel *helloCountView;

@end

@implementation BXDashboardViewController

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"Dashboard";
        self.navigationController.navigationBar.tintColor = [BXStyling lightColor];
        self.navigationController.navigationBar.barTintColor = [BXStyling lightColor];
        self.view.backgroundColor = [BXStyling lightColor];

        _helloCountView = [[UILabel alloc] init];
        _helloCountView.textAlignment = NSTextAlignmentCenter;
        _helloCountView.font = [UIFont systemFontOfSize:25];
        _helloCountView.backgroundColor = [BXStyling lightColor];
        _helloCountView.textColor = [BXStyling darkColor];
        [self.view addSubview:_helloCountView];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    CGSize viewSize = self.view.bounds.size;
    [_helloCountView
        setFrame:CGRectMake(0, 0, viewSize.width, viewSize.height)];
}

- (void)handleReceivedData:(unsigned char *)data length:(int)length {
    NSData *d = [NSData dataWithBytes:data length:length];
    NSString *s =
        [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    NSLog(@"%@", s);

    [_helloCountView setText:s];
}

@end
