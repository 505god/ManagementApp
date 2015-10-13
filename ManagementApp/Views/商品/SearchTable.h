//
//  SearchTable.h
//  ManagementApp
//
//  Created by 邱成西 on 15/10/13.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchTableDelegate;

@interface SearchTable : UIView

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, assign) id<SearchTableDelegate> delegate;

- (void)reloadData;

-(void)setHeaderAnimated:(BOOL)animated;

@end

@protocol SearchTableDelegate <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

- (NSArray *)sectionIndexTitlesForWQCustomerTable:(SearchTable *)tableView;

@end