//
//  ClassifyVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/14.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ClassifyVC.h"

/*
 检索
 */
#import "SearchTable.h"
#import "ChineseInclude.h"
#import "PinYinForObjc.h"
#import "WQIndexedCollationWithSearch.h"

#import "ClassifyCell.h"

#import "BlockAlertView.h"
#import "BlockTextPromptAlertView.h"

@interface ClassifyVC ()<SearchTableDelegate,RMSwipeTableViewCellDelegate>

///通讯录列表
@property (nonatomic, strong) SearchTable *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ClassifyVC

-(void)dealloc {
    SafeRelease(_tableView);
    SafeRelease(_dataArray);
    SafeRelease(_selectedSortModel);
    SafeRelease(_hasSelectedClassify);
    SafeRelease(_completedBlock);
}

#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
    
    //集成刷新控件
    [self addHeader];
    
    if (self.selectedSortModel) {
        [self.hasSelectedClassify addObject:self.selectedSortModel];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView.tableView headerBeginRefreshing];
    
//    ///第一次从服务器获取，后续从单例里面读取
//    if ([DataShare sharedService].classifyArray.count>0) {
//        __weak __typeof(self)weakSelf = self;
//        [[DataShare sharedService] sortClassify:[DataShare sharedService].classifyArray CompleteBlock:^(NSArray *array) {
//            weakSelf.dataArray = [NSMutableArray arrayWithArray:array];
//            [weakSelf.tableView setHeaderAnimated:YES];
//            [weakSelf.tableView reloadData];
//        }];
//    }else {
//        //自动刷新(一进入程序就下拉刷新)
//        [self.tableView.tableView headerBeginRefreshing];
//    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    if (!self.view.window){
        SafeRelease(_tableView);
        SafeRelease(_dataArray);
        SafeRelease(_selectedSortModel);
        SafeRelease(_hasSelectedClassify);
        SafeRelease(_completedBlock);
        self.view=nil;
    }
}

#pragma mark - getter/setter

-(SearchTable *)tableView {
    if (!_tableView) {
        _tableView = [[SearchTable alloc] initWithFrame:(CGRect){0,self.navBarView.bottom,[UIScreen mainScreen].bounds.size.width,self.view.height-self.navBarView.height}];
        _tableView.delegate = self;
        _tableView.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [Utility setExtraCellLineHidden:_tableView.tableView];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

-(NSMutableArray *)hasSelectedClassify {
    if (!_hasSelectedClassify) {
        _hasSelectedClassify = [[NSMutableArray alloc]init];
    }
    return _hasSelectedClassify;
}

#pragma mark - UI

-(void)setNavBarView {
    [self.navBarView setTitle:SetTitle(@"classify") image:nil];
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.navBarView setRightWithArray:@[@"add"] type:0];
    [self.view addSubview:self.navBarView];
}

#pragma mark - private

- (void)addHeader {
    
    __weak __typeof(self)weakSelf = self;
    [self.tableView.tableView addHeaderWithCallback:^{
        
        [weakSelf getDataFromSever];
        
    } dateKey:@"ClassifyVC"];
}

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    if (self.isSelectedClassify) {
        if (self.completedBlock) {
            if (self.hasSelectedClassify.count>0) {
                self.completedBlock(self.hasSelectedClassify[0]);
            }else {
                self.completedBlock(nil);
            }
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    UITextField *textField;
    BlockTextPromptAlertView *alert = [BlockTextPromptAlertView promptWithTitle:SetTitle(@"addClassify") message:nil textField:&textField type:0 block:^(BlockTextPromptAlertView *alert){
        [alert.textField resignFirstResponder];
        return YES;
    }];
    
    [alert setCancelButtonWithTitle:SetTitle(@"alert_cancel") block:^{
        
    }];
    __weak __typeof(self)weakSelf = self;
    [alert setDestructiveButtonWithTitle:SetTitle(@"alert_confirm") block:^{
        
        [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
        
        //保存对象
        AVObject *post = [AVObject objectWithClassName:@"Sort"];
        post[@"sortName"] = textField.text;
        
        // 为颜色和卖家建立一对一关系
        [post setObject:[AVUser currentUser] forKey:@"user"];
        
        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                AVQuery *query = [AVQuery queryWithClassName:@"Sort"];
                //查询行为先尝试从网络加载，若加载失败，则从缓存加载结果
                query.cachePolicy = kAVCachePolicyNetworkElseCache;
                //设置缓存有效期
                query.maxCacheAge = 24*3600;// 一天的总秒数
                
                [query whereKey:@"user" equalTo:[AVUser currentUser]];
                
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    
                    [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                    
                    if (!error) {
                        [DataShare sharedService].classifyArray = nil;
                        for (int i=0; i<objects.count; i++) {
                            AVObject *object = objects[i];
                            
                            SortModel *model = [SortModel initWithObject:object];
                            [[DataShare sharedService].classifyArray addObject:model];
                        }
                        
                        [[DataShare sharedService] sortClassify:[DataShare sharedService].classifyArray CompleteBlock:^(NSArray *array) {
                            weakSelf.dataArray = [NSMutableArray arrayWithArray:array];
                            [weakSelf.tableView setHeaderAnimated:YES];
                            [weakSelf.tableView reloadData];
                        }];
                    }else {
                        [PopView showWithImageName:@"error" message:SetTitle(@"connect_error")];
                    }
                }];
            }else {
                [PopView showWithImageName:@"error" message:SetTitle(@"connect_error")];
            }
        }];
    }];
    [alert show];
}


