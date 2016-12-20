//
//  ProductSearchVC.m
//  ManagementApp
//
//  Created by 邱成西 on 16/1/16.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "ProductSearchVC.h"
#import "ProductCell.h"
#import "ProductModel.h"
#import "ProductDetailVC.h"
#import "ProductHeader.h"

@interface ProductSearchVC ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *searchArray;
@property (nonatomic, assign) CGFloat keyboardHeight;//键盘高度

@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) BOOL isLoadingMore;
@end

@implementation ProductSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
    
    [self addHeader];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - private

- (void)addHeader {
    __weak __typeof(self)weakSelf = self;
    self.tableView.mj_header = [LCCKConversationRefreshHeader headerWithRefreshingBlock:^{
        if (weakSelf.searchBar.text.length==0) {
            [PopView showWithImageName:@"error" message:SetTitle(@"search_name")];
            return;
        }
        weakSelf.start = 0;
        weakSelf.isLoadingMore = NO;
        [weakSelf getDataFromSever];
    }];
}

- (void)addFooter {
    __weak __typeof(self)weakSelf = self;
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        weakSelf.start ++;
        weakSelf.isLoadingMore = YES;
        [weakSelf getDataFromSever];
    }];
}


#pragma mark - property

-(NSMutableArray *)searchArray
{
    if (!_searchArray) {
        _searchArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _searchArray;
}


#pragma mark - UI

-(void)setNavBarView {
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.view addSubview:self.navBarView];
    
    [self setTableView];
    
    [self searchBarInit];
}

-(void)setTableView {
    self.tableView = [[UITableView alloc]initWithFrame:(CGRect){0,self.navBarView.bottom,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height-self.navBarView.bottom} style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[ProductHeader class] forHeaderFooterViewReuseIdentifier:@"ProductHeader"];
    [Utility setExtraCellLineHidden:self.tableView];
    [self.view addSubview:self.tableView];
}

- (void)searchBarInit {
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-250)/2, 20, 250.0f, 44.0f)];
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    self.searchBar.translucent=NO;
    self.searchBar.placeholder=SetTitle(@"search_name");
    self.searchBar.delegate = self;
    self.searchBar.barStyle=UIBarStyleDefault;

    if ([self.searchBar respondsToSelector : @selector (barTintColor)]){
        if (Platform>=7.1){
            [[[[self.searchBar.subviews objectAtIndex:0] subviews] objectAtIndex:0] removeFromSuperview];
        }else{//7.0
            [self.searchBar setBarTintColor :[UIColor clearColor]];
        }
    }else {//7.0以下
        [[self.searchBar.subviews objectAtIndex:0] removeFromSuperview];
    }
    
    [self.navBarView addSubview:self.searchBar];
}

#pragma mark - 导航栏代理


-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         CGRect frame = self.tableView.frame;
                         frame.size.height += self.keyboardHeight;
                         frame.size.height -= keyboardRect.size.height;
                         self.tableView.frame = frame;
                         
                         self.keyboardHeight = keyboardRect.size.height;
                     }];
    userInfo = nil;
    aValue = nil;
    animationDurationValue = nil;
}
- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         CGRect frame = self.tableView.frame;
                         frame.size.height += self.keyboardHeight;
                         self.tableView.frame = frame;
                         
                         self.keyboardHeight = 0;
                     }];
    userInfo = nil;
    animationDurationValue = nil;
}

#pragma mark   ---------searchBar协议----------------

