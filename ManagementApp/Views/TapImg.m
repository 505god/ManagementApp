//
//  TapImg.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/29.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "TapImg.h"

@implementation TapImg

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Tapped:)];
        [self addGestureRecognizer:tap];
        SafeRelease(tap);
        
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void) Tapped:(UIGestureRecognizer *) gesture
{
    if ([self.delegate respondsToSelector:@selector(tappedWithObject:)])
    {
        [self.delegate tappedWithObject:self];
    }
}


@end
