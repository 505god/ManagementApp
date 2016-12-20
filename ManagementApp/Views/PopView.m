//
//  PopView.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/13.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "PopView.h"

static PopView *instancePop;

@implementation PopView

- (instancetype)initWithImageName:(NSString*)imageName message:(NSString *)string
{
    self = [super init];
    if (self) {
        self.hidden = NO;
        self.alpha = 1.0f;
        self.windowLevel = UIWindowLevelStatusBar + 1.0f;
        
        self.backgroundColor = [UIColor colorWithRed:0x17/255.0f green:0x17/255.0 blue:0x17/255.0 alpha:0.9];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 4;
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:14];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.text = string;
        [label sizeToFit];
        [self addSubview:label];
        
        self.width = label.width + 20;
        self.height = label.height+ 20;
        self.left = ([UIScreen mainScreen].bounds.size.width - self.width)/2;
        self.top = ([UIScreen mainScreen].bounds.size.height - self.height)/2;
        
        label.centerX = self.width/2;
        label.top = 10;
        SafeRelease(label);
    }
    return self;
}

+ (void)showWithImageName:(NSString*)imageName message:(NSString *)string;
{
    instancePop = [[PopView alloc] initWithImageName:imageName message:string];
    instancePop.alpha = 0;
    [UIView animateWithDuration:.25 animations:^{
        instancePop.alpha = 1;
    }];
    [instancePop performSelector:@selector(animationHide) withObject:nil afterDelay:2];
}

- (void)animationHide {
    [UIView animateWithDuration:.3 animations:^{
        instancePop.alpha = 0;
    } completion:^(BOOL finished) {
        instancePop = nil;
    }];
}

+(void)hiddenImage:(void (^)(BOOL finish))compleBlock {
    [UIView animateWithDuration:.25 animations:^{
        instancePop.alpha = 0;
    } completion:^(BOOL finished) {
        instancePop = nil;
        compleBlock(YES);
    }];
}

@end