- (void)searchBarTextDidBeginEditing:(UISearchBar *)search {
    search.showsCancelButton = YES;
    for(id cc in [search subviews]) {
        if([cc isKindOfClass:[UIView class]]) {
            UIView *cc_view = (UIView *)cc;
            for (id vv in [cc_view subviews]){
                if([vv isKindOfClass:[UIButton class]]){
                    UIButton *btn = (UIButton *)vv;
                    [btn setTitle:SetTitle(@"cancel") forState:UIControlStateNormal];
                    [btn setTintColor:[UIColor whiteColor]];
                }
            }
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)search{
    self.searchBar.showsCancelButton=NO;
    self.searchBar.text=nil;
    [self.searchBar resignFirstResponder];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)search {
    [self.searchBar resignFirstResponder];
    
    if (self.searchBar.text.length<=0) {
        [PopView showWithImageName:@"error" message:SetTitle(@"search_name")];
    }else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.start = 0;
        self.isLoadingMore = NO;
        [self getDataFromSever];
    }
}

#pragma mark - 获取列表

-(void)getDataFromSever {
    if ([DataShare sharedService].appDel.isReachable) {
        __weak __typeof(self)weakSelf = self;
        
        AVQuery *query1 = [AVQuery queryWithClassName:@"Product"];
        query1.cachePolicy = kAVCachePolicyNetworkElseCache;
        query1.maxCacheAge = 24*3600;// 一天的总秒数
        [query1 whereKey:@"user" equalTo:[AVUser currentUser]];
        [query1 orderByDescending:@"updatedAt"];
        
        query1.limit = 10;
        query1.skip = 10*self.start;
        [query1 whereKey:@"productName" containsString:self.searchBar.text];
        
        [query1 includeKey:@"sort"];
        [query1 includeKey:@"material"];
        [query1 includeKey:@"products"];
        
        [query1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.tableView.mj_footer endRefreshing];
            if (!error) {
                if (!weakSelf.isLoadingMore) {
                    weakSelf.searchArray = nil;
                }
                [weakSelf.tableView.mj_footer setHidden:YES];
                if (objects.count==10) {
                    [weakSelf addFooter];
                }
                for (int i=0; i<objects.count; i++) {
                    AVObject *object = objects[i];
                    
                    ProductModel *model = [ProductModel initWithObject:object];
                    [weakSelf.searchArray addObject:model];
                }
                
                [weakSelf.tableView reloadData];
                
            } else {
                [PopView showWithImageName:@"error" message:SetTitle(@"connect_error")];
            }
        }];
    }else {
        [PopView showWithImageName:@"error" message:SetTitle(@"no_connect")];
    }
}

#pragma mark -

#pragma mark - table代理
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ProductHeader *header = (ProductHeader*)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ProductHeader"];
    header.type = 1;
    return header;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchArray.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * identifier = @"product_cell";
    
    ProductCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[ProductCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier type:1 inTableView:self.tableView];
    }
    
    cell.idxPath = indexPath;
    cell.productModel = self.searchArray[indexPath.row];
    
    __weak __typeof(self)weakSelf = self;
    cell.hotChange = ^(ProductModel *productMode,NSIndexPath *idxPath){
        [weakSelf hotByProduct:productMode idx:idxPath];
    };
    cell.saleChange = ^(ProductModel *productMode,NSIndexPath *idxPath){
        [weakSelf saleByProduct:productMode idx:idxPath];
    };
    cell.deleteCell = ^(NSIndexPath *idxPath){
        [weakSelf deleteByIdx:idxPath];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ProductDetailVC *detailVC = LOADVC(@"ProductDetailVC");
    detailVC.productModel = self.searchArray[indexPath.row];
    [self.navigationController pushViewController:detailVC animated:YES];
    SafeRelease(detailVC);
}

#pragma mark -
#pragma mark - 热卖、上架、删除

