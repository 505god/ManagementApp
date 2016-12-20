//
//  StaticVC.m
//  ManagementApp
//
//  Created by 邱成西 on 16/10/29.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "StaticVC.h"
#import "RETableViewManager.h"

@interface StaticVC ()<RETableViewManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) RETableViewManager *manager;

@property (nonatomic, strong) NSMutableArray *tempArray;

@end

@implementation StaticVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
    
    self.tempArray = [NSMutableArray arrayWithObjects:@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0", nil];
    
    //集成刷新控件
    [self addHeader];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - UI

-(void)setNavBarView {
    [self.navBarView setTitle:SetTitle(@"statistics") image:nil];
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.view addSubview:self.navBarView];
    
    [self setTableView];
    
}

-(void)reloadData {
    [self.manager removeAllSections];
    
    RETableViewSection *section = [RETableViewSection section];
    [self.manager addSection:section];
    
    //当天订单数
    RETextItem *orderItem = [RETextItem itemWithTitle:SetTitle(@"static_today_order") value:self.tempArray[0] placeholder:@"0"];
//    orderItem.enabled = false;
    orderItem.alignment = NSTextAlignmentRight;
    [section addItem:orderItem];
    
    //当天销售额
    RETextItem *saleItem = [RETextItem itemWithTitle:SetTitle(@"static_today_money") value:self.tempArray[1] placeholder:@"0"];
//    saleItem.enabled = false;
    saleItem.alignment = NSTextAlignmentRight;
    [section addItem:saleItem];
    
    //当天收益
    RETextItem *profitItem = [RETextItem itemWithTitle:SetTitle(@"static_today_profit") value:self.tempArray[2] placeholder:@"0"];
//    profitItem.enabled = false;
    profitItem.alignment = NSTextAlignmentRight;
    [section addItem:profitItem];
    
    //当天卖出库存
    RETextItem *stockItem = [RETextItem itemWithTitle:SetTitle(@"static_today_stock") value:self.tempArray[3] placeholder:@"0"];
    stockItem.enabled = false;
    stockItem.alignment = NSTextAlignmentRight;
    [section addItem:stockItem];
    
    RETableViewSection *section2 = [RETableViewSection section];
    [self.manager addSection:section2];
    section2.headerHeight = 10;
    //总投入
    RETextItem *allMoneyItem = [RETextItem itemWithTitle:SetTitle(@"static_moneyTotal") value:self.tempArray[4] placeholder:@"0"];
    allMoneyItem.enabled = false;
    allMoneyItem.alignment = NSTextAlignmentRight;
    [section2 addItem:allMoneyItem];
    
    //总收益
    RETextItem *allProfitItem = [RETextItem itemWithTitle:SetTitle(@"static_profitTotal") value:self.tempArray[5] placeholder:@"0"];
    allProfitItem.enabled = false;
    allProfitItem.alignment = NSTextAlignmentRight;
    [section2 addItem:allProfitItem];
    
    //税
//    RETextItem *taxItem = [RETextItem itemWithTitle:SetTitle(@"company_tax") value:self.tempArray[9] placeholder:@"0"];
//    taxItem.enabled = false;
//    taxItem.alignment = NSTextAlignmentRight;
//    [section2 addItem:taxItem];
    
    RETableViewSection *section3 = [RETableViewSection section];
    [self.manager addSection:section3];
    section3.headerHeight = 10;
    
    //总库存
    RETextItem *allStockItem = [RETextItem itemWithTitle:SetTitle(@"static_stockTotal") value:self.tempArray[6] placeholder:@"0"];
    allStockItem.enabled = false;
    allStockItem.alignment = NSTextAlignmentRight;
    [section3 addItem:allStockItem];
    
    //剩余库存
    RETextItem *surplusStockItem = [RETextItem itemWithTitle:SetTitle(@"static_stockSurplus") value:self.tempArray[7] placeholder:@"0"];
    surplusStockItem.enabled = false;
    surplusStockItem.alignment = NSTextAlignmentRight;
    [section3 addItem:surplusStockItem];
    
    //剩余库存价值
    RETextItem *surplusStockMoneyItem = [RETextItem itemWithTitle:SetTitle(@"static_moneySurplus") value:self.tempArray[8] placeholder:@"0"];
    surplusStockMoneyItem.enabled = false;
    surplusStockMoneyItem.alignment = NSTextAlignmentRight;
    [section3 addItem:surplusStockMoneyItem];
}

