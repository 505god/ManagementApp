//
//  FilterView.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/24.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilterView;

@protocol FilterViewDataSourece <NSObject>

- (NSInteger)filterView:(FilterView *)filterView numberOfRowsInSection:(NSInteger)section;

- (NSString *)filterView:(FilterView *)filterView titleForBtnAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)filterView:(FilterView *)filterView selectedIndexInSection:(NSInteger)section;
@end

@protocol FilterViewDelegate <NSObject>

- (void)filterView:(FilterView *)filterView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;


- (void)filterHide;

@end

@interface FilterView : UIView

@property (nonatomic,weak) id<FilterViewDataSourece>dataSource;
@property (nonatomic,weak) id<FilterViewDelegate>delegate;

- (instancetype)initWithFrame:(CGRect)frame dataSource:(id<FilterViewDataSourece>)dataSource;

- (void)reloadData;
- (void)show;
- (void)hide;
- (BOOL)isHiddenState;

@end