-(void)hotByProduct:(ProductModel *)productMode idx:(NSIndexPath *)idxPath {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak __typeof(self)weakSelf = self;
    
    AVObject *mPost = [[AVQuery queryWithClassName:@"Product"] getObjectWithId:productMode.productId];
    [mPost setObject:[NSNumber numberWithBool:!productMode.isHot] forKey:@"hot"];
    [mPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        if (!error) {
            productMode.isHot = !productMode.isHot;
            for (int i=0; i<productMode.productStockArray.count; i++) {
                ProductStockModel *model2 = (ProductStockModel *)productMode.productStockArray[i];
                AVObject *p_Post = [[AVQuery queryWithClassName:@"ProductStock"] getObjectWithId:model2.ProductStockId];
                [p_Post setObject:[NSNumber numberWithBool:productMode.isHot] forKey:@"hot"];
                [p_Post saveInBackground];
                
                model2.isHot = productMode.isHot;
                [productMode.productStockArray replaceObjectAtIndex:i withObject:model2];
            }
            
            [weakSelf.searchArray replaceObjectAtIndex:idxPath.row withObject:productMode];
            
            [weakSelf.tableView reloadRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        
    }];
}

-(void)saleByProduct:(ProductModel *)productMode idx:(NSIndexPath *)idxPath {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak __typeof(self)weakSelf = self;
    
    AVObject *mPost = [[AVQuery queryWithClassName:@"Product"] getObjectWithId:productMode.productId];
    [mPost setObject:[NSNumber numberWithBool:!productMode.isDisplay] forKey:@"sale"];
    [mPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        if (!error) {
            productMode.isDisplay = !productMode.isDisplay;
            
            for (int i=0; i<productMode.productStockArray.count; i++) {
                ProductStockModel *model2 = (ProductStockModel *)productMode.productStockArray[i];
                AVObject *p_Post = [[AVQuery queryWithClassName:@"ProductStock"] getObjectWithId:model2.ProductStockId];
                [p_Post setObject:[NSNumber numberWithBool:productMode.isDisplay] forKey:@"sale"];
                [p_Post saveInBackground];
                
                model2.isDisplay = productMode.isDisplay;
                [productMode.productStockArray replaceObjectAtIndex:i withObject:model2];
            }
            
            [weakSelf.searchArray replaceObjectAtIndex:idxPath.row withObject:productMode];
            
            [weakSelf.tableView reloadRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        
    }];
    
}

-(void)deleteByIdx:(NSIndexPath *)idxPath {
    
    __weak __typeof(self)weakSelf = self;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    ProductModel *productMode = (ProductModel *)self.searchArray[idxPath.row];
    
    AVQuery *query1 = [AVQuery queryWithClassName:@"ProductCode"];
    [query1 whereKey:@"pcode" equalTo:productMode.productCode];
    [query1 whereKey:@"user" equalTo:[AVUser currentUser]];
    AVObject *obj = [query1 getFirstObject];
    if (obj) {
        [obj deleteInBackground];
    }
    
    if (productMode.sortModel!=nil){
        AVObject *sPost = [[AVQuery queryWithClassName:@"Sort"] getObjectWithId:productMode.sortModel.sortId];
        [sPost incrementKey:@"productCount" byAmount:[NSNumber numberWithInt:-1]];
        [sPost saveInBackground];
    }
    
    if (productMode.materialModel!=nil){
        AVObject *mPost = [[AVQuery queryWithClassName:@"Material"] getObjectWithId:productMode.materialModel.materialId];
        [mPost incrementKey:@"productCount" byAmount:[NSNumber numberWithInt:-1]];
        [mPost saveInBackground];
    }
    
    if (productMode.productStockArray.count>0) {
        for (int i=0; i<productMode.productStockArray.count; i++) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                ProductStockModel *model = (ProductStockModel *)productMode.productStockArray[i];
                AVObject *p_post = [[AVQuery queryWithClassName:@"ProductStock"] getObjectWithId:model.ProductStockId];
                
                AVObject *c_post = [[AVQuery queryWithClassName:@"Color"] getObjectWithId:model.colorModel.colorId];
                [c_post incrementKey:@"productCount" byAmount:[NSNumber numberWithInt:-1]];
                [c_post saveEventually];
                
                AVFile *attachment = [p_post objectForKey:@"header"];
                if (attachment != nil) {
                    [attachment deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [p_post deleteInBackground];
                    }];
                }
            });
        }
    }
    
    AVObject *mPost = [[AVQuery queryWithClassName:@"Product"] getObjectWithId:productMode.productId];
    [mPost deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        if (!error) {
            [weakSelf.searchArray removeObjectAtIndex:idxPath.row];
            
            [weakSelf.tableView reloadData];
        }
    }];
}

@end
