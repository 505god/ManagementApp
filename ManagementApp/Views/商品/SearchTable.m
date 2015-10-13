//
//  SearchTable.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/13.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "SearchTable.h"
#import "SearchTableIndex.h"

@interface SearchTable ()<SearchTableIndexDelegate>

@property (nonatomic, strong) UILabel *flotageLabel;
@property (nonatomic, strong) SearchTableIndex *tableViewIndex;

@end

@implementation SearchTable

-(void)dealloc {
    SafeRelease(_tableView.delegate);
    SafeRelease(_tableView.dataSource);
    SafeRelease(_tableView);
    SafeRelease(_searchBar.delegate);
    SafeRelease(_searchBar);
    SafeRelease(_delegate);
    SafeRelease(_flotageLabel);
    SafeRelease(_tableViewIndex.tableViewIndexDelegate);
    SafeRelease(_tableViewIndex);
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:self.tableView];
        
        self.tableViewIndex = [[SearchTableIndex alloc] initWithFrame:(CGRect){self.width-20,0,20,self.height}];
        self.tableViewIndex.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.tableViewIndex];
        
        self.flotageLabel = [[UILabel alloc] initWithFrame:(CGRect){(self.width - 64 ) / 2,(self.height-64-NavgationHeight)/2,64,64}];
        self.flotageLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin  |UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.flotageLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"flotageBackgroud"]];
        self.flotageLabel.hidden = YES;
        self.flotageLabel.font = [UIFont systemFontOfSize:20];
        self.flotageLabel.textAlignment = NSTextAlignmentCenter;
        self.flotageLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.flotageLabel];
    }
    return self;
}

-(UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.placeholder = SetTitle(@"Search");
        [_searchBar sizeToFit];
        
        if ([_searchBar respondsToSelector : @selector (barTintColor)]){
            if (Platform>=7.1){
                [[[[_searchBar.subviews objectAtIndex:0] subviews] objectAtIndex:0] removeFromSuperview];
                [_searchBar setBackgroundColor:COLOR(230, 230, 230, 1)];
            }else{//7.0
                [_searchBar setBarTintColor :[UIColor clearColor]];
                [_searchBar setBackgroundColor :COLOR(230, 230, 230, 1)];
            }
        }else {//7.0以下
            [[_searchBar.subviews objectAtIndex:0] removeFromSuperview];
            
            [_searchBar setBackgroundColor:COLOR(230, 230, 230, 1)];
        }
    }
    return _searchBar;
}

-(void)setHeaderAnimated:(BOOL)animated {
    if (animated) {
        self.tableView.tableHeaderView = self.searchBar;
    }else {
        self.tableView.tableHeaderView = nil;
    }
}

- (void)setDelegate:(id<SearchTableDelegate>)delegate {
    _delegate = delegate;
    self.tableView.delegate = delegate;
    self.tableView.dataSource = delegate;
    self.searchBar.delegate = delegate;
    self.tableViewIndex.indexes = [self.delegate sectionIndexTitlesForWQCustomerTable:self];
    if (self.tableViewIndex.indexes.count>0) {
        [self.tableViewIndex setHeight:YES];
    }else {
        [self.tableViewIndex setHeight:NO];
        self.tableViewIndex.frame = (CGRect){self.width-20,(self.height-NavgationHeight-self.tableViewIndex.indexes.count * 16)/2,20,self.tableViewIndex.indexes.count * 16};
        self.tableViewIndex.autoresizingMask = UIViewAutoresizingNone;
        self.tableViewIndex.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        
        self.tableViewIndex.tableViewIndexDelegate = self;
    }
    
}

- (void)reloadData
{
    [self.tableView reloadData];
    
    self.tableViewIndex.indexes = [self.delegate sectionIndexTitlesForWQCustomerTable:self];
    self.tableViewIndex.frame = (CGRect){self.width-20,(self.height-NavgationHeight-self.tableViewIndex.indexes.count * 16)/2,20,self.tableViewIndex.indexes.count * 16};
    self.tableViewIndex.autoresizingMask = UIViewAutoresizingNone;
    self.tableViewIndex.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    self.tableViewIndex.tableViewIndexDelegate = self;
}

#pragma mark -
- (void)tableViewIndex:(SearchTableIndex *)tableViewIndex didSelectSectionAtIndex:(NSInteger)index withTitle:(NSString *)title {
    if ([self.tableView numberOfSections] > index && index > -1){
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:NO];
        self.flotageLabel.text = @"";
        self.flotageLabel.text = title;
    }
}

- (void)tableViewIndexTouchesBegan:(SearchTableIndex *)tableViewIndex {
    self.flotageLabel.hidden = NO;
}

- (void)tableViewIndexTouchesEnd:(SearchTableIndex *)tableViewIndex {
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    [self.flotageLabel.layer addAnimation:animation forKey:nil];
    
    self.flotageLabel.hidden = YES;
}

- (NSArray *)tableViewIndexTitle:(SearchTableIndex *)tableViewIndex {
    return [self.delegate sectionIndexTitlesForWQCustomerTable:self];
}


@end
