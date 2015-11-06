//
//  BXStyling.h
//  Boxy
//
//  Created by Christian Le on 11/5/15.
//  Copyright © 2015 christianle. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface BXStyling : NSObject

+ (UIColor *)colorFromHexString:(NSString *)hexString;

+ (UIColor *)darkColor;
+ (UIColor *)lightColor;

+ (UIColor *)primaryColor;
+ (UIColor *)accentColor;

@end