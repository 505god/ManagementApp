//
//  MaterialVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/14.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "MaterialVC.h"

/*
 检索
 */
#import "SearchTable.h"
#import "ChineseInclude.h"
#import "PinYinForObjc.h"
#import "WQIndexedCollationWithSearch.h"

#import "MaterialCell.h"


@interface MaterialVC ()<SearchTableDelegate,RMSwipeTableViewCellDelegate>

///通讯录列表
@property (nonatomic, strong) SearchTable *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation MaterialVC

-(void)dealloc {
    SafeRelease(_tableView);
    SafeRelease(_dataArray);
    SafeRelease(_selectedMaterialModel);
    SafeRelease(_hasSelectedMaterial);
    SafeRelease(_completedBlock);
}

#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
    
    //集成刷新控件
    [self addHeader];
    
    if (self.selectedMaterialModel) {
        [self.hasSelectedMaterial addObject:self.selectedMaterialModel];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView.tableView.mj_header beginRefreshing];
    
    //    ///第一次从服务器获取，后续从单例里面读取
    //    if ([DataShare sharedService].materialArray.count>0) {
    //        __weak __typeof(self)weakSelf = self;
    //        [[DataShare sharedService] sortMaterial:[DataShare sharedService].materialArray CompleteBlock:^(NSArray *array) {
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
        SafeRelease(_selectedMaterialModel);
        SafeRelease(_hasSelectedMaterial);
        SafeRelease(_completedBlock);
        self.view=nil;
    }
}

#pragma mark - getter/setter

