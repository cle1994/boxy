//
//  BXStyling.m
//  Boxy
//
//  Created by Christian Le on 11/5/15.
//  Copyright © 2015 christianle. All rights reserved.
//

#import "BXStyling.h"

@implementation BXStyling

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];

    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0
                           green:((rgbValue & 0xFF00) >> 8)/255.0
                            blue:(rgbValue & 0xFF)/255.0
                           alpha:1.0];
}

+ (UIColor *)darkColor {
    return [self colorFromHexString:@"#556270"];
}

+ (UIColor *)mediumColor {
    return [self colorFromHexString:@"#AAAAAA"];
}

+ (UIColor *)lightColor {
    return [self colorFromHexString:@"#F3F3F3"];
}

+ (UIColor *)primaryColor {
    return [self colorFromHexString:@"#4ECDC4"];
}

+ (UIColor *)secondaryColor {
    return [self colorFromHexString:@"#C7F464"];
}

+ (UIColor *)accentColor {
    return [self colorFromHexString:@"#FF6B6B"];
}

+ (UIColor *)dangerColor {
    return [self colorFromHexString:@"#C44D58"];
}

@end
