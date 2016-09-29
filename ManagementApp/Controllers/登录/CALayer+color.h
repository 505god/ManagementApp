//
//  CALayer+color.h
//  ManagementApp
//
//  Created by 邱成西 on 15/11/13.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (color)

@property (nonatomic, strong) UIColor *borderUIColor;

@property (nonatomic, assign) CGColorRef borderColor;

@end
