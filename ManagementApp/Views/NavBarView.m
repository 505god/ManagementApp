//
//  NavBarView.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/10.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "NavBarView.h"

@interface NavBarView ()

@end

@implementation NavBarView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        UIImage *normal = [Utility getImgWithImageName:@"nav_bg@2x"];
        normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        [self setBackgroundColor:[UIColor colorWithPatternImage:normal]];
        
        self.rightEnable = YES;
    }
    return self;
}

#pragma mark - UI

-(void)removeViewWithTag:(NSUInteger)tag {
    UIView *view = [self viewWithTag:tag];
    [view removeFromSuperview];
    view = nil;
}

///设置左侧按钮、标题
-(void)setLeftWithImage:(NSString *)imageString title:(NSString *)title {
    if (imageString) {
        [self removeViewWithTag:10000];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[Utility getImgWithImageName:[NSString stringWithFormat:@"%@@2x",imageString]] forState:UIControlStateNormal];
        [btn setImage:[Utility getImgWithImageName:[NSString stringWithFormat:@"%@_highlighted@2x",imageString]] forState:UIControlStateHighlighted];
        btn.tag = 10000;
        [btn addTarget:self action:@selector(tapLeft:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = (CGRect){5,20+(NavgationHeight-40)/2,40,40};
        [self addSubview:btn];
        
        if (title) {
            [self removeViewWithTag:10001];
            UILabel *lab = [[UILabel alloc]initWithFrame:CGRectZero];
            lab.font = [UIFont systemFontOfSize:16];
            lab.text = title;
            lab.textColor = [UIColor whiteColor];
            [lab sizeToFit];
            lab.tag = 10001;
            lab.frame = (CGRect){btn.right,20+(NavgationHeight-lab.height)/2,lab.width,lab.height};
            [self addSubview:lab];
            
            lab = nil;
        }
        btn = nil;
    }else {
        [self removeViewWithTag:10001];
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectZero];
        lab.font = [UIFont systemFontOfSize:16];
        lab.text = title;
        lab.textColor = [UIColor whiteColor];
        [lab sizeToFit];
        lab.tag = 10001;
        lab.frame = (CGRect){10,20+(NavgationHeight-lab.height)/2,lab.width,lab.height};
        [self addSubview:lab];
        
        lab = nil;
    }
}

///设置右侧按钮
-(void)setRightWithArray:(NSArray *)array type:(NSInteger)type{
    for (int i=0; i<array.count; i++) {
        [self removeViewWithTag:30000+i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if (type==0) {
            [btn setImage:[Utility getImgWithImageName:[NSString stringWithFormat:@"%@@2x",array[i]]] forState:UIControlStateNormal];
            [btn setImage:[Utility getImgWithImageName:[NSString stringWithFormat:@"%@_highlighted@2x",array[i]]] forState:UIControlStateHighlighted];
        }else {
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitleColor:COLOR(212, 212, 212, 1) forState:UIControlStateHighlighted];
            [btn setTitle:array[i] forState:UIControlStateNormal];
        }
        
        btn.tag = i+30000;
        btn.enabled = self.rightEnable;
        
        [btn addTarget:self action:@selector(tapRight:) forControlEvents:UIControlEventTouchUpInside];
        
        btn.frame = (CGRect){self.width-5-50*(i+1),20+(NavgationHeight-40)/2,50,40};
        [self addSubview:btn];
        btn = nil;
    }
}

-(void)setRightEnable:(BOOL)rightEnable {
    _rightEnable = rightEnable;
    
    UIButton *btn = (UIButton *)[self viewWithTag:30000];
    btn.enabled = rightEnable;
}

///设置标题
-(void)setTitle:(NSString *)title image:(NSString *)imageString {
    //标题
    [self removeViewWithTag:20001];
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectZero];
    lab.text = title;
    lab.textColor = [UIColor whiteColor];
    lab.tag = 20001;
    lab.font = [UIFont systemFontOfSize:18];
    [lab sizeToFit];
    
    //包含图片
    if (imageString != nil) {
        [self removeViewWithTag:20000];
        UIImageView *img = [[UIImageView alloc]initWithFrame:(CGRect){0,0,40,40}];
        img.image = [Utility getImgWithImageName:[NSString stringWithFormat:@"%@@2x",imageString]];
        img.frame = (CGRect){(self.width-lab.width-45)/2,20+(NavgationHeight-40)/2,40,40};
        img.tag = 20000;
        [self addSubview:img];
        
        lab.frame = (CGRect){img.right+5,20+(NavgationHeight-lab.height)/2,lab.width,lab.height};
        [self addSubview:lab];
        lab = nil;
        img = nil;
    }else {
        lab.frame = (CGRect){(self.width-lab.width)/2,20+(NavgationHeight-lab.height)/2,lab.width,lab.height};
        [self addSubview:lab];
        lab = nil;
    }
}

#pragma mark - action

-(void)tapLeft:(id)sender {
    if (self.navDelegate && [self.navDelegate respondsToSelector:@selector(leftBtnClickByNavBarView:)]) {
        [self.navDelegate leftBtnClickByNavBarView:self];
    }
}

-(void)tapRight:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    if (self.navDelegate && [self.navDelegate respondsToSelector:@selector(rightBtnClickByNavBarView:tag:)]) {
        [self.navDelegate rightBtnClickByNavBarView:self tag:btn.tag-30000];
    }
}
@end