#pragma mark - 获取分类列表

-(void)getDataFromSever {
    
    if ([DataShare sharedService].appDel.isReachable) {
        __weak __typeof(self)weakSelf = self;
        
        AVQuery *query = [AVQuery queryWithClassName:@"Sort"];
        //查询行为先尝试从网络加载，若加载失败，则从缓存加载结果
        query.cachePolicy = kAVCachePolicyNetworkElseCache;
        //设置缓存有效期
        query.maxCacheAge = 24*3600;// 一天的总秒数
        
        [query whereKey:@"user" equalTo:[AVUser currentUser]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [weakSelf.tableView.tableView headerEndRefreshing];
            if (!error) {
                [DataShare sharedService].classifyArray = nil;
                for (int i=0; i<objects.count; i++) {
                    AVObject *object = objects[i];
                    
                    SortModel *model = [SortModel initWithObject:object];
                    [[DataShare sharedService].classifyArray addObject:model];
                }
                
                [[DataShare sharedService] sortClassify:[DataShare sharedService].classifyArray CompleteBlock:^(NSArray *array) {
                    weakSelf.dataArray = [NSMutableArray arrayWithArray:array];
                    [weakSelf.tableView setHeaderAnimated:YES];
                    [weakSelf.tableView reloadData];
                }];
                
            } else {
                [PopView showWithImageName:@"error" message:SetTitle(@"connect_error")];
            }
        }];
    }else {
        [PopView showWithImageName:@"error" message:SetTitle(@"no_connect")];
    }
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (NSArray *)sectionIndexTitlesForWQCustomerTable:(SearchTable *)tableView {
    NSMutableArray * indexTitles = [NSMutableArray array];
    for (NSDictionary * sectionDictionary in self.dataArray) {
        [indexTitles addObject:sectionDictionary[@"indexTitle"]];
    }
    return indexTitles;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.width, 15)];
    customView.backgroundColor = COLOR(230, 230, 230, 1);
    
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:(CGRect){10, 0.0, self.tableView.width-20, 15}];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor lightGrayColor];
    headerLabel.font = [UIFont systemFontOfSize:13];
    headerLabel.text = self.dataArray[section][@"indexTitle"];
    
    [customView addSubview:headerLabel];
    SafeRelease(headerLabel);
    
    return customView;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *aDic = (NSDictionary *)self.dataArray[section];
    NSArray *array = (NSArray *)aDic[@"data"];
    return [array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"classify_cell";
    
    ClassifyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ClassifyCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                   reuseIdentifier:CellIdentifier];
    }
    
    cell.delegate = self;
    cell.revealDirection = RMSwipeTableViewCellRevealDirectionRight;
    [cell setSelectedType:0];
    [cell setIndexPath:indexPath];
    
    SortModel *sortModel = (SortModel *)self.dataArray[indexPath.section][@"data"][indexPath.row];
    sortModel.indexPath = indexPath;
    
    [cell setSortModel:sortModel];
    
    if (self.isSelectedClassify) {
        NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"sortId == %@", sortModel.sortId];
        NSMutableArray *filteredArray = [NSMutableArray arrayWithArray:[self.hasSelectedClassify filteredArrayUsingPredicate:predicateString]];
        if (filteredArray.count>0) {
            ///已经选择
            [cell setSelectedType:2];
            
            SortModel *sortModelTemp = filteredArray[0];
            sortModelTemp.indexPath = indexPath;
        }else {
            [cell setSelectedType:1];
        }
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ClassifyCell *cell = (ClassifyCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (self.isSelectedClassify) {
        
        SortModel *sortModel = (SortModel *)self.dataArray[indexPath.section][@"data"][indexPath.row];
        
        if (self.hasSelectedClassify.count>0) {
            SortModel *sortModelTemp = (SortModel *)self.hasSelectedClassify[0];
            
            if ([sortModel.sortId isEqualToString:sortModelTemp.sortId]) {
                ///已经选择,取消选择
                [cell setSelectedType:1];
                [self.hasSelectedClassify removeAllObjects];
            }else {
                //找到sortModelTemp的index
                ClassifyCell *cellTemp = (ClassifyCell *)[tableView cellForRowAtIndexPath:sortModelTemp.indexPath];
                [cellTemp setSelectedType:1];
                
                [self.hasSelectedClassify removeAllObjects];
                if (self.selectedSortModel && ([sortModel.sortId isEqualToString:self.selectedSortModel.sortId])){
                    [self.hasSelectedClassify addObject:self.selectedSortModel];
                }else {
                    [self.hasSelectedClassify addObject:sortModel];
                }
                ///选择
                [cell setSelectedType:2];
            }
        }else {
            ///选择
            [self.hasSelectedClassify addObject:sortModel];
            [cell setSelectedType:2];
        }
    }else {
        //do noting
    }
}

