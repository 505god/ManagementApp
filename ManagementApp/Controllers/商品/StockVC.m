//
//  StockVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "StockVC.h"
#import "SortVC.h"

#import "ProductVC.h"

#import "ProductCell.h"
#import "ProductModel.h"

#import "ProductHeader.h"
#import "ProductDetailVC.h"
#import "ProductSearchVC.h"
#import "FilterView.h"

typedef enum FilterType:NSUInteger{
    ProductFilterType_code=0,//货号A-Z
    ProductFilterType_ccreat=1,//最新创建
    ProductFilterType_update=2,//最近更新
    ProductFilterType_best_sell=3,//最好卖
    ProductFilterType_worst_sell=4,//30天内最不好卖
    ProductFilterType_stock_up=5,//库存最多
    ProductFilterType_stock_down=6,//库存最少
} ProductFilterType;

@interface StockVC ()<UITableViewDelegate,UITableViewDataSource,FilterViewDelegate,FilterViewDataSourece>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArray;

///当前页开始索引
@property (nonatomic, assign) NSInteger start;
///加载更多
@property (nonatomic, assign) BOOL isLoadingMore;

///筛选
@property (nonatomic, weak) IBOutlet UIButton *filterBtn;
@property (nonatomic, strong) FilterView *filterView;
@property (nonatomic, assign) BOOL isShowFilterView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableTopConstraint;

///最好卖的天数选择
@property (weak, nonatomic) IBOutlet UIView *filterDayView;
@property (nonatomic, assign) NSInteger dayType;

@property (nonatomic, assign) NSInteger productType;
@property (nonatomic, strong) SortModel *filterModel;

@property (nonatomic, assign) ProductFilterType filterType;
@end

@implementation StockVC

#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.productType = 1;
    [self setNavBarView];

    //集成刷新控件
    [self addHeader];

    self.type=1;
    self.filterType = 0;
    self.dayType = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fliterProductDataWithNotification:) name:@"fliterProductDataWithNotification" object:nil];
}

