//
//  TabbarView.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "TabbarView.h"

@interface TabbarView ()

///作为背景
@property (nonatomic, strong) UIToolbar *toolbar;

@end

@implementation TabbarView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        
        [self setClipsToBounds:YES];
        if (![self toolbar]) {
            [self setToolbar:[[UIToolbar alloc] initWithFrame:[self bounds]]];
            
            [self.toolbar setBarTintColor:[UIColor colorWithWhite:0.9 alpha:1.f]];
            [self.layer insertSublayer:[self.toolbar layer] atIndex:0];
        }

        
        CGFloat count = 4;
        CGFloat space = (frame.size.width-20*2-TabbarHeight*count)/(count-1);
        
        self.item0 = [[TabBarItem alloc]initWithFrame:(CGRect){20,0,TabbarHeight,TabbarHeight} normal:@"navicon_stock" active:@"navicon_stock_fo" title:SetTitle(@"navicon_stock")];
        self.item0.tag = 0;
        [self.item0 addTarget:self action:@selector(itemSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.item0];
        
        self.item1 = [[TabBarItem alloc]initWithFrame:(CGRect){self.item0.right+space,0,TabbarHeight,TabbarHeight} normal:@"navicon_client" active:@"navicon_client_fo" title:SetTitle(@"navicon_client")];
        self.item1.tag = 1;
        [self.item1 addTarget:self action:@selector(itemSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.item1];
        
        self.item2 = [[TabBarItem alloc]initWithFrame:(CGRect){self.item1.right+space,0,TabbarHeight,TabbarHeight} normal:@"navicon_order" active:@"navicon_order_fo" title:SetTitle(@"navicon_order")];
        self.item2.tag = 2;
        [self.item2 addTarget:self action:@selector(itemSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.item2];
        
        self.item3 = [[TabBarItem alloc]initWithFrame:(CGRect){self.item2.right+space,0,TabbarHeight,TabbarHeight} normal:@"navicon_options" active:@"navicon_options_fo" title:SetTitle(@"navicon_options")];
        self.item3.tag = 3;
        [self.item3 addTarget:self action:@selector(itemSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.item3];
    }
    return self;
}


-(void)defaultSelected{
    [self unSelectedAllItems];
}

-(void)unSelectedAllItems{
    self.item0.isSelected = NO;
    self.item1.isSelected = NO;
    self.item2.isSelected = NO;
    self.item3.isSelected = NO;
}

-(void)itemSelected:(id)sender {
    [self unSelectedAllItems];
    
    TabBarItem *item = (TabBarItem *)sender;
    item.isSelected = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabBar:selectedItem:)]) {
        [self.delegate tabBar:self selectedItem:item.tag];
    }
}

-(void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    
    [self defaultSelected];
    
    switch (currentPage) {
        case 0:
            self.item0.isSelected = YES;
            break;
        case 1:
            self.item1.isSelected = YES;
            break;
        case 2:
            self.item2.isSelected = YES;
            break;
        case 3:
            self.item3.isSelected = YES;
            break;
            
        default:
            break;
    }
}
@end
