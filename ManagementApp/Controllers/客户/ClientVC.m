//
//  ClientVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ClientVC.h"
#import "SortVC.h"

#import "AddClientVC.h"

#import "ClientModel.h"
#import "ClientCell.h"

#import "FilterView.h"
#import "ClientDetailVC.h"

typedef enum FilterType:NSUInteger{
    ClientFilterType_ccreat=0,//最新创建
    ClientFilterType_update=1,//最近更新
    ClientFilterType_maximum=2,//交易金额最高
    ClientFilterType_up=3,//交易次数最多
    ClientFilterType_arrears=4,//欠款最多
} ClientFilterType;

@interface ClientVC ()<UITableViewDelegate,UITableViewDataSource,FilterViewDelegate,FilterViewDataSourece>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;


///当前页开始索引
@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger lastProductId;
///分页基数---默认10
@property (nonatomic, assign) NSInteger limit;
///总页数
@property (nonatomic, assign) NSInteger pageCount;
///加载更多
@property (nonatomic, assign) BOOL isLoadingMore;

@property (nonatomic, weak) IBOutlet UIButton *filterBtn;
@property (nonatomic, strong) FilterView *filterView;
@property (nonatomic, assign) BOOL isShowFilterView;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (nonatomic, assign) ClientFilterType filterType;

///欠款最多的天数选择
@property (weak, nonatomic) IBOutlet UIView *filterDayView;
@property (nonatomic, assign) NSInteger dayType;
@end

@implementation ClientVC

#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
    
    //集成刷新控件
    [self addHeader];
    
    self.type = 1;
    self.filterType = 0;
    self.dayType = 0;
    
    ClientModel *clientModel = [[ClientModel alloc]init];
    clientModel.clientName = @"testtesttest";
    clientModel.clientLevel = 2;
    clientModel.totalPrice = 1293.23;
    clientModel.isPrivate = YES;
    clientModel.clientType = 0;
    
    [self.dataArray addObject:clientModel];
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
//            ProductModel *proObj = (ProductModel *)[weakSelf.dataArray lastObject];
//            weakSelf.lastProductId = proObj.productId;
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

-(FilterView *)filterView {
    if (!_filterView) {
        _filterView = [[FilterView alloc]initWithFrame:(CGRect){0,self.navBarView.bottom,self.view.width,self.view.height-self.navBarView.height} dataSource:self];
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

-(void)setFilterType:(ClientFilterType)filterType {
    _filterType = filterType;
    
    if (filterType==ClientFilterType_arrears) {
        self.dayType = 0;
        self.tableTopConstraint.constant = 64+50+44;
    }else {
        if (self.type==0) {
            self.tableTopConstraint.constant = 64;
        }else {
            self.tableTopConstraint.constant = 64+50;
        }
    }
    
    NSArray *array = @[SetTitle(@"new_creat"),SetTitle(@"new_update"),SetTitle(@"order_maximum"),SetTitle(@"order_up"),SetTitle(@"order_arrears")];
    [self.filterBtn setTitle:array[filterType] forState:UIControlStateNormal];
    
}

-(void)setDayType:(NSInteger)dayType {
    _dayType = dayType;
    
    for (int i=0; i<3; i++) {
        UIButton *btn = (UIButton *)[self.filterDayView viewWithTag:(100+i)];
        if (i==dayType) {
            [btn setTitleColor:COLOR(12, 96, 254, 1) forState:UIControlStateNormal];
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
    
    [Utility setExtraCellLineHidden:self.tableView];
    
    ///欠款最多的天数选择
    NSArray *array = @[[NSString stringWithFormat:@"7 %@",SetTitle(@"day")],[NSString stringWithFormat:@"15 %@",SetTitle(@"day")],[NSString stringWithFormat:@"30 %@",SetTitle(@"day")],SetTitle(@"navicon_all")];
    for (int i=0; i<3; i++) {
        UIButton *btn = (UIButton *)[self.filterDayView viewWithTag:(100+i)];
        [btn setTitle:array[i] forState:UIControlStateNormal];
    }

}

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    SortVC *sortVC = (SortVC *)self.mainVC.drawer.leftViewController;
    sortVC.currentPage = 1;
    [self.mainVC.drawer open];
}

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    if (tag==0) {//添加
        AddClientVC *clientVC = [[AddClientVC alloc]init];
        [self.navigationController pushViewController:clientVC animated:YES];
        SafeRelease(clientVC);
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * identifier = @"ClientVC_cell";
    
    ClientCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[ClientCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    cell.clientModel = self.dataArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ClientDetailVC *detailVC = [[ClientDetailVC alloc]init];
    detailVC.clientModel = self.dataArray[indexPath.row];
    [self.navigationController pushViewController:detailVC animated:YES];
    SafeRelease(detailVC);
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
}
#pragma mark - FilterViewDelegate/FilterViewDataSourece

- (NSInteger)filterView:(FilterView *)filterView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (NSString *)filterView:(FilterView *)filterView titleForBtnAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = @[SetTitle(@"new_creat"),SetTitle(@"new_update"),SetTitle(@"order_maximum"),SetTitle(@"order_up"),SetTitle(@"order_arrears")];
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
