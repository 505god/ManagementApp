//
//  OrderVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "OrderVC.h"
#import "OrderHeaderView.h"
#import "OrderCell.h"
#import "OrderFilterView.h"
#import "OrderDetailVC.h"
#import "OrderStatisticVC.h"

@interface OrderVC ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSMutableArray *headerArray;

@property (nonatomic, strong) UITableView *tableView;

//筛选
@property (nonatomic, assign) OrderFilterType orderType;//一级
@property (nonatomic, assign) NSInteger type;//二级
@property (nonatomic, copy) NSString *time;

@property (nonatomic, strong) NSArray *filterNameArray;

@property (nonatomic, strong) OrderFilterView *filterView;
@property (nonatomic, assign) BOOL isFilterOpen;


@end

NSString *const cellIdentifier=@"OrderCell";

@implementation OrderVC


-(void)dealloc {
    SafeRelease(_dataArray);
}
#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
    
    //集成刷新控件
    [self addHeader];
    
    self.filterNameArray = @[@[SetTitle(@"Today"),SetTitle(@"Yesterday"),SetTitle(@"week"),SetTitle(@"month"),SetTitle(@"latest_month"),SetTitle(@"select_date")],@[SetTitle(@"pay_none"),SetTitle(@"pay_part"),SetTitle(@"pay_all"),SetTitle(@"deliver_none"),SetTitle(@"deliver_part"),SetTitle(@"deliver_all")]];
    
    self.orderType = 0;
    self.type = 0;
    
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - private

- (void)addHeader {
    __weak __typeof(self)weakSelf = self;
    self.tableView.mj_header = [LCCKConversationRefreshHeader headerWithRefreshingBlock:^{
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

-(NSMutableArray *)headerArray {
    if (!_headerArray) {
        _headerArray = [[NSMutableArray alloc]init];
    }
    return _headerArray;
}

-(void)setType:(NSInteger)type {
    _type = type;
    
     [self.navBarView setLeftWithImage:@"sort_icon" title:[NSString stringWithFormat:@"%@",self.filterNameArray[self.orderType][self.type]]];
}

-(OrderFilterView *)filterView {
    if (!_filterView) {
        _filterView = [[OrderFilterView alloc]initWithFrame:(CGRect){0,self.navBarView.bottom,[UIScreen mainScreen].bounds.size.width,0} orderType:self.orderType type:self.type filterArray:nil];
        
        __weak __typeof(self)weakSelf = self;
        _filterView.completedBlock = ^(NSInteger orderType,NSInteger type,NSString *time,BOOL finished){
            weakSelf.orderType = orderType;
            weakSelf.type = type;
            weakSelf.time = time;
            
            [weakSelf hiddenFilterView:finished];
        };
        [self.view addSubview:_filterView];
    }
    return _filterView;
}


#pragma mark - action

-(void)hiddenFilterView:(BOOL)animated {
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.25f animations:^{
        weakSelf.filterView.frame = (CGRect){0,weakSelf.navBarView.bottom,[UIScreen mainScreen].bounds.size.width,0};
        weakSelf.isFilterOpen = NO;
        
        weakSelf.filterView.isShow = NO;
        weakSelf.filterView.customView.hidden = YES;
    }completion:^(BOOL finished) {
        ///请求订单列表
        if (animated) {
            [weakSelf getDataFromSever];
        }
    }];
}

#pragma mark - UI

-(void)setNavBarView {
    
    [self.navBarView setLeftWithImage:@"sort_icon" title:[NSString stringWithFormat:@"%@ • 0",SetTitle(@"Today")]];
    [self.navBarView setRightWithArray:@[@"navicon_more"] type:0];
    [self.view addSubview:self.navBarView];
    
    self.tableView = [[UITableView alloc]initWithFrame:(CGRect){0,self.navBarView.bottom,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height-self.navBarView.bottom-TabbarHeight} style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[OrderHeaderView class] forHeaderFooterViewReuseIdentifier:@"OrderHeaderView"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"OrderCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    [Utility setExtraCellLineHidden:self.tableView];
}

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView{
    __weak __typeof(self)weakSelf = self;
    
    if (self.isFilterOpen) {
        [self hiddenFilterView:NO];
        
        self.filterView.isShow = NO;
        self.filterView.customView.hidden = YES;
    }else {
        [self.view bringSubviewToFront:self.filterView];
        [UIView animateWithDuration:0.25f animations:^{
            weakSelf.filterView.frame = (CGRect){0,weakSelf.navBarView.bottom,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height-weakSelf.navBarView.height-TabbarHeight};
            weakSelf.isFilterOpen = YES;
        }];
    }
}

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    OrderStatisticVC *vc = [[OrderStatisticVC alloc]init];
    
    vc.dataArray = self.dataArray;
    vc.headerArray = self.headerArray;
    vc.orderType = self.orderType;
    vc.type = self.type;
    vc.time = self.time;
    vc.filterNameArray = self.filterNameArray;
    
    [self.navigationController pushViewController:vc animated:YES];
    vc = nil;
}
#pragma mark - TableDatasource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 80;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    OrderHeaderView *header = (OrderHeaderView*)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"OrderHeaderView"];
    header.dataArray = self.headerArray;
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 58.0f;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OrderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.orderModel=[self.dataArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    OrderModel *order = (OrderModel *)self.dataArray[indexPath.row];
    
    //去除红点
    order.ered = false;
    [self.dataArray replaceObjectAtIndex:indexPath.row withObject:order];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        AVObject *object = [AVObject objectWithClassName:@"Order" objectId:order.orderId];
        
        [object setObject:@(false) forKey:@"ered"];
        
        [object saveEventually];
    });
    
    
    //--------
    __weak __typeof(self)weakSelf = self;
    
    OrderDetailVC *VC = LOADVC(@"OrderDetailVC");
    VC.orderModel = order;
    VC.idxPath = indexPath;
    VC.deleteHandler = ^(NSIndexPath *idxpath){
        [weakSelf.dataArray removeObjectAtIndex:idxpath.row];
        
        [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    };
    VC.refreshHandler = ^(OrderModel *orderModel,NSIndexPath *idxpath) {
        [weakSelf.dataArray replaceObjectAtIndex:idxpath.row withObject:orderModel];
        
        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    };
    [self.navigationController pushViewController:VC animated:YES];
    VC = nil;
}

//去掉UItableview headerview黏性(sticky)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 80;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}
#pragma mark -
#pragma mark - 请求数据
-(NSDate*) getDateWithDateString:(NSString*) dateString{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormat dateFromString:dateString];
    return date;
}