-(SearchTable *)tableView {
    if (!_tableView) {
        _tableView = [[SearchTable alloc] initWithFrame:(CGRect){0,self.navBarView.bottom,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height-self.navBarView.height}];
        _tableView.delegate = self;
        _tableView.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [Utility setExtraCellLineHidden:_tableView.tableView];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

-(NSMutableArray *)hasSelectedMaterial {
    if (!_hasSelectedMaterial) {
        _hasSelectedMaterial = [[NSMutableArray alloc]init];
    }
    return _hasSelectedMaterial;
}

#pragma mark - UI

-(void)setNavBarView {
    [self.navBarView setTitle:SetTitle(@"material") image:nil];
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.navBarView setRightWithArray:@[@"add"] type:0];
    [self.view addSubview:self.navBarView];
}

#pragma mark - private

- (void)addHeader {
    
    __weak __typeof(self)weakSelf = self;
    self.tableView.tableView.mj_header = [LCCKConversationRefreshHeader headerWithRefreshingBlock:^{
        [weakSelf getDataFromSever];
    }];
}

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    if (self.isSelectedMaterial) {
        if (self.completedBlock) {
            if (self.hasSelectedMaterial.count>0) {
                self.completedBlock(self.hasSelectedMaterial[0]);
            }else {
                self.completedBlock(nil);
            }
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    if ([Utility isAuthority]) {
        QWeakSelf(self);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:SetTitle(@"addmaterial") preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.textAlignment = NSTextAlignmentCenter;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];
        }];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:SetTitle(@"alert_confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alert.textFields.firstObject];
            
            
            [MBProgressHUD showHUDAddedTo:weakself.view animated:YES];
            
            //保存对象
            AVObject *post = [AVObject objectWithClassName:@"Material"];
            post[@"materialName"] = (UITextField *)alert.textFields.firstObject.text;
            
            // 为颜色和卖家建立一对一关系
            [post setObject:[AVUser currentUser] forKey:@"user"];
            
            [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    AVQuery *query = [AVQuery queryWithClassName:@"Material"];
                    query.cachePolicy = kAVCachePolicyNetworkElseCache;
                    query.maxCacheAge = 24*3600;// 一天的总秒数
                    
                    [query whereKey:@"user" equalTo:[AVUser currentUser]];
                    
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        
                        [MBProgressHUD hideAllHUDsForView:weakself.view animated:YES];
                        
                        if (!error) {
                            [DataShare sharedService].materialArray = nil;
                            for (int i=0; i<objects.count; i++) {
                                AVObject *object = objects[i];
                                
                                MaterialModel *model = [MaterialModel initWithObject:object];
                                [[DataShare sharedService].materialArray addObject:model];
                            }
                            
                            [[DataShare sharedService] sortMaterial:[DataShare sharedService].materialArray CompleteBlock:^(NSArray *array) {
                                weakself.dataArray = [NSMutableArray arrayWithArray:array];
                                [weakself.tableView setHeaderAnimated:YES];
                                [weakself.tableView reloadData];
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
//        [action setValue:kThemeColor forKey:@"_titleTextColor"];
        action.enabled = NO;
        [alert addAction:action];
        self.sureAction = action;
        
        [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
        [self presentViewController:alert animated:YES completion:nil];
    }else {
        /*
        QWeakSelf(self);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"authority_tip") message:SetTitle(@"authority_error") preferredStyle:UIAlertControllerStyleAlert];
        [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
            
            AuthorityVC *vc = LOADVC(@"AuthorityVC");
            [weakself.navigationController pushViewController:vc animated:YES];
        }];
        [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
        [self presentViewController:alert animated:YES completion:nil];
         */
    }
}

- (void)handleTextFieldTextDidChangeNotification:(NSNotification *)notification {
    UITextField *textField = notification.object;
    
    self.sureAction.enabled = textField.text.length >= 1;
}

#pragma mark - 获取颜色列表

-(void)getDataFromSever {
    if ([DataShare sharedService].appDel.isReachable) {
        __weak __typeof(self)weakSelf = self;
        
        AVQuery *query = [AVQuery queryWithClassName:@"Material"];
        query.cachePolicy = kAVCachePolicyNetworkElseCache;
        query.maxCacheAge = 24*3600;
        [query orderByDescending:@"updatedAt"];
        [query whereKey:@"user" equalTo:[AVUser currentUser]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [weakSelf.tableView.tableView.mj_header endRefreshing];
            if (!error) {
                [DataShare sharedService].materialArray = nil;
                for (int i=0; i<objects.count; i++) {
                    AVObject *object = objects[i];
                    
                    MaterialModel *model = [MaterialModel initWithObject:object];
                    [[DataShare sharedService].materialArray addObject:model];
                }
                
                [[DataShare sharedService] sortMaterial:[DataShare sharedService].materialArray CompleteBlock:^(NSArray *array) {
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
    static NSString * CellIdentifier = @"material_cell";
    
    MaterialCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MaterialCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                   reuseIdentifier:CellIdentifier];
    }
    
    cell.delegate = self;
    cell.revealDirection = RMSwipeTableViewCellRevealDirectionRight;
    [cell setSelectedType:0];
    [cell setIndexPath:indexPath];
    
    MaterialModel *materialModel = (MaterialModel *)self.dataArray[indexPath.section][@"data"][indexPath.row];
    materialModel.indexPath = indexPath;
    
    [cell setMaterialModel:materialModel];
    
    if (self.isSelectedMaterial) {
        NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"materialId == %@", materialModel.materialId];
        NSMutableArray *filteredArray = [NSMutableArray arrayWithArray:[self.hasSelectedMaterial filteredArrayUsingPredicate:predicateString]];
        if (filteredArray.count>0) {
            ///已经选择
            [cell setSelectedType:2];
            
            MaterialModel *materialModelTemp = filteredArray[0];
            materialModelTemp.indexPath = indexPath;
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
    
    MaterialCell *cell = (MaterialCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (self.isSelectedMaterial) {
        
        MaterialModel *materialModel = (MaterialModel *)self.dataArray[indexPath.section][@"data"][indexPath.row];
        
        if (self.hasSelectedMaterial.count>0) {
            MaterialModel *materialModelTemp = (MaterialModel *)self.hasSelectedMaterial[0];
            
            if ([materialModel.materialId isEqualToString:materialModelTemp.materialId]) {
                ///已经选择,取消选择
                [cell setSelectedType:1];
                [self.hasSelectedMaterial removeAllObjects];
            }else {
                //找到materialModelTemp的index
                MaterialCell *cellTemp = (MaterialCell *)[tableView cellForRowAtIndexPath:materialModelTemp.indexPath];
                [cellTemp setSelectedType:1];
                
                [self.hasSelectedMaterial removeAllObjects];
                if (self.selectedMaterialModel && ([materialModel.materialId isEqualToString:self.selectedMaterialModel.materialId])){
                    [self.hasSelectedMaterial addObject:self.selectedMaterialModel];
                }else {
                    [self.hasSelectedMaterial addObject:materialModel];
                }
                ///选择
                [cell setSelectedType:2];
            }
        }else {
            ///选择
            [self.hasSelectedMaterial addObject:materialModel];
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
    [[DataShare sharedService] sortMaterial:[DataShare sharedService].materialArray CompleteBlock:^(NSArray *array) {
        weakSelf.dataArray = [NSMutableArray arrayWithArray:array];
        [weakSelf.tableView setHeaderAnimated:YES];
        [weakSelf.tableView reloadData];
    }];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSMutableArray *searchResults = [NSMutableArray array];
    
    if (searchBar.text.length>0 && ![ChineseInclude isIncludeChineseInString:searchBar.text]) {//英文或者数字搜素
        
        [[DataShare sharedService].materialArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MaterialModel *materialModel = (MaterialModel *)obj;
            
            if ([ChineseInclude isIncludeChineseInString:materialModel.materialName]) {//名称含有中文
                //转换为拼音
                NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:materialModel.materialName];
                NSRange titleResult=[tempPinYinStr rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0 && ![searchResults containsObject:materialModel]) {
                    [searchResults addObject:materialModel];
                }
                
                //转换为拼音首字母
                NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:materialModel.materialName];
                NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
                if (titleHeadResult.length>0 && ![searchResults containsObject:materialModel]) {
                    [searchResults addObject:materialModel];
                }
            }else {
                //昵称含有数字
                NSRange titleResult=[materialModel.materialName rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [searchResults addObject:materialModel];
                }
            }
        }];
        
    } else if (searchBar.text.length>0&&[ChineseInclude isIncludeChineseInString:searchBar.text]) {//中文搜索
        for (MaterialModel *materialModel in [DataShare sharedService].materialArray) {
            NSRange titleResult=[materialModel.materialName rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
            if (titleResult.length>0) {
                [searchResults addObject:materialModel];
            }
        }
    }else if (searchBar.text.length == 0){
        [searchResults addObjectsFromArray:[DataShare sharedService].materialArray];
    }
    
    
    __weak __typeof(self)weakSelf = self;
    [[DataShare sharedService] sortMaterial:searchResults CompleteBlock:^(NSArray *array) {
        weakSelf.dataArray = [NSMutableArray arrayWithArray:array];
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - RMSwipeTableViewCellDelegate
//删除颜色
-(void)swipeTableViewCellWillResetState:(RMSwipeTableViewCell *)swipeTableViewCell fromPoint:(CGPoint)point animation:(RMSwipeTableViewCellAnimationType)animation velocity:(CGPoint)velocity {
    if ([Utility isAuthority]) {
        if (point.x < 0 && (0-point.x) >= swipeTableViewCell.contentView.height)  {
            NSIndexPath *indexPath = [self.tableView.tableView indexPathForCell:swipeTableViewCell];
            
            MaterialModel *materialModel = (MaterialModel *)self.dataArray[indexPath.section][@"data"][indexPath.row];
            if (materialModel.productCount>0) {
                [PopView showWithImageName:@"error" message:SetTitle(@"materialDelete")];
            }else {
                swipeTableViewCell.shouldAnimateCellReset = YES;
                
                __weak __typeof(self)weakSelf = self;
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:SetTitle(@"ConfirmDelete") preferredStyle:UIAlertControllerStyleAlert];
                
                [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
                
                [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
                    [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                    
                    AVObject *post = [[AVQuery queryWithClassName:@"Material"] getObjectWithId:materialModel.materialId];
                    [post deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                        
                        if (!error) {
                            //已选择
                            if ([materialModel.materialId isEqualToString:weakSelf.selectedMaterialModel.materialId]) {
                                weakSelf.selectedMaterialModel = nil;
                            }
                            if (weakSelf.hasSelectedMaterial.count>0) {
                                MaterialModel *materialModelTemp = (MaterialModel *)weakSelf.hasSelectedMaterial[0];
                                if ([materialModel.materialId isEqualToString:materialModelTemp.materialId]) {
                                    [weakSelf.hasSelectedMaterial removeAllObjects];
                                }
                            }
                            
                            NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"materialId == %@", materialModel.materialId];
                            NSMutableArray *filteredArray = [NSMutableArray arrayWithArray:[[DataShare sharedService].materialArray filteredArrayUsingPredicate:predicateString]];
                            
                            [[DataShare sharedService].materialArray removeObjectsInArray:filteredArray];
                            
                            [UIView animateWithDuration:0.25
                                                  delay:0
                                                options:UIViewAnimationOptionCurveLinear
                                             animations:^{
                                                 swipeTableViewCell.contentView.frame = CGRectOffset(swipeTableViewCell.contentView.bounds, swipeTableViewCell.contentView.frame.size.width, 0);
                                             }
                                             completion:^(BOOL finished) {
                                                 [[DataShare sharedService] sortMaterial:[DataShare sharedService].materialArray CompleteBlock:^(NSArray *array) {
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
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    }else {
        /*
        QWeakSelf(self);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"authority_tip") message:SetTitle(@"authority_error") preferredStyle:UIAlertControllerStyleAlert];
        [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
            
            AuthorityVC *vc = LOADVC(@"AuthorityVC");
            [weakself.navigationController pushViewController:vc animated:YES];
        }];
        [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
        [self presentViewController:alert animated:YES completion:nil];
         */
    }
}

//修改颜色
-(void)editDidLongPressedOption:(RMSwipeTableViewCell *)cell {
    if ([Utility isAuthority]) {
        QWeakSelf(self);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:SetTitle(@"Editmaterial") preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.textAlignment = NSTextAlignmentCenter;
            textField.text = [(MaterialCell *)cell materialModel].materialName;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];
        }];
        UIAlertAction *action = [UIAlertAction actionWithTitle:SetTitle(@"alert_confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alert.textFields.firstObject];
            
            
            [MBProgressHUD showHUDAddedTo:weakself.view animated:YES];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSIndexPath *indexPath = [self.tableView.tableView indexPathForCell:cell];
                
                MaterialModel *materialModel = (MaterialModel *)self.dataArray[indexPath.section][@"data"][indexPath.row];
                
                AVObject *post = [[AVQuery queryWithClassName:@"Material"] getObjectWithId:materialModel.materialId];
                //更新属性
                UITextField *textField = (UITextField *)alert.textFields.firstObject;
                [post setObject:textField.text forKey:@"materialName"];
                //保存
                
                __weak __typeof(textField)weakTXT = textField;
                [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideAllHUDsForView:weakself.view animated:YES];
                        
                        if (!error) {
                            //已选择
                            if ([materialModel.materialId isEqualToString:weakself.selectedMaterialModel.materialId]) {
                                weakself.selectedMaterialModel.materialName = weakTXT.text;
                            }
                            if (weakself.hasSelectedMaterial.count>0) {
                                MaterialModel *materialModelTemp = (MaterialModel *)weakself.hasSelectedMaterial[0];
                                if ([materialModel.materialId isEqualToString:materialModelTemp.materialId]) {
                                    materialModelTemp.materialName = weakTXT.text;
                                }
                            }
                            
                            materialModel.materialName =weakTXT.text;
                            NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"materialId == %@", materialModel.materialId];
                            NSMutableArray *filteredArray = [NSMutableArray arrayWithArray:[[DataShare sharedService].materialArray filteredArrayUsingPredicate:predicateString]];
                            
                            [[DataShare sharedService].materialArray removeObjectsInArray:filteredArray];
                            [[DataShare sharedService].materialArray addObject:materialModel];
                            
                            [[DataShare sharedService] sortMaterial:[DataShare sharedService].materialArray CompleteBlock:^(NSArray *array) {
                                weakself.dataArray = [NSMutableArray arrayWithArray:array];
                                [weakself.tableView setHeaderAnimated:YES];
                                [weakself.tableView reloadData];
                            }];
                        }else {
                            [PopView showWithImageName:@"error" message:SetTitle(@"connect_error")];
                        }
                    });
                }];
            });
        }];
//        [action setValue:kThemeColor forKey:@"_titleTextColor"];
        action.enabled = NO;
        [alert addAction:action];
        self.sureAction = action;
        
        [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
        [self presentViewController:alert animated:YES completion:nil];
    }else {
        /*
        QWeakSelf(self);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"authority_tip") message:SetTitle(@"authority_error") preferredStyle:UIAlertControllerStyleAlert];
        [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
            
            AuthorityVC *vc = LOADVC(@"AuthorityVC");
            [weakself.navigationController pushViewController:vc animated:YES];
        }];
        [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
        [self presentViewController:alert animated:YES completion:nil];
         */
    }
}

@end
