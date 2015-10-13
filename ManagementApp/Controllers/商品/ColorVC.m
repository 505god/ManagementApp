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

@interface ColorVC ()<SearchTableDelegate>

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
    
    
    ColorModel *model1 = [[ColorModel alloc]init];
    model1.colorName = @"电视剧";
    model1.productCount = 2;
    
    ColorModel *model2 = [[ColorModel alloc]init];
    model2.colorName = @"fghghfh";
    model2.productCount = 4;
    
    ColorModel *model3 = [[ColorModel alloc]init];
    model3.colorName = @"了解更多";
    model3.productCount = 45;
    
    ColorModel *model4 = [[ColorModel alloc]init];
    model4.colorName = @"电视剧";
    model4.productCount = 2;
    
    ColorModel *model5 = [[ColorModel alloc]init];
    model5.colorName = @"fghghfh";
    model5.productCount = 4;
    
    ColorModel *model6 = [[ColorModel alloc]init];
    model6.colorName = @"了解更多";
    model6.productCount = 45;
    
    ColorModel *model7 = [[ColorModel alloc]init];
    model7.colorName = @"电视剧";
    model7.productCount = 2;
    
    ColorModel *model8 = [[ColorModel alloc]init];
    model8.colorName = @"fghghfh";
    model8.productCount = 4;
    
    ColorModel *model9 = [[ColorModel alloc]init];
    model9.colorName = @"了解更多";
    model9.productCount = 45;
    
    ColorModel *model10 = [[ColorModel alloc]init];
    model10.colorName = @"电视剧";
    model10.productCount = 2;
    
    ColorModel *model11 = [[ColorModel alloc]init];
    model11.colorName = @"fghghfh";
    model11.productCount = 4;
    
    ColorModel *model12 = [[ColorModel alloc]init];
    model12.colorName = @"了解更多";
    model12.productCount = 45;
    
    self.colorList = [NSMutableArray arrayWithObjects:model1,model2,model3,model4,model5,model6,model7,model8,model9,model10,model11,model3,model12, nil];
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
    
    [cell setSelectedType:0];
    
    ColorModel *colorModel = nil;
    colorModel = (ColorModel *)self.dataArray[indexPath.section][@"data"][indexPath.row];
    [cell setColorModel:colorModel];
    
//    cell.delegate = self;
//    cell.revealDirection = RMSwipeTableViewCellRevealDirectionRight;
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

@end
