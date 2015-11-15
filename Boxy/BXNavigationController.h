//
//  BXNavigationController.h
//  Boxy
//
//  Created by Christian Le on 11/5/15.
//  Copyright © 2015 christianle. All rights reserved.
//

@import UIKit;

@interface BXNavigationController : UINavigationController

- (void)setBarWithColor:(UIColor *)color;
- (void)setTitleAttributesWithAttributes:(NSDictionary *)attributes;
- (void)setBarStyleWithStyle:(UIBarStyle)style;

@end