-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [self.tableView.searchBar resignFirstResponder];
}

#pragma mark - search代理
- (void)searchBarTextDidBeginEditing:(UISearchBar *)search {
    search.showsCancelButton = YES;
    for(id cc in [search subviews]) {
        if([cc isKindOfClass:[UIView class]]) {
            UIView *cc_view = (UIView *)cc;
            for (id vv in [cc_view subviews]){
                if([vv isKindOfClass:[UIButton class]]){
                    UIButton *btn = (UIButton *)vv;
                    [btn setTitle:SetTitle(@"cancel") forState:UIControlStateNormal];
                    [btn setTintColor:[UIColor lightGrayColor]];
                }
            }
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)search{
    search.showsCancelButton=NO;
    search.text=nil;
    [search resignFirstResponder];
    
    __weak __typeof(self)weakSelf = self;
    [[DataShare sharedService] sortClassify:[DataShare sharedService].classifyArray CompleteBlock:^(NSArray *array) {
        weakSelf.dataArray = [NSMutableArray arrayWithArray:array];
        [weakSelf.tableView setHeaderAnimated:YES];
        [weakSelf.tableView reloadData];
    }];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSMutableArray *searchResults = [NSMutableArray array];
    
    if (searchBar.text.length>0 && ![ChineseInclude isIncludeChineseInString:searchBar.text]) {//英文或者数字搜素
        
        [[DataShare sharedService].classifyArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SortModel *sortModel = (SortModel *)obj;
            
            if ([ChineseInclude isIncludeChineseInString:sortModel.sortName]) {//名称含有中文
                //转换为拼音
                NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:sortModel.sortName];
                NSRange titleResult=[tempPinYinStr rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0 && ![searchResults containsObject:sortModel]) {
                    [searchResults addObject:sortModel];
                }
                
                //转换为拼音首字母
                NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:sortModel.sortName];
                NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
                if (titleHeadResult.length>0 && ![searchResults containsObject:sortModel]) {
                    [searchResults addObject:sortModel];
                }
            }else {
                //昵称含有数字
                NSRange titleResult=[sortModel.sortName rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [searchResults addObject:sortModel];
                }
            }
        }];
        
    } else if (searchBar.text.length>0&&[ChineseInclude isIncludeChineseInString:searchBar.text]) {//中文搜索
        for (SortModel *sortModel in [DataShare sharedService].classifyArray) {
            NSRange titleResult=[sortModel.sortName rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
            if (titleResult.length>0) {
                [searchResults addObject:sortModel];
            }
        }
    }else if (searchBar.text.length == 0){
        [searchResults addObjectsFromArray:[DataShare sharedService].classifyArray];
    }
    
    
    __weak __typeof(self)weakSelf = self;
    [[DataShare sharedService] sortClassify:searchResults CompleteBlock:^(NSArray *array) {
        weakSelf.dataArray = [NSMutableArray arrayWithArray:array];
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - RMSwipeTableViewCellDelegate
//删除颜色
-(void)swipeTableViewCellWillResetState:(RMSwipeTableViewCell *)swipeTableViewCell fromPoint:(CGPoint)point animation:(RMSwipeTableViewCellAnimationType)animation velocity:(CGPoint)velocity {
    if (point.x < 0 && (0-point.x) >= swipeTableViewCell.contentView.height)  {
        NSIndexPath *indexPath = [self.tableView.tableView indexPathForCell:swipeTableViewCell];
        
        SortModel *sortModel = (SortModel *)self.dataArray[indexPath.section][@"data"][indexPath.row];
        if (sortModel.productCount>0) {
            [PopView showWithImageName:@"error" message:SetTitle(@"classifyDelete")];
        }else {
            swipeTableViewCell.shouldAnimateCellReset = YES;
            
            __weak __typeof(self)weakSelf = self;
            BlockAlertView *alert = [BlockAlertView alertWithTitle:SetTitle(@"ConfirmDelete") message:nil];
            [alert setCancelButtonWithTitle:SetTitle(@"alert_cancel") block:^{
                
            }];
            [alert setDestructiveButtonWithTitle:SetTitle(@"alert_confirm") block:^{
                
                [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                
                AVObject *post = [[AVQuery queryWithClassName:@"Sort"] getObjectWithId:sortModel.sortId];
                [post deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                    
                    if (!error) {
                        
                        //已选择
                        if ([sortModel.sortId isEqualToString:weakSelf.selectedSortModel.sortId]) {
                            weakSelf.selectedSortModel = nil;
                        }
                        if (weakSelf.hasSelectedClassify.count>0) {
                            SortModel *sortModelTemp = (SortModel *)weakSelf.hasSelectedClassify[0];
                            if ([sortModel.sortId isEqualToString:sortModelTemp.sortId]) {
                                [weakSelf.hasSelectedClassify removeAllObjects];
                            }
                        }
                        
                        
                        NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"sortId == %@", sortModel.sortId];
                        NSMutableArray *filteredArray = [NSMutableArray arrayWithArray:[[DataShare sharedService].classifyArray filteredArrayUsingPredicate:predicateString]];
                        
                        [[DataShare sharedService].classifyArray removeObjectsInArray:filteredArray];
                        
                        [UIView animateWithDuration:0.25
                                              delay:0
                                            options:UIViewAnimationOptionCurveLinear
                                         animations:^{
                                             swipeTableViewCell.contentView.frame = CGRectOffset(swipeTableViewCell.contentView.bounds, swipeTableViewCell.contentView.frame.size.width, 0);
                                         }
                                         completion:^(BOOL finished) {
                                             [[DataShare sharedService] sortClassify:[DataShare sharedService].classifyArray CompleteBlock:^(NSArray *array) {
                                                 weakSelf.dataArray = [NSMutableArray arrayWithArray:array];
                                                 [weakSelf.tableView setHeaderAnimated:YES];
                                                 [weakSelf.tableView reloadData];
                                             }];
                                             
                                             [swipeTableViewCell setHidden:YES];
                                         }
                         ];
                    }else {
                        [PopView showWithImageName:@"error" message:SetTitle(@"connect_error")];
                    }
                    
                }];
                
            }];
            [alert show];
        }
    }
}

//修改颜色
-(void)editDidLongPressedOption:(RMSwipeTableViewCell *)cell {
    UITextField *textField;
    BlockTextPromptAlertView *alert = [BlockTextPromptAlertView promptWithTitle:SetTitle(@"EditClassify") message:nil defaultText:[(ClassifyCell *)cell sortModel].sortName textField:&textField type:0 block:^(BlockTextPromptAlertView *alert){
        [alert.textField resignFirstResponder];
        return YES;
    }];
    
    [alert setCancelButtonWithTitle:SetTitle(@"alert_cancel") block:^{
        
    }];
    
    __weak __typeof(self)weakSelf = self;
    [alert setDestructiveButtonWithTitle:SetTitle(@"alert_confirm") block:^{
        
        [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSIndexPath *indexPath = [self.tableView.tableView indexPathForCell:cell];
            
            SortModel *sortModel = (SortModel *)self.dataArray[indexPath.section][@"data"][indexPath.row];
            
            AVObject *post = [[AVQuery queryWithClassName:@"Sort"] getObjectWithId:sortModel.sortId];
            //更新属性
            [post setObject:textField.text forKey:@"sortName"];
            //保存
            [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                    
                    if (!error) {
                        //已选择
                        if ([sortModel.sortId isEqualToString:weakSelf.selectedSortModel.sortId]) {
                            weakSelf.selectedSortModel.sortName = textField.text;
                        }
                        if (weakSelf.hasSelectedClassify.count>0) {
                            SortModel *sortModelTemp = (SortModel *)weakSelf.hasSelectedClassify[0];
                            if ([sortModel.sortId isEqualToString:sortModelTemp.sortId]) {
                                sortModelTemp.sortName = textField.text;
                            }
                        }
                        
                        sortModel.sortName = textField.text;
                        
                        NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"sortId == %@", sortModel.sortId];
                        NSMutableArray *filteredArray = [NSMutableArray arrayWithArray:[[DataShare sharedService].classifyArray filteredArrayUsingPredicate:predicateString]];
                        
                        [[DataShare sharedService].classifyArray removeObjectsInArray:filteredArray];
                        [[DataShare sharedService].classifyArray addObject:sortModel];
                        
                        [[DataShare sharedService] sortClassify:[DataShare sharedService].classifyArray CompleteBlock:^(NSArray *array) {
                            weakSelf.dataArray = [NSMutableArray arrayWithArray:array];
                            [weakSelf.tableView setHeaderAnimated:YES];
                            [weakSelf.tableView reloadData];
                        }];
                    }else {
                        [PopView showWithImageName:@"error" message:SetTitle(@"connect_error")];
                    }
                });
            }];
        });
    }];
    [alert show];
}


@end
