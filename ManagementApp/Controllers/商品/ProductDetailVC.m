//
//  ProductDetailVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/23.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ProductDetailVC.h"
#import "ProductDetailHeader.h"
#import "ProductVC.h"

#import "ProductDetailCell.h"

@interface ProductDetailVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) NSMutableArray *dataArray1;
@property (nonatomic, strong) NSMutableArray *dataArray2;
@property (nonatomic, strong) NSMutableArray *dataArray3;

//-------------当为客户的时候分页---------------------------------------
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

@implementation ProductDetailVC
-(void)dealloc {
    SafeRelease(_tableView);
}
#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.index = 0;
    [self setNavBarView];
    
    //集成刷新控件
    [self addHeader];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    if (!self.view.window){
        SafeRelease(_tableView);
        self.view=nil;
    }
}

#pragma mark - UI

-(void)setNavBarView {
    
    //左侧名称显示的分类名称
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.navBarView setRightWithArray:@[SetTitle(@"product_edit")] type:1];
    [self.navBarView setTitle:SetTitle(@"detail") image:nil];
    [self.view addSubview:self.navBarView];
    
    [self setTableViewUI];
}

-(void)setTableViewUI {
    self.tableView = [[UITableView alloc]initWithFrame:(CGRect){0,self.navBarView.bottom,self.view.width,self.view.height-self.navBarView.bottom} style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [Utility setExtraCellLineHidden:self.tableView];
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[ProductDetailHeader class] forHeaderFooterViewReuseIdentifier:@"ProductDetailHeader"];
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
    } dateKey:@"ProductDetailVC"];
}

- (void)addFooter {
    __weak __typeof(self)weakSelf = self;
    [self.tableView addFooterWithCallback:^{
        weakSelf.start += weakSelf.limit;
        if (weakSelf.dataArray2.count>0) {
            //            ProductModel *proObj = (ProductModel *)[weakSelf.dataArray lastObject];
            //            weakSelf.lastProductId = proObj.productId;
        }
        weakSelf.isLoadingMore = YES;
        [weakSelf getDataFromSever];
    }];
}

#pragma mark - getter/setter

-(NSMutableArray *)dataArray1 {
    if (!_dataArray1) {
        _dataArray1 = [[NSMutableArray alloc]init];
    }
    return _dataArray1;
}
-(NSMutableArray *)dataArray2 {
    if (!_dataArray2) {
        _dataArray2 = [[NSMutableArray alloc]init];
    }
    return _dataArray2;
}
-(NSMutableArray *)dataArray3 {
    if (!_dataArray3) {
        _dataArray3 = [[NSMutableArray alloc]init];
    }
    return _dataArray3;
}

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    ProductVC *proVC = [[ProductVC alloc]init];
    proVC.productModel = self.productModel;
    [self.navigationController pushViewController:proVC animated:YES];
    SafeRelease(proVC);
}

#pragma mark -

#pragma mark - table代理

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [ProductDetailHeader returnHeightWithProductModel:self.productModel];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ProductDetailHeader *header = (ProductDetailHeader*)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ProductDetailHeader"];
    header.productModel = self.productModel;
    header.selectedIndex = self.index;
    
    __weak __typeof(self)weakSelf = self;
    header.segmentChange = ^(NSInteger index){
        weakSelf.index = index;
        [weakSelf.tableView reloadData];
    };
    header.showProfit = ^(ProductModel *productModel){
        
    };
    

    return header;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * identifier = @"product_cell";
    
    ProductDetailCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[ProductDetailCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.productModel = self.productModel;
    cell.selectedIndex = self.index;
    
    
    return cell;
}

//去掉UItableview headerview黏性(sticky)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        CGFloat sectionHeaderHeight = [ProductDetailHeader returnHeightWithProductModel:self.productModel]-80;
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
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

@end
