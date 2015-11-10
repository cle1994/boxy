//
//  BXGraphViewController.h
//  Boxy
//
//  Created by Christian Le on 11/10/15.
//  Copyright © 2015 christianle. All rights reserved.
//

@import UIKit;

#import "BXPageViewChildProtocol.h"

@interface BXGraphViewController : UIViewController<BXPageViewChildProtocol>

@property (nonatomic) int pageIndex;

- (void)setDataCount:(int)count range:(double)range;

@end
