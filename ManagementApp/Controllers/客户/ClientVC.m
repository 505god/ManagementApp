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
#import "ClientSearchVC.h"

typedef enum FilterType:NSUInteger{
    ClientFilterType_ccreat=0,//最新创建
    ClientFilterType_update=1,//最近更新
    ClientFilterType_maximum=2,//交易次数最多
    ClientFilterType_up=3,//交易金额最高
    ClientFilterType_arrears=4,//欠款最多
} ClientFilterType;

@interface ClientVC ()<UITableViewDelegate,UITableViewDataSource,FilterViewDelegate,FilterViewDataSourece>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;


///当前页开始索引
@property (nonatomic, assign) NSInteger start;
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

@property (nonatomic, assign) NSInteger clientType;

@end

@implementation ClientVC
-(void)dealloc {
    SafeRelease(_dataArray);
    SafeRelease(_tableView);
    SafeRelease(_filterBtn);
    SafeRelease(_filterView);
    SafeRelease(_filterDayView);
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
    
    //集成刷新控件
    [self addHeader];
    
    self.type = 1;
    self.filterType = 0;
    self.dayType = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fliterDataWithNotification:) name:@"fliterDataWithNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unreadeMessage:) name:@"unreadeMessage" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

-(void)unreadeMessage:(NSNotification *)notification {
    NSString *name = [notification object];
    
    NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"%K == %@", @"clientName", name];
    NSMutableArray  *filteredArray = [NSMutableArray arrayWithArray:[self.dataArray filteredArrayUsingPredicate:predicateString]];
    
    if (filteredArray.count>0) {
        ClientModel *model = (ClientModel *)[filteredArray firstObject];
        model.redPoint ++;
        NSInteger index = [self.dataArray indexOfObject:model];
        
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(void)fliterDataWithNotification:(NSNotification *)notification {
    self.clientType = [[notification object]integerValue];
    
    if (self.clientType==0) {
        [self.navBarView setLeftWithImage:@"menu_icon" title:SetTitle(@"navicon_all")];
    }else if (self.clientType==1){
        [self.navBarView setLeftWithImage:@"menu_icon" title:@"A"];
    }else if (self.clientType==2){
        [self.navBarView setLeftWithImage:@"menu_icon" title:@"B"];
    }else if (self.clientType==3){
        [self.navBarView setLeftWithImage:@"menu_icon" title:@"C"];
    }else if (self.clientType==4){
        [self.navBarView setLeftWithImage:@"menu_icon" title:@"D"];
    }else if (self.clientType==5){
        [self.navBarView setLeftWithImage:@"menu_icon" title:SetTitle(@"private_client")];
    }else if (self.clientType==6){
        [self.navBarView setLeftWithImage:@"menu_icon" title:SetTitle(@"supplier")];
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self getDataFromSever];
}
#pragma mark - private

- (void)addHeader {
    __weak __typeof(self)weakSelf = self;
    [self.tableView addHeaderWithCallback:^{
        
        weakSelf.start = 0;
        weakSelf.isLoadingMore = NO;
        [weakSelf getDataFromSever];
    } dateKey:@"ClientVC"];
}

- (void)addFooter {
    __weak __typeof(self)weakSelf = self;
    [self.tableView addFooterWithCallback:^{
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
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self getDataFromSever];
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
        ClientSearchVC *vc = LOADVC(@"ClientSearchVC");
        [self.navigationController pushViewController:vc animated:YES];
        vc = nil;
    }
}

#pragma mark -
#pragma mark - 请求数据

-(void)getDataFromSever {
    if ([DataShare sharedService].appDel.isReachable) {
        __weak __typeof(self)weakSelf = self;
        
        AVQuery *query1 = [AVQuery queryWithClassName:@"Client"];
        //查询行为先尝试从网络加载，若加载失败，则从缓存加载结果
        query1.cachePolicy = kAVCachePolicyNetworkElseCache;
        //设置缓存有效期
        query1.maxCacheAge = 24*3600;// 一天的总秒数
        [query1 whereKey:@"user" equalTo:[AVUser currentUser]];
        
        if (self.filterType==ClientFilterType_ccreat) {
            [query1 orderByDescending:@"createdAt"];
        }else if (self.filterType==ClientFilterType_update) {
            [query1 orderByDescending:@"updatedAt"];
        }else if (self.filterType==ClientFilterType_maximum) {
            [query1 orderByDescending:@"tradeNum"];
        }else if (self.filterType==ClientFilterType_up) {
            [query1 orderByDescending:@"totalPrice"];
        }else if (self.filterType==ClientFilterType_arrears) {
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
                [query1 orderByDescending:@"arrearsPrice"];
                [query1 whereKey:@"createdAt" greaterThanOrEqualTo:yesterDay];
            }
        }
        
        if (self.clientType==0) {
        }else if (self.clientType==5) {
            [query1 whereKey:@"clientType" equalTo:@(0)];
            [query1 whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:true]];
        }else if (self.clientType==6) {
            [query1 whereKey:@"clientType" equalTo:@(1)];
        }else {
            [query1 whereKey:@"clientType" equalTo:@(0)];
            [query1 whereKey:@"clientLevel" equalTo:@(self.clientType-1)];
        }
        
        query1.limit = 10;
        query1.skip = 10*self.start;
        
        [query1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
            [weakSelf.tableView headerEndRefreshing];
            [weakSelf.tableView footerEndRefreshing];
            if (!error) {
                if (!weakSelf.isLoadingMore) {
                    weakSelf.dataArray = nil;
                }
                [weakSelf.tableView removeFooter];
                if (objects.count==10) {
                    [weakSelf addFooter];
                }
                for (int i=0; i<objects.count; i++) {
                    AVObject *object = objects[i];
                    
                    NSDictionary *dic =(NSDictionary *)[object objectForKey:@"localData"];
                    
                    ClientModel *model = [[ClientModel alloc]init];
                    [model mts_setValuesForKeysWithDictionary:dic];
                    model.clientId = object.objectId;
                    
                    [weakSelf.dataArray addObject:model];
                    
                    if (model.redPoint>0) {
                        [object incrementKey:@"redPoint" byAmount:[NSNumber numberWithInt:-1]];
                        [object saveInBackground];
                    }
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * identifier = @"ClientVC_cell";
    
    ClientCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[ClientCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    //红点判断
    ClientModel *model = (ClientModel *)self.dataArray[indexPath.row];
    
    NSArray *allkeys = [[DataShare sharedService].unreadMessageDic allKeys];
    if ([allkeys containsObject:model.clientName]) {//包含
        model.redPoint ++;
    }
    
    cell.clientModel = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    __weak __typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        AVObject *post = [[AVQuery queryWithClassName:@"Client"] getObjectWithId:[(ClientModel *)weakSelf.dataArray[indexPath.row] clientId]];
        [post setObject:[NSNumber numberWithInt:0] forKey:@"redPoint"];
        [post saveInBackground];
    });
    
    ClientModel *model = (ClientModel *)self.dataArray[indexPath.row];
    model.redPoint = 0;
    [self.dataArray replaceObjectAtIndex:indexPath.row withObject:model];
    
    ClientDetailVC *detailVC = [[ClientDetailVC alloc]init];
    detailVC.clientModel = model;
    [self.navigationController pushViewController:detailVC animated:YES];
    SafeRelease(detailVC);
}


#pragma mark - action

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
