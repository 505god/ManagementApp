//
//  CALayer+color.m
//  ManagementApp
//
//  Created by 邱成西 on 15/11/13.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "CALayer+color.h"


@implementation CALayer (color)

@dynamic borderUIColor;

-(CGColorRef)borderColor {
    return self.borderUIColor.CGColor;
}
@end
