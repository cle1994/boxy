//
//  BXSyncViewController.m
//  Boxy
//
//  Created by Christian Le on 11/10/15.
//  Copyright © 2015 christianle. All rights reserved.
//

#import "BXSyncViewController.h"
#import "BXStyling.h"

@interface BXSyncViewController ()

@property (strong, nonatomic) UILabel *helloCountView;

@end

@implementation BXSyncViewController

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"Sync";
        self.navigationController.navigationBar.tintColor =
            [BXStyling lightColor];
        self.navigationController.navigationBar.barTintColor =
            [BXStyling lightColor];
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
    [super viewDidLayoutSubviews];
    CGSize viewSize = self.view.bounds.size;
    [_helloCountView
        setFrame:CGRectMake(0, 0, viewSize.width, viewSize.height)];
}

- (void)updateData:(NSString *)data {
    [_helloCountView setText:data];
}

@end
