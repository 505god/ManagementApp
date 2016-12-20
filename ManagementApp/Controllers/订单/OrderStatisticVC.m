//
//  OrderStatisticVC.m
//  ManagementApp
//
//  Created by 邱成西 on 16/1/17.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "OrderStatisticVC.h"
#import "StatisticModel.h"
#import "OrderStatisticCell.h"

@interface OrderStatisticVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataList;

@end

@implementation OrderStatisticVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavBarView];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[Utility getImgWithImageName:@"shop_title@2x"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setNavBarView {
    
    [self.navBarView setTitle:SetTitle(@"order_info") image:nil];
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.view addSubview:self.navBarView];
    
    [self setTableViewUI];
}

-(void)setTableViewUI {
    self.tableView = [[UITableView alloc]initWithFrame:(CGRect){0,self.navBarView.bottom,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height-self.navBarView.bottom} style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [Utility setExtraCellLineHidden:self.tableView];
    
    
    [self dealDataList];
}


-(void)dealDataList {
    self.dataList = [NSMutableArray array];
    
    StatisticModel *model0 = [[StatisticModel alloc]init];
    if (self.orderType==0 && self.type==5) {
        model0.title = self.time;
    }else {
        model0.title = self.filterNameArray[self.orderType][self.type];
    }
    model0.type = 0;
    [self.dataList addObject:model0];
    
    
    StatisticModel *model1 = [[StatisticModel alloc]init];
    model1.title = SetTitle(@"order_total");
    model1.info = [NSString stringWithFormat:@"%.2f",[self.headerArray[1] floatValue]];
    model1.type = 0;
    [self.dataList addObject:model1];
    
//    StatisticModel *model2 = [[StatisticModel alloc]init];
//    model2.title = SetTitle(@"order_tax");
//    model2.info = [NSString stringWithFormat:@"%.2f",[self.headerArray[8] floatValue]];
//    model2.type = 0;
//    [self.dataList addObject:model2];
    
    
    StatisticModel *model3 = [[StatisticModel alloc]init];
    model3.title = SetTitle(@"order_profit");
    model3.info = [NSString stringWithFormat:@"%.2f",[self.headerArray[2] floatValue]];
    model3.type = 0;
    [self.dataList addObject:model3];
    
    StatisticModel *model4 = [[StatisticModel alloc]init];
    model4.title = SetTitle(@"order_count");
    model4.info = [NSString stringWithFormat:@"%ld",[self.headerArray[0] integerValue]];
    model4.type = 0;
    [self.dataList addObject:model4];
    
    
    StatisticModel *model5 = [[StatisticModel alloc]init];
    model5.title = SetTitle(@"order_num");
    model5.info = [NSString stringWithFormat:@"%ld",self.dataArray.count];
    model5.type = 0;
    [self.dataList addObject:model5];
        
    StatisticModel *model6 = [[StatisticModel alloc]init];
    model6.title = SetTitle(@"pay_none");
    model6.info = [NSString stringWithFormat:@"%ld",(self.dataArray.count-[self.headerArray[4] integerValue]-[self.headerArray[5] integerValue])];
    model6.type = 1;
    [self.dataList addObject:model6];
    
    StatisticModel *model8 = [[StatisticModel alloc]init];
    model8.title = SetTitle(@"pay_part");
    model8.info = [NSString stringWithFormat:@"%ld",[self.headerArray[4] integerValue]];
    model8.type = 1;
    [self.dataList addObject:model8];
    
    StatisticModel *model9 = [[StatisticModel alloc]init];
    model9.title = SetTitle(@"pay_all");
    model9.info = [NSString stringWithFormat:@"%ld",[self.headerArray[5] integerValue]];
    model9.type = 1;
    [self.dataList addObject:model9];
    
    StatisticModel *model10 = [[StatisticModel alloc]init];
    model10.title = SetTitle(@"deliver_none");
    model10.info = [NSString stringWithFormat:@"%ld",(self.dataArray.count-[self.headerArray[6] integerValue]-[self.headerArray[7] integerValue])];
    model10.type = 1;
    [self.dataList addObject:model10];
    
    StatisticModel *model11 = [[StatisticModel alloc]init];
    model11.title = SetTitle(@"deliver_part");
    model11.info = [NSString stringWithFormat:@"%ld",[self.headerArray[6] integerValue]];
    model11.type = 1;
    [self.dataList addObject:model11];
    
    StatisticModel *model12 = [[StatisticModel alloc]init];
    model12.title = SetTitle(@"deliver_all");
    model12.info = [NSString stringWithFormat:@"%ld",[self.headerArray[7] integerValue]];
    model12.type = 1;
    [self.dataList addObject:model12];
    
    [self.tableView reloadData];
}

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    [self.navigationController popViewControllerAnimated:YES];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * identifier = @"OrderStatisticCell";
    
    OrderStatisticCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[OrderStatisticCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    cell.model = self.dataList[indexPath.row];
    return cell;
}


@end
