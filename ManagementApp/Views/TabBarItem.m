//
//  TabBarItem.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "TabBarItem.h"

@implementation TabBarItem

- (id)initWithFrame:(CGRect)frame normal:(NSString *)normal active:(NSString *)active title:(NSString *)title{
    self = [super initWithFrame:frame];
    if (self) {
        self.logoImg = [[UIImageView alloc]initWithFrame:(CGRect){(frame.size.width-30)/2,3,30,30}];
        self.logoImg.image = [UIImage imageNamed:normal];
        self.logoImg.highlightedImage = [UIImage imageNamed:active];
        [self addSubview:self.logoImg];
        
        self.titleLab = [[UILabel alloc]initWithFrame:(CGRect){0,frame.size.height-12,frame.size.width,12}];
        self.titleLab.textAlignment = NSTextAlignmentCenter;
        self.titleLab.textColor = [UIColor lightGrayColor];
        self.titleLab.font = [UIFont systemFontOfSize:10];
        self.titleLab.text = title;
        [self addSubview:self.titleLab];
        
        self.notificationHub = [[RKNotificationHub alloc]initWithView:self];
        [self.notificationHub setCount:-1];
        [self.notificationHub setCircleAtFrame:(CGRect){self.logoImg.right-5,self.logoImg.top-5,10,10}];

    }
    return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self animate];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}

- (void)animate {
    CAKeyframeAnimation *k = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    k.values = @[@(0.9),@(1.0),@(1.1)];
    k.keyTimes = @[@(0.5),@(0.7),@(0.9),@(1.0)];
    k.calculationMode = kCAAnimationLinear;
    
    [self.logoImg.layer addAnimation:k forKey:@"SHOW"];
}



#pragma mark property
-(void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    [self.logoImg setHighlighted:isSelected];
    
    self.titleLab.textColor = isSelected?[UIColor blackColor]:[UIColor lightGrayColor];
}


@end
