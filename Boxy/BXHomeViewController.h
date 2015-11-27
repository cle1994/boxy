//
//  BXHomeViewController.h
//  Boxy
//
//  Created by Christian Le on 11/25/15.
//  Copyright © 2015 christianle. All rights reserved.
//

@import UIKit;

#import "BXPageViewChildProtocol.h"
#import "BXDashboardDelegate.h"

@protocol BXHomeViewControllerDelegate<NSObject>

- (void)sendToTwitter:(NSString *)message;
- (void)sendWorkout:(NSArray *)workout;
- (void)layoutSubviews;

@end

@interface BXHomeViewController : UIViewController<BXPageViewChildProtocol>

@property (strong, nonatomic) id<BXDashboardDelegate> delegate;
@property (nonatomic) int pageIndex;

@end