-(void)getDataFromSever {
    if ([DataShare sharedService].appDel.isReachable) {
        __weak __typeof(self)weakSelf = self;
        
        AVQuery *query1 = [AVQuery queryWithClassName:@"Order"];
        query1.cachePolicy = kAVCachePolicyNetworkElseCache;
        query1.maxCacheAge = 24*3600;// 一天的总秒数
        [query1 whereKey:@"user" equalTo:[AVUser currentUser]];
        
        if (self.orderType==0) {
            if (self.type==5) {
                NSArray *array = [self.time componentsSeparatedByString:@"/"];
                
                NSString *starTime = [NSString stringWithFormat:@"%ld-%ld-%ld 00:00:00",[array[2] integerValue],[array[0] integerValue],[array[1] integerValue]];
                NSDate *starDate = [self getDateWithDateString:starTime];
                
                NSString *endTime = [NSString stringWithFormat:@"%ld-%ld-%ld 23:59:59",[array[2] integerValue],[array[0] integerValue],[array[1] integerValue]];
                NSDate *endDate = [self getDateWithDateString:endTime];
                
                [query1 whereKey:@"createdAt" greaterThanOrEqualTo:starDate];
                [query1 whereKey:@"createdAt" lessThanOrEqualTo:endDate];
            }else {
                
                NSDate * date  = [NSDate date];
                NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitWeekday|NSCalendarUnitWeekdayOrdinal fromDate:date];
                NSString *month_starTime;
                NSDate *month_starDate;
                
                NSString *month_endTime;
                NSDate *month_endDate;
                
                if(comps.weekday==1){
                    month_starTime = [NSString stringWithFormat:@"%ld-%ld-%ld 00:00:00",comps.year,comps.month,comps.day-6];
                }else if(comps.weekday==2){
                    month_starTime = [NSString stringWithFormat:@"%ld-%ld-%ld 00:00:00",comps.year,comps.month,comps.day];
                }else if(comps.weekday==3){
                    month_starTime = [NSString stringWithFormat:@"%ld-%ld-%ld 00:00:00",comps.year,comps.month,comps.day-1];
                }else if(comps.weekday==4){
                    month_starTime = [NSString stringWithFormat:@"%ld-%ld-%ld 00:00:00",comps.year,comps.month,comps.day-2];
                }else if(comps.weekday==5){
                    month_starTime = [NSString stringWithFormat:@"%ld-%ld-%ld 00:00:00",comps.year,comps.month,comps.day];
                }else if(comps.weekday==6){
                    month_starTime = [NSString stringWithFormat:@"%ld-%ld-%ld 00:00:00",comps.year,comps.month,comps.day-4];
                }else if(comps.weekday==7){
                    month_starTime = [NSString stringWithFormat:@"%ld-%ld-%ld 00:00:00",comps.year,comps.month,comps.day-5];
                }
                
                
                NSString *starTime = [NSString stringWithFormat:@"%ld-%ld-%ld 00:00:00",comps.year,comps.month,comps.day];
                NSDate *starDate = [self getDateWithDateString:starTime];
                
                NSString *endTime = [NSString stringWithFormat:@"%ld-%ld-%ld 23:59:59",comps.year,comps.month,comps.day];
                NSDate *endDate = [self getDateWithDateString:endTime];
                
                if (self.type==0) {
                    [query1 whereKey:@"createdAt" greaterThanOrEqualTo:starDate];
                    [query1 whereKey:@"createdAt" lessThanOrEqualTo:endDate];
                }else if (self.type==1) {
                    NSTimeInterval secondsPerDay = 24 * 60 * 60;
                    
                    NSDate *starDate2 = [starDate dateByAddingTimeInterval: -secondsPerDay];
                    NSDate *endDate2 = [endDate dateByAddingTimeInterval: -secondsPerDay];
                    [query1 whereKey:@"createdAt" greaterThanOrEqualTo:starDate2];
                    [query1 whereKey:@"createdAt" lessThanOrEqualTo:endDate2];
                }else if (self.type==2) {
                    month_starDate = [self getDateWithDateString:month_starTime];
                    month_endTime = [NSString stringWithFormat:@"%ld-%ld-%ld 23:59:59",comps.year,comps.month,comps.day];
                    month_endDate = [self getDateWithDateString:month_endTime];
                    [query1 whereKey:@"createdAt" greaterThanOrEqualTo:month_starDate];
                    [query1 whereKey:@"createdAt" lessThanOrEqualTo:month_endDate];
                }else if (self.type==3) {
                    date = [NSDate returnMonthday];
                    [query1 whereKey:@"createdAt" greaterThanOrEqualTo:date];
                }else if (self.type==4) {
                    date = [NSDate returnMonth:3];
                    [query1 whereKey:@"createdAt" greaterThanOrEqualTo:date];
                }
            }
        }else if (self.orderType==1) {
            if (self.type<=2) {
                [query1 whereKey:@"isPay" equalTo:[NSNumber numberWithInteger:self.type]];
            }else {
                [query1 whereKey:@"isDeliver" equalTo:[NSNumber numberWithInteger:(self.type-3)]];
            }
        }
        
        [query1 orderByDescending:@"createdAt"];

        [query1 includeKey:@"products"];
        [query1 includeKey:@"client"];
        [query1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [weakSelf.tableView.mj_header endRefreshing];

            if (!error) {
                weakSelf.dataArray = nil;
                weakSelf.headerArray = nil;
                
                CGFloat price = 0;//总金额
                NSInteger num = 0;//总数量
                CGFloat profit = 0;//总利润
                NSInteger client = 0;//来自会员
                NSInteger partPay = 0;//部分付款
                NSInteger allPay = 0;//全部付款
                NSInteger partship = 0;//部分发货
                NSInteger allship= 0;//全部发货
                
                CGFloat tax = 0;//税
                
                for (int i=0; i<objects.count; i++) {
                    AVObject *object = objects[i];
                    OrderModel *model = [OrderModel initWithObject:object];
                    num += model.orderCount;
                    price += model.orderPrice;
                    profit += model.profit;
                    tax += model.tax;
                    
                    if ([Utility checkString:model.clientId]) {
                        client ++;
                    }
                    if (model.isPay==1) {
                        partPay ++;
                    }else if (model.isPay==2) {
                        allPay ++;
                    }
                    
                    if (model.isDeliver==1) {
                        partship ++;
                    }else if (model.isDeliver==2) {
                        allship ++;
                    }
                    
                    [weakSelf.dataArray addObject:model];
                }
                
                [weakSelf.headerArray addObject:@(num)];
                [weakSelf.headerArray addObject:@(price)];
                [weakSelf.headerArray addObject:@(profit)];
                [weakSelf.headerArray addObject:@(client)];
                [weakSelf.headerArray addObject:@(partPay)];
                [weakSelf.headerArray addObject:@(allPay)];
                [weakSelf.headerArray addObject:@(partship)];
                [weakSelf.headerArray addObject:@(allship)];
                [weakSelf.headerArray addObject:@(tax)];
                [weakSelf.tableView reloadData];
                
                if (weakSelf.orderType==0 && weakSelf.type==5) {
                    [weakSelf.navBarView setLeftWithImage:@"sort_icon" title:[NSString stringWithFormat:@"%@ • %ld",weakSelf.time,objects.count]];
                }else {
                    [weakSelf.navBarView setLeftWithImage:@"sort_icon" title:[NSString stringWithFormat:@"%@ • %ld",weakSelf.filterNameArray[weakSelf.orderType][weakSelf.type],objects.count]];
                }
                
            } else {
                [PopView showWithImageName:@"error" message:SetTitle(@"connect_error")];
            }
        }];
    }else {
        [PopView showWithImageName:@"error" message:SetTitle(@"no_connect")];
    }
}

@end
