//
//  FilterView.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/24.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "FilterView.h"

#define APP_SCREEN_BOUNDS   [[UIScreen mainScreen] bounds]
#define APP_SCREEN_HEIGHT   (APP_SCREEN_BOUNDS.size.height)
#define APP_SCREEN_WIDTH    (APP_SCREEN_BOUNDS.size.width)
#define Content_with 304

#define MaxRowsPerSection 10000

@interface FilterView ()
{
    NSMutableDictionary *_selectedIndexDic;
}
@property (nonatomic,strong) UIView *maskView;
@property (nonatomic,strong) UIView *contentView;

@property (nonatomic,strong) UIButton *filterBtn;
@end

@implementation FilterView

- (instancetype)initWithFrame:(CGRect)frame dataSource:(id<FilterViewDataSourece>)dataSource{
    if (self = [super initWithFrame:frame]) {
        _dataSource = dataSource;
        
        _maskView = [[UIView alloc] initWithFrame:self.bounds];
        _maskView.backgroundColor = COLOR(115, 115, 115, 0.3);
        [self addSubview:_maskView];
        
        self.filterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.filterBtn.frame = (CGRect){(self.width-Content_with)/2,10,Content_with,30};
        [self.filterBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.filterBtn.userInteractionEnabled = NO;
        [self.filterBtn setBackgroundImage:[Utility getImgWithImageName:@"sort_bg2@2x"] forState:UIControlStateNormal];
        [self addSubview:self.filterBtn];
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTapped:)];
        [_maskView addGestureRecognizer:tap];
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bounds)-Content_with)/2, 50, Content_with, 0)];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 4;
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];
        
        [self reloadData];
        
        self.hidden = YES;
    }
    return self;
}

- (void)reloadData {
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger sectionNum =  1;
    CGFloat contentViewHeight = 0;
    
    _selectedIndexDic = [NSMutableDictionary dictionaryWithCapacity:sectionNum];
    for (NSInteger i = 0; i < sectionNum; i++) {
        NSInteger choiceNum = [self.dataSource filterView:self numberOfRowsInSection:i];
        if (choiceNum > 0)
        {
            NSInteger btnNumPerLine = 1;
            NSInteger lineNum = choiceNum%btnNumPerLine == 0 ? choiceNum/btnNumPerLine : choiceNum/btnNumPerLine + 1;
            
            NSInteger selectedNum = [self.dataSource respondsToSelector:@selector(filterView:selectedIndexInSection:)] ? [self.dataSource filterView:self selectedIndexInSection:i] : 0;
            
            CGFloat btnWidth = Content_with;
            
            CGFloat xOrig = 0.0;
            for (NSInteger j = 0; j < lineNum; j++)
            {
                for (NSInteger m = 0; m < btnNumPerLine; m++)
                {
                    NSInteger tempNum = j*btnNumPerLine + m;
                    
                    if (tempNum >= choiceNum) {
                        break;
                    }
                    NSString *btnTitle = [self.dataSource filterView:self titleForBtnAtIndexPath:[NSIndexPath indexPathForRow:tempNum inSection:i]];
                    
                    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(xOrig, contentViewHeight, btnWidth, 40)];
                    if (tempNum!=(choiceNum-1)) {
                        [btn setBackgroundImage:[Utility getImgWithImageName:@"item_detail_tab_bg@2x"] forState:UIControlStateNormal];
                        [btn setBackgroundImage:[Utility getImgWithImageName:@"item_detail_tab_bg@2x"] forState:UIControlStateHighlighted];
                    }
                    
                    [btn setTitle:btnTitle forState:UIControlStateNormal];
                    btn.titleLabel.font = [UIFont systemFontOfSize:18.0];
                    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    btn.tag = MaxRowsPerSection*i + tempNum + 1;
                    [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    [self.contentView addSubview:btn];
                    
                    if (tempNum == selectedNum) {
                        [btn setTitleColor:kThemeColor forState:UIControlStateNormal];
                        
                        [self.filterBtn setTitle:btnTitle forState:UIControlStateNormal];
                        _selectedIndexDic[[NSString stringWithFormat:@"%ld",(long)i]] = [NSString stringWithFormat:@"%ld",(long)selectedNum];
                    }
                    
                    xOrig = xOrig + btnWidth +10;
                }
                xOrig = 0;
                contentViewHeight += 40;
            }
        }
    }
    
    self.contentView.height = contentViewHeight;
}

- (void)buttonClicked:(id)sender {
    UIButton *btn = (UIButton*)sender;
    NSInteger section = btn.tag/MaxRowsPerSection;
    NSInteger row = btn.tag%MaxRowsPerSection - 1;
    
    NSInteger lastSelectedIndex = [_selectedIndexDic[[NSString stringWithFormat:@"%ld",(long)section]] integerValue];
    if (lastSelectedIndex == row) {
        if ([self.delegate respondsToSelector:@selector(filterView:didSelectRowAtIndexPath:)]) {
            [self.delegate filterView:self didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        }
        return;
    }
    
    [btn setTitleColor:COLOR(12, 96, 254, 1) forState:UIControlStateNormal];
    
    _selectedIndexDic[[NSString stringWithFormat:@"%ld",(long)section]] = [NSString stringWithFormat:@"%ld",(long)row];
    
    btn = (UIButton*)[self.contentView viewWithTag:section*MaxRowsPerSection+lastSelectedIndex+1];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if ([self.delegate respondsToSelector:@selector(filterView:didSelectRowAtIndexPath:)]) {
        [self.delegate filterView:self didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    }
}

#pragma mark --

- (void)bgTapped:(id)sender {
    [self hide];
}

#pragma mark --

- (void)show {
    CGFloat height = self.contentView.height;
    self.contentView.height = 0;
    self.maskView.alpha = 0.0;
    self.hidden = NO;
    [UIView animateWithDuration:0.25f animations:^{
        self.maskView.alpha = 1.0;
        self.contentView.height = height;
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.25f animations:^{
        self.maskView.alpha = 0.0;
        self.contentView.height = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        
        if ([self.delegate respondsToSelector:@selector(filterHide)]) {
            [self.delegate filterHide];
        }
    }];
}

- (BOOL)isHiddenState{
    return self.hidden;
}


@end
