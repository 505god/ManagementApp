//
//  SearchTableIndex.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/13.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchTableIndexDelegate;

@interface SearchTableIndex : UIView

@property (nonatomic, strong) NSArray *indexes;
@property (nonatomic, assign) id <SearchTableIndexDelegate>tableViewIndexDelegate;

@end

@protocol SearchTableIndexDelegate <NSObject>

/**
 *  触摸到索引时触发
 *
 *  @param tableViewIndex 触发didSelectSectionAtIndex对象
 *  @param index          索引下标
 *  @param title          索引文字
 */
- (void)tableViewIndex:(SearchTableIndex *)tableViewIndex didSelectSectionAtIndex:(NSInteger)index withTitle:(NSString *)title;

/**
 *  开始触摸索引
 *
 *  @param tableViewIndex 触发tableViewIndexTouchesBegan对象
 */
- (void)tableViewIndexTouchesBegan:(SearchTableIndex *)tableViewIndex;
/**
 *  触摸索引结束
 *
 *  @param tableViewIndex
 */
- (void)tableViewIndexTouchesEnd:(SearchTableIndex *)tableViewIndex;

/**
 *  TableView中右边右边索引title
 *
 *  @param tableViewIndex 触发tableViewIndexTitle对象
 *
 *  @return 索引title数组
 */
- (NSArray *)tableViewIndexTitle:(SearchTableIndex *)tableViewIndex;

@end