-(void)setTableView {
    self.tableView = [[UITableView alloc]initWithFrame:(CGRect){0,self.navBarView.bottom,[UIScreen mainScreen].bounds.size.width,self.view.height-self.navBarView.bottom} style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    
    // Create manager
    self.manager = [[RETableViewManager alloc] initWithTableView:self.tableView];
    self.manager.delegate = self;
    
    [self reloadData];
    
    [Utility setExtraCellLineHidden:self.tableView];
}

#pragma mark - private

- (void)addHeader {
    
    __weak __typeof(self)weakSelf = self;
    self.tableView.mj_header = [LCCKConversationRefreshHeader headerWithRefreshingBlock:^{
        [weakSelf getDataFromSever];
    }];
}

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getDataFromSever {
    if (![DataShare sharedService].appDel.isReachable) {
        [PopView showWithImageName:@"error" message:SetTitle(@"no_connect")];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^(){
        AVQuery *query1 = [AVQuery queryWithClassName:@"Order"];
        [query1 whereKey:@"user" equalTo:[AVUser currentUser]];
        NSDate *date = [NSDate returnToday];
        [query1 whereKey:@"createdAt" greaterThanOrEqualTo:date];
        [query1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            //当天订单数
            [weakSelf.tempArray replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%ld",objects.count]];
            
            //当天销售额
            CGFloat price = 0;
            //当天收益
            CGFloat profit = 0;
            //当天卖出库存
            NSInteger stock = 0;
            
            for (int i=0; i<objects.count; i++) {
                AVObject *obj = objects[i];
                NSDictionary *dic = [obj objectForKey:@"localData"];
                price += [dic[@"orderPrice"] floatValue];
                profit += [dic[@"profit"] floatValue];
                stock += [dic[@"orderCount"] integerValue];
            }
            
            [weakSelf.tempArray replaceObjectAtIndex:1 withObject:[NSString stringWithFormat:@"%.2f",price]];
            [weakSelf.tempArray replaceObjectAtIndex:2 withObject:[NSString stringWithFormat:@"%.2f",profit]];
            [weakSelf.tempArray replaceObjectAtIndex:3 withObject:[NSString stringWithFormat:@"%ld",stock]];
            
            dispatch_group_leave(group);
        }];
    });
    
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^(){
        AVQuery *query1 = [AVQuery queryWithClassName:@"Statistics"];
        [query1 whereKey:@"user" equalTo:[AVUser currentUser]];
        AVObject *statistics_post = [query1 getFirstObject];
        
        [weakSelf.tempArray replaceObjectAtIndex:4 withObject:[NSString stringWithFormat:@"%.2f",[[statistics_post objectForKey:@"totalMoney"] floatValue]]];
        
        CGFloat Profit = [[statistics_post objectForKey:@"totalProfit"] floatValue];
        if (Profit<=0) {
            Profit = 0;
        }
        [weakSelf.tempArray replaceObjectAtIndex:5 withObject:[NSString stringWithFormat:@"%.2f",Profit]];
        [weakSelf.tempArray replaceObjectAtIndex:6 withObject:[NSString stringWithFormat:@"%ld",[[statistics_post objectForKey:@"totalStock"] integerValue]]];
        [weakSelf.tempArray replaceObjectAtIndex:7 withObject:[NSString stringWithFormat:@"%ld",[[statistics_post objectForKey:@"totalStock"] integerValue]-[[statistics_post objectForKey:@"surplusStock"] integerValue]]];
        [weakSelf.tempArray replaceObjectAtIndex:8 withObject:[NSString stringWithFormat:@"%.2f",[[statistics_post objectForKey:@"surplusMoney"] floatValue]]];
        
//        CGFloat tax = [[statistics_post objectForKey:@"tax"] floatValue];
//        if (tax<=0) {
//            tax = 0;
//        }
//        [weakSelf.tempArray replaceObjectAtIndex:9 withObject:[NSString stringWithFormat:@"%.2f",tax]];
        
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^(){
        
        [weakSelf.tableView.mj_header endRefreshing];
        
        [weakSelf setTableView];
    });
    
    
}
@end