-(void)fliterProductDataWithNotification:(NSNotification *)notification {
    id object = [notification object];
    
    if ([object isKindOfClass:[NSString class]]) {
        self.productType = [[notification object]integerValue];
        
        if (self.productType==0) {
            [self.navBarView setLeftWithImage:@"menu_icon" title:SetTitle(@"stock_warning")];
        }else if (self.productType==1) {
            [self.navBarView setLeftWithImage:@"menu_icon" title:SetTitle(@"navicon_all")];
        }else if (self.productType==2) {
            [self.navBarView setLeftWithImage:@"menu_icon" title:SetTitle(@"not_classified")];
        }else if (self.productType==-2) {
            [self.navBarView setLeftWithImage:@"menu_icon" title:SetTitle(@"off_the_shelf")];
        }else if (self.productType==-1) {
            [self.navBarView setLeftWithImage:@"menu_icon" title:SetTitle(@"best_sellers")];
        }
    }else if ([object isKindOfClass:[NSArray class]]) {
        NSArray *array = [notification object];
        
        self.productType = [array[0] integerValue];
        self.filterModel = (SortModel *)array[1];
        
        [self.navBarView setLeftWithImage:@"menu_icon" title:self.filterModel.sortName];
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self getDataFromSever];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private

- (void)addHeader {
    __weak __typeof(self)weakSelf = self;
    self.tableView.mj_header = [LCCKConversationRefreshHeader headerWithRefreshingBlock:^{
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

#pragma mark - getter/setter

-(NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}

-(FilterView *)filterView {
    if (!_filterView) {
        _filterView = [[FilterView alloc]initWithFrame:(CGRect){0,self.navBarView.bottom,[UIScreen mainScreen].bounds.size.width,self.view.height-self.navBarView.height} dataSource:self];
        _filterView.delegate=self;
        [self.view addSubview:_filterView];
    }
    return _filterView;
}

-(void)setType:(NSInteger)type {
    _type = type;
    
    if (type==1) {
        self.tableTopConstraint.constant = 64+50;
    }else {
        self.tableTopConstraint.constant = 64;
    }
}

-(void)setFilterType:(ProductFilterType)filterType {
    _filterType = filterType;
    
    if (filterType==ProductFilterType_best_sell) {
        self.dayType = 0;
        self.tableTopConstraint.constant = 64+50+44;
    }else {
        if (self.type==0) {
            self.tableTopConstraint.constant = 64;
        }else {
            self.tableTopConstraint.constant = 64+50;
        }
    }
    
    NSArray *array = @[SetTitle(@"order_code"),SetTitle(@"new_creat"),SetTitle(@"new_update"),SetTitle(@"order_best_sell"),SetTitle(@"order_worst_sell"),SetTitle(@"order_stock_up"),SetTitle(@"order_stock_down")];
    [self.filterBtn setTitle:array[filterType] forState:UIControlStateNormal];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self getDataFromSever];
}

-(void)setDayType:(NSInteger)dayType {
    _dayType = dayType;
    
    for (int i=0; i<4; i++) {
        UIButton *btn = (UIButton *)[self.filterDayView viewWithTag:(100+i)];
        if (i==dayType) {
            [btn setTitleColor:kThemeColor forState:UIControlStateNormal];
        }else {
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - UI

-(void)setNavBarView {
    
    //左侧名称显示的分类名称
    [self.navBarView setLeftWithImage:@"menu_icon" title:SetTitle(@"navicon_all")];
    [self.navBarView setRightWithArray:@[@"add_bt",@"search_icon"] type:0];
    [self.view addSubview:self.navBarView];
    
     [self.tableView registerClass:[ProductHeader class] forHeaderFooterViewReuseIdentifier:@"ProductHeader"];
    
    ///最好卖的天数选择
    NSArray *array = @[[NSString stringWithFormat:@"7 %@",SetTitle(@"day")],[NSString stringWithFormat:@"15 %@",SetTitle(@"day")],[NSString stringWithFormat:@"30 %@",SetTitle(@"day")],SetTitle(@"navicon_all")];
    for (int i=0; i<4; i++) {
        UIButton *btn = (UIButton *)[self.filterDayView viewWithTag:(100+i)];
        [btn setTitle:array[i] forState:UIControlStateNormal];
    }
}

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    SortVC *sortVC = (SortVC *)self.mainVC.drawer.leftViewController;
    sortVC.currentPage = 0;
    
    [self.mainVC.drawer open];
}

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    
    if (tag==0) {//添加
        
        if ([Utility isAuthority]) {
            ProductVC *productVC = [[ProductVC alloc]init];
            QWeakSelf(self);
            productVC.addHandler = ^(){
                [weakself.tableView.mj_header beginRefreshing];
            };
            [self.navigationController pushViewController:productVC animated:YES];
            SafeRelease(productVC);
        }else {
//            QWeakSelf(self);
//            UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"authority_tip") message:SetTitle(@"authority_error") preferredStyle:UIAlertControllerStyleAlert];
//            [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
//                
//                AuthorityVC *vc = LOADVC(@"AuthorityVC");
//                [weakself.navigationController pushViewController:vc animated:YES];
//            }];
//            [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
//            [self presentViewController:alert animated:YES completion:nil];
        }
    }else if(tag==1){//搜索
        ProductSearchVC *vc = LOADVC(@"ProductSearchVC");
        [self.navigationController pushViewController:vc animated:YES];
        vc = nil;
    }
}
#pragma mark -
#pragma mark - 请求数据

-(void)getDataFromSever {
    if ([DataShare sharedService].appDel.isReachable) {
        __weak __typeof(self)weakSelf = self;
        
        AVQuery *query1 = [AVQuery queryWithClassName:@"Product"];
        query1.cachePolicy = kAVCachePolicyNetworkElseCache;
        query1.maxCacheAge = 24*3600;// 一天的总秒数
        [query1 whereKey:@"user" equalTo:[AVUser currentUser]];
        
        if (self.filterType==ProductFilterType_code) {
            [query1 addAscendingOrder:@"productCode"];
        }else if (self.filterType==ProductFilterType_ccreat) {
            [query1 orderByDescending:@"createdAt"];
        }else if (self.filterType==ProductFilterType_update) {
            [query1 orderByDescending:@"updatedAt"];
        }else if (self.filterType==ProductFilterType_best_sell) {
            //根据已有日期创建日期
            if (self.dayType != 3) {
                NSDate *yesterDay;
                if (self.dayType==0) {
                    yesterDay = [NSDate returnDay:7];
                }else if (self.dayType==1) {
                    yesterDay = [NSDate returnDay:15];
                }else if (self.dayType==2) {
                    yesterDay = [NSDate returnDay:30];
                }
                [query1 orderByDescending:@"saleNum"];
                [query1 whereKey:@"updatedAt" greaterThanOrEqualTo:yesterDay];
            }else {
                [query1 orderByDescending:@"saleNum"];
            }
        }else if (self.filterType==ProductFilterType_worst_sell) {
            NSDate *yesterDay = [NSDate returnDay:30];
            [query1 orderByAscending:@"saleNum"];
            [query1 whereKey:@"updatedAt" greaterThanOrEqualTo:yesterDay];
        }else if (self.filterType==ProductFilterType_stock_up) {
            [query1 orderByDescending:@"stockNum"];
        }else if (self.filterType==ProductFilterType_stock_down) {
            [query1 orderByAscending:@"stockNum"];
        }
        
        if (self.productType==0) {
            [query1 whereKey:@"isWarning" equalTo:[NSNumber numberWithBool:true]];
        }else if (self.productType==1) {
        }else if (self.productType==2) {
            [query1 whereKeyDoesNotExist:@"sort"];
        }else if (self.productType==-1) {
            [query1 whereKey:@"hot" equalTo:[NSNumber numberWithBool:true]];
        }else if (self.productType==-2) {
            [query1 whereKey:@"sale" equalTo:[NSNumber numberWithBool:false]];
        }else if (self.productType==-100) {
            AVObject *post = [[AVQuery queryWithClassName:@"Sort"] getObjectWithId:weakSelf.filterModel.sortId];
            if (post != nil) {
                [query1 whereKey:@"sort" equalTo:post];
            }
        }
        
        query1.limit = 10;
        query1.skip = 10*self.start;
        
        [query1 includeKey:@"sort"];
        [query1 includeKey:@"material"];
        [query1 includeKey:@"products"];
        
        [query1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.tableView.mj_footer endRefreshing];
            if (!error) {
                if (!weakSelf.isLoadingMore) {
                    weakSelf.dataArray = nil;
                }
                [weakSelf.tableView.mj_footer setHidden:YES];
                if (objects.count==10) {
                    [weakSelf addFooter];
                }
                
                for (int i=0; i<objects.count; i++) {
                    AVObject *object = objects[i];
                    
                    ProductModel *model = [ProductModel initWithObject:object];
                    [weakSelf.dataArray addObject:model];
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
    header.type = self.type;
    return header;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * identifier = @"product_cell";
    
    ProductCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[ProductCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier type:self.type inTableView:self.tableView];
    }
    
    cell.idxPath = indexPath;
    cell.productModel = self.dataArray[indexPath.row];

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
    detailVC.productModel = self.dataArray[indexPath.row];
    [self.navigationController pushViewController:detailVC animated:YES];
    SafeRelease(detailVC);
}

#pragma mark -
#pragma mark - 热卖、上架、删除

-(void)hotByProduct:(ProductModel *)productMode idx:(NSIndexPath *)idxPath {
    if ([Utility isAuthority]) {
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
                
                [weakSelf.dataArray replaceObjectAtIndex:idxPath.row withObject:productMode];
                
                [weakSelf.tableView reloadRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            
        }];
    }else {
//        QWeakSelf(self);
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"authority_tip") message:SetTitle(@"authority_error") preferredStyle:UIAlertControllerStyleAlert];
//        [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
//            
//            AuthorityVC *vc = LOADVC(@"AuthorityVC");
//            [weakself.navigationController pushViewController:vc animated:YES];
//        }];
//        [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
//        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)saleByProduct:(ProductModel *)productMode idx:(NSIndexPath *)idxPath {
    if ([Utility isAuthority]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        __weak __typeof(self)weakSelf = self;
        
        AVObject *mPost = [[AVQuery queryWithClassName:@"Product"] getObjectWithId:productMode.productId];
        [mPost setObject:[NSNumber numberWithBool:!productMode.isDisplay] forKey:@"sale"];
        [mPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
            
            //分类
            if ([Utility checkString:productMode.sortId]) {
                AVObject *sPost = [[AVQuery queryWithClassName:@"Sort"] getObjectWithId:productMode.sortId];
                if (productMode.isDisplay) {//下架
                    [sPost incrementKey:@"sale"];
                }else {
                    [sPost incrementKey:@"sale" byAmount:[NSNumber numberWithInteger:-1]];
                }
                [sPost saveInBackground];
            }
            
            if ([Utility checkString:productMode.materialId]) {
                AVObject *mPost = [[AVQuery queryWithClassName:@"Material"] getObjectWithId:productMode.materialId];
                if (productMode.isDisplay) {
                    [mPost incrementKey:@"sale"];
                }else {
                    [mPost incrementKey:@"sale" byAmount:[NSNumber numberWithInteger:-1]];
                }
                [mPost saveInBackground];
            }
            if (!error) {
                productMode.isDisplay = !productMode.isDisplay;
                
                for (int i=0; i<productMode.productStockArray.count; i++) {
                    ProductStockModel *model2 = (ProductStockModel *)productMode.productStockArray[i];
                    AVObject *p_Post = [[AVQuery queryWithClassName:@"ProductStock"] getObjectWithId:model2.ProductStockId];
                    [p_Post setObject:[NSNumber numberWithBool:productMode.isDisplay] forKey:@"sale"];
                    [p_Post saveInBackground];
                    
                    if ([Utility checkString:model2.colorModel.colorId]) {
                        AVObject *cPost = [[AVQuery queryWithClassName:@"Color"] getObjectWithId:model2.colorModel.colorId];
                        if (productMode.isDisplay) {
                            [cPost incrementKey:@"sale" byAmount:[NSNumber numberWithInteger:-1]];
                        }else {
                            [cPost incrementKey:@"sale"];
                        }
                        [cPost saveInBackground];
                    }
                    
                    
                    model2.isDisplay = productMode.isDisplay;
                    [productMode.productStockArray replaceObjectAtIndex:i withObject:model2];
                }
                
                [weakSelf.dataArray replaceObjectAtIndex:idxPath.row withObject:productMode];
                
                [weakSelf.tableView reloadRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            
        }];
    }else {
//        QWeakSelf(self);
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"authority_tip") message:SetTitle(@"authority_error") preferredStyle:UIAlertControllerStyleAlert];
//        [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
//            
//            AuthorityVC *vc = LOADVC(@"AuthorityVC");
//            [weakself.navigationController pushViewController:vc animated:YES];
//        }];
//        [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
//        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)deleteByIdx:(NSIndexPath *)idxPath {
    
    if ([Utility isAuthority]) {
        __weak __typeof(self)weakSelf = self;
        
        ProductModel *productMode = (ProductModel *)self.dataArray[idxPath.row];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"ConfirmDelete") message:[NSString stringWithFormat:@"%@:%@",SetTitle(@"product_code"),productMode.productCode] preferredStyle:UIAlertControllerStyleAlert];
        [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
            
            [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
            
            AVQuery *query1 = [AVQuery queryWithClassName:@"Statistics"];
            [query1 whereKey:@"user" equalTo:[AVUser currentUser]];
            AVObject *statistics_post = [query1 getFirstObject];
            [statistics_post incrementKey:@"totalStock" byAmount:[NSNumber numberWithInt:(int)(0-productMode.stockCount)]];
            [statistics_post incrementKey:@"totalMoney" byAmount:[NSNumber numberWithFloat:0-productMode.stockCount *productMode.purchaseprice]];
            [statistics_post saveInBackground];

            AVQuery *query2 = [AVQuery queryWithClassName:@"ProductCode"];
            [query2 whereKey:@"user" equalTo:[AVUser currentUser]];
            [query2 whereKey:@"pcode" equalTo:productMode.productCode];
            AVObject *obj = [query2 getFirstObject];
            if (obj) {
                [obj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    NSLog(@"22");
                }];
            }
            
            if (productMode.sortModel!=nil){
                AVObject *sPost = [AVObject objectWithClassName:@"Sort" objectId:productMode.sortModel.sortId];
                [sPost incrementKey:@"productCount" byAmount:[NSNumber numberWithInt:-1]];
                [sPost saveInBackground];
            }
            
            if (productMode.materialModel!=nil){
                AVObject *mPost = [AVObject objectWithClassName:@"Material" objectId:productMode.materialModel.materialId];;
                [mPost incrementKey:@"productCount" byAmount:[NSNumber numberWithInt:-1]];
                [mPost saveInBackground];
            }
            
            if (productMode.productStockArray.count>0) {
                for (int i=0; i<productMode.productStockArray.count; i++) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        ProductStockModel *model = (ProductStockModel *)productMode.productStockArray[i];
                        AVObject *p_post = [AVObject objectWithClassName:@"ProductStock" objectId:model.ProductStockId];
                        
                        AVObject *c_post = [AVObject objectWithClassName:@"Color" objectId:model.colorModel.colorId];
                        [c_post incrementKey:@"productCount" byAmount:[NSNumber numberWithInt:-1]];
                        [c_post saveInBackground];
                        
                        AVFile *attachment = [p_post objectForKey:@"header"];
                        if (attachment != nil) {
                            [attachment deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                [p_post deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                    NSLog(@"111");
                                }];
                            }];
                        }else {
                            [p_post deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                NSLog(@"111");
                            }];
                        }
                    });
                }
            }
            
            AVObject *mPost = [AVObject objectWithClassName:@"Product" objectId:productMode.productId];
            [mPost deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                
                if (!error) {
                    [weakSelf.dataArray removeObjectAtIndex:idxPath.row];
                    
                    [weakSelf.tableView reloadData];
                }
            }];
            
        }];
        [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
        [self presentViewController:alert animated:YES completion:nil];
    }else {
//        QWeakSelf(self);
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"authority_tip") message:SetTitle(@"authority_error") preferredStyle:UIAlertControllerStyleAlert];
//        [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
//            
//            AuthorityVC *vc = LOADVC(@"AuthorityVC");
//            [weakself.navigationController pushViewController:vc animated:YES];
//        }];
//        [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
//        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark -

-(IBAction)filterBtnPressed:(id)sender {
    [self.filterView reloadData];
    [self.filterView show];
    self.isShowFilterView = YES;
    [self.view bringSubviewToFront:self.filterView];
}

-(IBAction)dayFilterBtnPressed:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    if ((btn.tag-100)==self.dayType) {
        return;
    }else {
        self.dayType = btn.tag-100;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self getDataFromSever];
}

#pragma mark - FilterViewDelegate/FilterViewDataSourece

- (NSInteger)filterView:(FilterView *)filterView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (NSString *)filterView:(FilterView *)filterView titleForBtnAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = @[SetTitle(@"order_code"),SetTitle(@"new_creat"),SetTitle(@"new_update"),SetTitle(@"order_best_sell"),SetTitle(@"order_worst_sell"),SetTitle(@"order_stock_up"),SetTitle(@"order_stock_down")];
    return array[indexPath.row];
}

- (NSInteger)filterView:(FilterView *)filterView selectedIndexInSection:(NSInteger)section {
    return self.filterType;
}

- (void)filterView:(FilterView *)filterView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.filterType = indexPath.row;
    [self.filterView hide];
}

- (void)filterHide {
    self.isShowFilterView = NO;
}


@end
