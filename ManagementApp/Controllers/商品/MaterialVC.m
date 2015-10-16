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

#import "BlockAlertView.h"
#import "BlockTextPromptAlertView.h"

@interface MaterialVC ()<SearchTableDelegate,RMSwipeTableViewCellDelegate>

///通讯录列表
@property (nonatomic, strong) SearchTable *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation MaterialVC

#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
    
    //集成刷新控件
    [self addHeader];
    
    self.isSelectedMaterial  =YES;
    
    MaterialModel *model1 = [[MaterialModel alloc]init];
    model1.materialName = @"电视剧";
    model1.productCount = 2;
    model1.materialId = 1;
    
    MaterialModel *model2 = [[MaterialModel alloc]init];
    model2.materialName = @"fghghfh";
    model2.productCount = 4;
    model2.materialId = 2;
    
    MaterialModel *model3 = [[MaterialModel alloc]init];
    model3.materialName = @"了解更多";
    model3.productCount = 45;
    model3.materialId = 3;
    
    MaterialModel *model4 = [[MaterialModel alloc]init];
    model4.materialName = @"电视剧";
    model4.productCount = 2;
    model4.materialId = 4;
    
    self.selectedMaterialModel = model4;
    [self.hasSelectedMaterial addObject:self.selectedMaterialModel];
    
    [DataShare sharedService].materialArray = [NSMutableArray arrayWithObjects:model1,model2,model3,model4, nil];
    __weak __typeof(self)weakSelf = self;
    
    [[DataShare sharedService] sortMaterial:[DataShare sharedService].materialArray CompleteBlock:^(NSArray *array) {
        weakSelf.dataArray = [NSMutableArray arrayWithArray:array];
        [weakSelf.tableView setHeaderAnimated:YES];
        [weakSelf.tableView reloadData];
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    /*
     ///第一次从服务器获取，后续从单例里面读取
     if ([DataShare sharedService].materialArray.count>0) {
     __weak __typeof(self)weakSelf = self;
     [[DataShare sharedService] sortMaterial:[DataShare sharedService].materialArray CompleteBlock:^(NSArray *array) {
     weakSelf.dataArray = [NSMutableArray arrayWithArray:array];
     [weakSelf.tableView setHeaderAnimated:YES];
     [weakSelf.tableView reloadData];
     }];
     }else {
     //自动刷新(一进入程序就下拉刷新)
     [self.tableView.tableView headerBeginRefreshing];
     }
     */
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter/setter

-(SearchTable *)tableView {
    if (!_tableView) {
        _tableView = [[SearchTable alloc] initWithFrame:(CGRect){0,self.navBarView.bottom,self.view.width,self.view.height-self.navBarView.height}];
        _tableView.delegate = self;
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
    [self.navBarView setRightWithArray:@[@"add"]];
    [self.view addSubview:self.navBarView];
}

#pragma mark - private

- (void)addHeader {
    
    __weak __typeof(self)weakSelf = self;
    [self.tableView.tableView addHeaderWithCallback:^{
        
        [weakSelf getDataFromSever];
        
    } dateKey:@"MaterialVC"];
}

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    if (self.isSelectedMaterial) {
        if (self.completedBlock) {
            
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    UITextField *textField;
    BlockTextPromptAlertView *alert = [BlockTextPromptAlertView promptWithTitle:SetTitle(@"addmaterial") message:nil textField:&textField type:0 block:^(BlockTextPromptAlertView *alert){
        [alert.textField resignFirstResponder];
        return YES;
    }];
    
    [alert setCancelButtonWithTitle:SetTitle(@"alert_cancel") block:^{
        
    }];
    __weak __typeof(self)weakSelf = self;
    [alert setDestructiveButtonWithTitle:SetTitle(@"alert_confirm") block:^{
        
        [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
        
        [[APIClient sharedClient] POST:@"/rest/store/addColor" parameters:@{} success:^(NSURLSessionDataTask *task, id responseObject) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
            
            NSDictionary *jsonData=(NSDictionary *)responseObject;
            
            if ([[jsonData objectForKey:@"status"]integerValue]==1) {
                
                NSDictionary *aDic = [jsonData objectForKey:@"returnObj"];
                if ([aDic allKeys].count>0) {
                    MaterialModel *materialModel = [[MaterialModel alloc] init];
                    [materialModel mts_setValuesForKeysWithDictionary:aDic];
                    
                    [[DataShare sharedService].materialArray addObject:materialModel];
                    [[DataShare sharedService] sortMaterial:[DataShare sharedService].materialArray CompleteBlock:^(NSArray *array) {
                        strongSelf.dataArray = [NSMutableArray arrayWithArray:array];
                        [strongSelf.tableView setHeaderAnimated:YES];
                        [strongSelf.tableView reloadData];
                    }];
                    [strongSelf.tableView reloadData];
                }
            }else {
                [Utility interfaceWithStatus:[jsonData[@"status"] integerValue] msg:jsonData[@"msg"]];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
            
            [PopView showWithImageName:@"error" message:SetTitle(@"connect_error")];
        }];
    }];
    [alert show];
}


#pragma mark - 获取颜色列表

-(void)getDataFromSever {
    ///接口请求
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak __typeof(self)weakSelf = self;
    [[APIClient sharedClient] POST:loginInterface parameters:@{} success:^(NSURLSessionDataTask *task, id responseObject) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
        
        NSDictionary *jsonData=(NSDictionary *)responseObject;
        
        if ([[jsonData objectForKey:@"status"]integerValue]==1) {
            
        }else {
            [Utility interfaceWithStatus:[jsonData[@"status"] integerValue] msg:jsonData[@"msg"]];
        }
        
        [strongSelf.tableView.tableView headerEndRefreshing];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [strongSelf.tableView.tableView headerEndRefreshing];
        
        [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
        
        [PopView showWithImageName:@"error" message:SetTitle(@"connect_error")];
    }];
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
        NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"materialId == %d", materialModel.materialId];
        NSMutableArray *filteredArray = [NSMutableArray arrayWithArray:[self.hasSelectedMaterial filteredArrayUsingPredicate:predicateString]];
        if (filteredArray.count>0) {
            ///已经选择
            [cell setSelectedType:2];
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
            
            if (materialModel.materialId == materialModelTemp.materialId) {
                ///已经选择,取消选择
                [cell setSelectedType:1];
                [self.hasSelectedMaterial removeAllObjects];
            }else {
                //找到materialModelTemp的index
                MaterialCell *cellTemp = (MaterialCell *)[tableView cellForRowAtIndexPath:materialModelTemp.indexPath];
                [cellTemp setSelectedType:1];
                
                [self.hasSelectedMaterial removeAllObjects];
                if (self.selectedMaterialModel && (materialModel.materialId == self.selectedMaterialModel.materialId)){
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
    if (point.x < 0 && (0-point.x) >= swipeTableViewCell.contentView.height)  {
        NSIndexPath *indexPath = [self.tableView.tableView indexPathForCell:swipeTableViewCell];
        
        MaterialModel *materialModel = (MaterialModel *)self.dataArray[indexPath.section][@"data"][indexPath.row];
        //        if (materialModel.productCount>0) {
        //            [PopView showWithImageName:@"error" message:SetTitle(@"materialDelete")];
        //        }else {
        swipeTableViewCell.shouldAnimateCellReset = YES;
        
        __weak __typeof(self)weakSelf = self;
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"" message:SetTitle(@"ConfirmDelete")];
        [alert setCancelButtonWithTitle:SetTitle(@"alert_cancel") block:^{
            
        }];
        [alert setDestructiveButtonWithTitle:SetTitle(@"alert_confirm") block:^{
            
            [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
            
            [[APIClient sharedClient] POST:@"" parameters:@{} success:^(NSURLSessionDataTask *task, id responseObject) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
                
                NSDictionary *jsonData=(NSDictionary *)responseObject;
                
                if ([[jsonData objectForKey:@"status"]integerValue]==1) {
                    
                    
                    NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"materialId == %d", materialModel.materialId];
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
                                             strongSelf.dataArray = [NSMutableArray arrayWithArray:array];
                                             [strongSelf.tableView setHeaderAnimated:YES];
                                             [strongSelf.tableView reloadData];
                                         }];
                                         
                                         [swipeTableViewCell setHidden:YES];
                                     }
                     ];
                }else {
                    [Utility interfaceWithStatus:[jsonData[@"status"] integerValue] msg:jsonData[@"msg"]];
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
                
                [PopView showWithImageName:@"error" message:SetTitle(@"connect_error")];
            }];
            
        }];
        [alert show];
        //        }
    }
}

//修改颜色
-(void)editDidLongPressedOption:(RMSwipeTableViewCell *)cell {
    UITextField *textField;
    BlockTextPromptAlertView *alert = [BlockTextPromptAlertView promptWithTitle:SetTitle(@"Editmaterial") message:nil defaultText:[(MaterialCell *)cell materialModel].materialName textField:&textField type:0 block:^(BlockTextPromptAlertView *alert){
        [alert.textField resignFirstResponder];
        return YES;
    }];
    
    [alert setCancelButtonWithTitle:SetTitle(@"alert_cancel") block:^{
        
    }];
    
    __weak __typeof(self)weakSelf = self;
    [alert setDestructiveButtonWithTitle:SetTitle(@"alert_confirm") block:^{
        
        [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
        
        NSIndexPath *indexPath = [self.tableView.tableView indexPathForCell:cell];
        
        MaterialModel *materialModel = (MaterialModel *)self.dataArray[indexPath.section][@"data"][indexPath.row];
        
        [[APIClient sharedClient] POST:@"/rest/store/updateColor" parameters:@{} success:^(NSURLSessionDataTask *task, id responseObject) {
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
            
            NSDictionary *jsonData=(NSDictionary *)responseObject;
            if ([[jsonData objectForKey:@"status"]integerValue]==1) {
                
                materialModel.materialName = textField.text;
                
                NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"materialId == %d", materialModel.materialId];
                NSMutableArray *filteredArray = [NSMutableArray arrayWithArray:[[DataShare sharedService].materialArray filteredArrayUsingPredicate:predicateString]];
                
                [[DataShare sharedService].materialArray removeObjectsInArray:filteredArray];
                [[DataShare sharedService].materialArray addObject:materialModel];
                
                [[DataShare sharedService] sortMaterial:[DataShare sharedService].materialArray CompleteBlock:^(NSArray *array) {
                    strongSelf.dataArray = [NSMutableArray arrayWithArray:array];
                    [strongSelf.tableView setHeaderAnimated:YES];
                    [strongSelf.tableView reloadData];
                }];
                
                
                [strongSelf.tableView reloadData];
            }else {
                [Utility interfaceWithStatus:[jsonData[@"status"] integerValue] msg:jsonData[@"msg"]];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
            
            [PopView showWithImageName:@"error" message:SetTitle(@"connect_error")];
        }];
    }];
    [alert show];
}

@end
