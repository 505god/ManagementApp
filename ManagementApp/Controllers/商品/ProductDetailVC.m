//
//  ProductDetailVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/v/23.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ProductDetailVC.h"
#import "ProductDetailHeader.h"
#import "ProductVC.h"

#import "ProductDetailCell.h"
#import "OrderStockModel.h"

@interface ProductDetailVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) NSMutableArray *dataArray;

//-------------当为客户的时候分页---------------------------------------
///当前页开始索引
@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) BOOL isLoadingMore;

@end

@implementation ProductDetailVC
-(void)dealloc {
    SafeRelease(_tableView);
    SafeRelease(_dataArray);
}
#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.index = 0;
    [self setNavBarView];
    
    //集成刷新控件
    [self addHeader];
    
    [self.tableView.mj_header beginRefreshing];
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
    self.tableView = [[UITableView alloc]initWithFrame:(CGRect){0,self.navBarView.bottom,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height-self.navBarView.bottom} style:UITableViewStylePlain];
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


#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    if ([Utility isAuthority]) {
        ProductVC *proVC = [[ProductVC alloc]init];
        proVC.isEditing = YES;
        proVC.productModel = self.productModel;
        [self.navigationController pushViewController:proVC animated:YES];
        SafeRelease(proVC);
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
    
    if (self.index==0 || self.index==1) {
        return self.dataArray.count;
    }
    return self.productModel.productStockArray.count==0?0:(self.productModel.productStockArray.count+1);
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.index==0 || self.index==1) {
        return 44;
    }
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * identifier = @"product_cell";
    
    ProductDetailCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[ProductDetailCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.selectedIndex = self.index;
    cell.idxPath = indexPath;
    
    if (self.index==0 || self.index==1) {
        cell.orderStockModel = self.dataArray[indexPath.row];
    }else {
        cell.productModel = self.productModel;
        
        if (indexPath.row>0) {
            cell.productStockModel = (ProductStockModel *)self.productModel.productStockArray[(indexPath.row-1)];
        }
    }
    
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
    __weak __typeof(self)weakSelf = self;

    AVQuery *query = [AVQuery queryWithClassName:@"OrderStock"];
    query.cachePolicy = kAVCachePolicyNetworkElseCache;
    query.maxCacheAge = 24*3600;
    query.limit = 15;
    query.skip = 15*self.start;
    [query orderByDescending:@"updatedAt"];
    [query whereKey:@"user" equalTo:[AVUser currentUser]];
    [query whereKey:@"pcode" equalTo:self.productModel.productCode];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        
        if (!error) {
            if (!weakSelf.isLoadingMore) {
                weakSelf.dataArray = nil;
            }
            [weakSelf.tableView.mj_footer setHidden:YES];
            if (objects.count==15) {
                [weakSelf addFooter];
            }
            
            for (int i=0; i<objects.count; i++) {
                AVObject *object = objects[i];
                
                OrderStockModel *model = [[OrderStockModel alloc]init];
                model.orderStockId = object.objectId;
                model.creat = object.createdAt;
                
                NSDictionary *dic =(NSDictionary *)[object objectForKey:@"localData"];
                [model mts_setValuesForKeysWithDictionary:dic];
                
                [weakSelf.dataArray addObject:model];
            }
            [weakSelf.tableView reloadData];
        }else {
            [PopView showWithImageName:@"error" message:SetTitle(@"connect_error")];
        }
    }];
}

@end
