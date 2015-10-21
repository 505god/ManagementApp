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

@interface StockVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, assign) NSInteger type;

///当前页开始索引
@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger lastProductId;
///分页基数---默认10
@property (nonatomic, assign) NSInteger limit;
///总页数
@property (nonatomic, assign) NSInteger pageCount;
///加载更多
@property (nonatomic, assign) BOOL isLoadingMore;

@end

@implementation StockVC

#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];

    //集成刷新控件
    [self addHeader];
    self.type=1;
    
    ProductModel *model = [[ProductModel alloc]init];
    model.productCode = @"9001";
    
    ProductPriceModel *productPriceModel = [[ProductPriceModel alloc]init];
    productPriceModel.aPrice = 9.99;
    productPriceModel.selected = 0;
    model.productPriceModel = productPriceModel;
    
    model.stockCount = 57;
    
    model.saleCount = 7;
    
    ProductModel *model2 = [[ProductModel alloc]init];
    model2.productCode = @"9001";
    
    ProductPriceModel *productPriceModel2 = [[ProductPriceModel alloc]init];
    productPriceModel2.aPrice = 19.99;
    productPriceModel2.selected = 0;
    model2.productPriceModel = productPriceModel2;
    
    model2.stockCount = 157;
    model2.isHot = YES;
    model2.saleCount = 17;
    
    [self.dataArray addObject:model];
    [self.dataArray addObject:model2];
    
    [self.tableView reloadData];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [self.tableView headerBeginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private

- (void)addHeader {
    __weak __typeof(self)weakSelf = self;
    [self.tableView addHeaderWithCallback:^{
        
        weakSelf.start = 0;
        weakSelf.lastProductId = 0;
        weakSelf.pageCount = -1;
        weakSelf.isLoadingMore = NO;
        [weakSelf.tableView removeFooter];
        
        [weakSelf getDataFromSever];
    } dateKey:@"StockVC"];
}

- (void)addFooter {
    __weak __typeof(self)weakSelf = self;
    [self.tableView addFooterWithCallback:^{
        weakSelf.start += weakSelf.limit;
        if (weakSelf.dataArray.count>0) {
            ProductModel *proObj = (ProductModel *)[weakSelf.dataArray lastObject];
            weakSelf.lastProductId = proObj.productId;
        }
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


#pragma mark - UI

-(void)setNavBarView {
    
    //左侧名称显示的分类名称
    [self.navBarView setLeftWithImage:@"menu_icon" title:SetTitle(@"navicon_all")];
    [self.navBarView setRightWithArray:@[@"add_bt",@"search_icon"]];
    [self.view addSubview:self.navBarView];
    
     [self.tableView registerClass:[ProductHeader class] forHeaderFooterViewReuseIdentifier:@"ProductHeader"];
}

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    SortVC *sortVC = (SortVC *)self.mainVC.drawer.leftViewController;
    sortVC.currentPage = 0;
    
    [self.mainVC.drawer open];
}

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    if (tag==0) {//添加
        ProductVC *productVC = [[ProductVC alloc]init];
        [self.navigationController pushViewController:productVC animated:YES];
    }else if(tag==1){//搜索
        
    }
}
#pragma mark -
#pragma mark - 请求数据

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
            NSDictionary *aDic = [jsonData objectForKey:@"returnObj"];
            NSInteger proNumber = [[aDic objectForKey:@"totalProduct"]integerValue];
            if (strongSelf.pageCount<0) {
                strongSelf.pageCount = proNumber;
            }
            
            if ((strongSelf.start+strongSelf.limit)<strongSelf.pageCount) {
                if (strongSelf.isLoadingMore == NO) {
                    [strongSelf addFooter];
                }
            }else {
                [strongSelf.tableView removeFooter];
            }
            
        }else {
            strongSelf.start = (strongSelf.start-strongSelf.limit)<0?0:strongSelf.start-strongSelf.limit;
            [Utility interfaceWithStatus:[jsonData[@"status"] integerValue] msg:jsonData[@"msg"]];
        }
        
        [strongSelf.tableView headerEndRefreshing];
        [strongSelf.tableView footerEndRefreshing];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf.start = (strongSelf.start-strongSelf.limit)<0?0:strongSelf.start-strongSelf.limit;
        [strongSelf.tableView headerEndRefreshing];
        [strongSelf.tableView footerEndRefreshing];
        
        [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
        
        [PopView showWithImageName:@"error" message:SetTitle(@"connect_error")];
    }];
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
}

#pragma mark -
#pragma mark - 热卖、上架、删除

-(void)hotByProduct:(ProductModel *)productMode idx:(NSIndexPath *)idxPath {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak __typeof(self)weakSelf = self;
    [[APIClient sharedClient] POST:@"" parameters:@{} success:^(NSURLSessionDataTask *task, id responseObject) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
        
        NSDictionary *jsonData=(NSDictionary *)responseObject;
        
        if ([[jsonData objectForKey:@"status"]integerValue]==1) {
            
            productMode.isHot = !productMode.isHot;
            [strongSelf.dataArray replaceObjectAtIndex:idxPath.row withObject:productMode];
            [strongSelf.tableView reloadRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationNone];
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

-(void)saleByProduct:(ProductModel *)productMode idx:(NSIndexPath *)idxPath {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak __typeof(self)weakSelf = self;
    [[APIClient sharedClient] POST:@"" parameters:@{} success:^(NSURLSessionDataTask *task, id responseObject) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
        
        NSDictionary *jsonData=(NSDictionary *)responseObject;
        
        if ([[jsonData objectForKey:@"status"]integerValue]==1) {
            
            
            productMode.isDisplay = !productMode.isDisplay;
            [strongSelf.dataArray replaceObjectAtIndex:idxPath.row withObject:productMode];
            
            [strongSelf.tableView reloadRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationNone];
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

-(void)deleteByIdx:(NSIndexPath *)idxPath {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak __typeof(self)weakSelf = self;
    [[APIClient sharedClient] POST:@"" parameters:@{} success:^(NSURLSessionDataTask *task, id responseObject) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
        
        NSDictionary *jsonData=(NSDictionary *)responseObject;
        
        if ([[jsonData objectForKey:@"status"]integerValue]==1) {
            
            [strongSelf.dataArray removeObjectAtIndex:idxPath.row];
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

@end
