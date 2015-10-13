//
//  ColorVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/13.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ColorVC.h"

/*
 检索
 */
#import "SearchTable.h"
#import "ChineseInclude.h"
#import "PinYinForObjc.h"
#import "WQIndexedCollationWithSearch.h"

#import "ColorCell.h"

#import "BlockAlertView.h"
#import "BlockTextPromptAlertView.h"

@interface ColorVC ()<SearchTableDelegate,RMSwipeTableViewCellDelegate>

///通讯录列表
@property (nonatomic, strong) SearchTable *tableView;
@property (nonatomic, strong) NSMutableArray *colorList;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ColorVC

#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
    
    //集成刷新控件
    [self addHeader];
    
    self.isSelectedColor  =YES;
    
    ColorModel *model1 = [[ColorModel alloc]init];
    model1.colorName = @"电视剧";
    model1.productCount = 2;
    model1.colorId = 1;
    
    ColorModel *model2 = [[ColorModel alloc]init];
    model2.colorName = @"fghghfh";
    model2.productCount = 4;
    model2.colorId = 2;
    
    ColorModel *model3 = [[ColorModel alloc]init];
    model3.colorName = @"了解更多";
    model3.productCount = 45;
    model3.colorId = 3;
    
    ColorModel *model4 = [[ColorModel alloc]init];
    model4.colorName = @"电视剧";
    model4.productCount = 2;
    model4.productCount = 4;

    self.hasSelectedColor = [NSMutableArray arrayWithObjects:model1,model2, nil];
    
    self.colorList = [NSMutableArray arrayWithObjects:model1,model2,model3,model4, nil];
    __weak __typeof(self)weakSelf = self;
    [[DataShare sharedService] sortColors:self.colorList CompleteBlock:^(NSArray *array) {
        weakSelf.dataArray = [NSMutableArray arrayWithArray:array];
        [weakSelf.tableView setHeaderAnimated:YES];
        [weakSelf.tableView reloadData];
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessage:) name:@"newMessage" object:nil];
    
    
    /*
    ///第一次从服务器获取，后续从单例里面读取
    if ([DataShare sharedService].colorArray.count>0) {
        self.colorList = [NSMutableArray arrayWithArray:[DataShare sharedService].colorArray];
        
        __weak __typeof(self)weakSelf = self;
        [[DataShare sharedService] sortColors:[DataShare sharedService].colorArray CompleteBlock:^(NSArray *array) {
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"newMessage" object:nil];
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

-(NSMutableArray *)colorList {
    if (!_colorList) {
        _colorList = [[NSMutableArray alloc]init];
    }
    return _colorList;
}


#pragma mark - UI

-(void)setNavBarView {
    [self.navBarView setTitle:SetTitle(@"color") image:nil];
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.navBarView setRightWithArray:@[@"add"]];
    [self.view addSubview:self.navBarView];
}

#pragma mark - private

- (void)addHeader {
    
    __weak __typeof(self)weakSelf = self;
    [self.tableView.tableView addHeaderWithCallback:^{
        
        [weakSelf getDataFromSever];
        
    } dateKey:@"ColorVC"];
}

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
}

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    UITextField *textField;
    BlockTextPromptAlertView *alert = [BlockTextPromptAlertView promptWithTitle:SetTitle(@"addColor") message:nil textField:&textField type:0 block:^(BlockTextPromptAlertView *alert){
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
                    ColorModel *colorModel = [[ColorModel alloc] init];
                    [colorModel mts_setValuesForKeysWithDictionary:aDic];
                    
                    [[DataShare sharedService].colorArray addObject:colorModel];
                    [[DataShare sharedService] sortColors:[DataShare sharedService].colorArray CompleteBlock:^(NSArray *array) {
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

#pragma mark - 通知来新消息

-(void)newMessage:(NSNotification *)notification  {
    [self.tableView reloadData];
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
    static NSString * CellIdentifier = @"color_cell";
    
    ColorCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ColorCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                     reuseIdentifier:CellIdentifier];
    }
    
    cell.delegate = self;
    cell.revealDirection = RMSwipeTableViewCellRevealDirectionRight;
    [cell setSelectedType:0];
    [cell setIndexPath:indexPath];
    
    ColorModel *colorModel = (ColorModel *)self.dataArray[indexPath.section][@"data"][indexPath.row];
    [cell setColorModel:colorModel];
    
    if (self.isSelectedColor) {
        NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"colorId == %d", colorModel.colorId];
        NSMutableArray *filteredArray = [NSMutableArray arrayWithArray:[self.hasSelectedColor filteredArrayUsingPredicate:predicateString]];
        
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
    
    ColorCell *cell = (ColorCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (self.isSelectedColor) {
         ColorModel *colorModel = (ColorModel *)self.dataArray[indexPath.section][@"data"][indexPath.row];
        
        NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"colorId == %d", colorModel.colorId];
        NSMutableArray *filteredArray = [NSMutableArray arrayWithArray:[self.hasSelectedColor filteredArrayUsingPredicate:predicateString]];
        if (filteredArray.count>0) {
            ///已经选择,取消选择
            [cell setSelectedType:1];
            [self.hasSelectedColor removeObjectsInArray:filteredArray];
        }else {
            ///选择
            [cell setSelectedType:2];
            [self.hasSelectedColor addObject:colorModel];
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
    [[DataShare sharedService] sortColors:self.colorList CompleteBlock:^(NSArray *array) {
        weakSelf.dataArray = [NSMutableArray arrayWithArray:array];
        [weakSelf.tableView setHeaderAnimated:YES];
        [weakSelf.tableView reloadData];
    }];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSMutableArray *searchResults = [NSMutableArray array];
    
    if (searchBar.text.length>0 && ![ChineseInclude isIncludeChineseInString:searchBar.text]) {//英文或者数字搜素
        
        [self.colorList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ColorModel *colorModel = (ColorModel *)obj;
            
            if ([ChineseInclude isIncludeChineseInString:colorModel.colorName]) {//名称含有中文
                //转换为拼音
                NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:colorModel.colorName];
                NSRange titleResult=[tempPinYinStr rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0 && ![searchResults containsObject:colorModel]) {
                    [searchResults addObject:colorModel];
                }
                
                //转换为拼音首字母
                NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:colorModel.colorName];
                NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
                if (titleHeadResult.length>0 && ![searchResults containsObject:colorModel]) {
                    [searchResults addObject:colorModel];
                }
            }else {
                //昵称含有数字
                NSRange titleResult=[colorModel.colorName rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [searchResults addObject:colorModel];
                }
            }
        }];
        
    } else if (searchBar.text.length>0&&[ChineseInclude isIncludeChineseInString:searchBar.text]) {//中文搜索
        for (ColorModel *colorModel in self.colorList) {
            NSRange titleResult=[colorModel.colorName rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
            if (titleResult.length>0) {
                [searchResults addObject:colorModel];
            }
        }
    }else if (searchBar.text.length == 0){
        [searchResults addObjectsFromArray:self.colorList];
    }
    
    
    __weak __typeof(self)weakSelf = self;
    [[DataShare sharedService] sortColors:searchResults CompleteBlock:^(NSArray *array) {
        weakSelf.dataArray = [NSMutableArray arrayWithArray:array];
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - RMSwipeTableViewCellDelegate
//删除颜色
-(void)swipeTableViewCellWillResetState:(RMSwipeTableViewCell *)swipeTableViewCell fromPoint:(CGPoint)point animation:(RMSwipeTableViewCellAnimationType)animation velocity:(CGPoint)velocity {
    if (point.x < 0 && (0-point.x) >= swipeTableViewCell.contentView.height)  {
        NSIndexPath *indexPath = [self.tableView.tableView indexPathForCell:swipeTableViewCell];
        
        ColorModel *colorModel = (ColorModel *)self.dataArray[indexPath.section][@"data"][indexPath.row];
//        if (colorModel.productCount>0) {
//            [PopView showWithImageName:@"error" message:SetTitle(@"ColorDelete")];
//        }else {
            swipeTableViewCell.shouldAnimateCellReset = YES;
            
            __weak __typeof(self)weakSelf = self;
            BlockAlertView *alert = [BlockAlertView alertWithTitle:@"" message:SetTitle(@"ConfirmDelete")];
            [alert setCancelButtonWithTitle:SetTitle(@"alert_cancel") block:^{
                
            }];
            [alert setDestructiveButtonWithTitle:SetTitle(@"alert_confirm") block:^{
                
                
                [UIView animateWithDuration:0.25
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     swipeTableViewCell.contentView.frame = CGRectOffset(swipeTableViewCell.contentView.bounds, swipeTableViewCell.contentView.frame.size.width, 0);
                                 }
                                 completion:^(BOOL finished) {
                                     
                                     [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                                     
                                     [[APIClient sharedClient] POST:@"" parameters:@{} success:^(NSURLSessionDataTask *task, id responseObject) {
                                         __strong __typeof(weakSelf)strongSelf = weakSelf;
                                         if (!strongSelf) {
                                             return;
                                         }
                                         [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
                                         
                                         NSDictionary *jsonData=(NSDictionary *)responseObject;
                                         
                                         if ([[jsonData objectForKey:@"status"]integerValue]==1) {
                                             
                                             
                                             NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"colorId == %d", colorModel.colorId];
                                             NSMutableArray *filteredArray = [NSMutableArray arrayWithArray:[[DataShare sharedService].colorArray filteredArrayUsingPredicate:predicateString]];
                                             
                                             [[DataShare sharedService].colorArray removeObjectsInArray:filteredArray];
                                             
                                             [[DataShare sharedService] sortColors:[DataShare sharedService].colorArray CompleteBlock:^(NSArray *array) {
                                                 strongSelf.dataArray = [NSMutableArray arrayWithArray:array];
                                                 [strongSelf.tableView setHeaderAnimated:YES];
                                                 [strongSelf.tableView reloadData];
                                             }];
                                             
                                             
                                             [swipeTableViewCell setHidden:YES];
                                             
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
                                 }
                 ];
            }];
            [alert show];
//        }
    }
}

//修改颜色
-(void)editDidLongPressedOption:(RMSwipeTableViewCell *)cell {
    UITextField *textField;
    BlockTextPromptAlertView *alert = [BlockTextPromptAlertView promptWithTitle:SetTitle(@"EditColor") message:nil defaultText:[(ColorCell *)cell colorModel].colorName textField:&textField type:0 block:^(BlockTextPromptAlertView *alert){
        [alert.textField resignFirstResponder];
        return YES;
    }];
    
    [alert setCancelButtonWithTitle:SetTitle(@"alert_cancel") block:^{
        
    }];
    
    __weak __typeof(self)weakSelf = self;
    [alert setDestructiveButtonWithTitle:SetTitle(@"alert_confirm") block:^{
        
        [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
        
        NSIndexPath *indexPath = [self.tableView.tableView indexPathForCell:cell];
        
        ColorModel *colorModel = (ColorModel *)self.dataArray[indexPath.section][@"data"][indexPath.row];
        
        [[APIClient sharedClient] POST:@"/rest/store/updateColor" parameters:@{} success:^(NSURLSessionDataTask *task, id responseObject) {
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
            
            NSDictionary *jsonData=(NSDictionary *)responseObject;
            if ([[jsonData objectForKey:@"status"]integerValue]==1) {
                
                colorModel.colorName = textField.text;
                
                NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"colorId == %d", colorModel.colorId];
                NSMutableArray *filteredArray = [NSMutableArray arrayWithArray:[[DataShare sharedService].colorArray filteredArrayUsingPredicate:predicateString]];
                
                [[DataShare sharedService].colorArray removeObjectsInArray:filteredArray];
                [[DataShare sharedService].colorArray addObject:colorModel];
                
                [[DataShare sharedService] sortColors:[DataShare sharedService].colorArray CompleteBlock:^(NSArray *array) {
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
