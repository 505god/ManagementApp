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

@interface OrderVC ()<UITableViewDataSource,UITableViewDelegate>
@property(strong,nonatomic) NSMutableArray *dataSource;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong,nonatomic) OrderHeaderView *headerView;

@end
NSString *const cellIdentifier=@"OrderCell";
@implementation OrderVC

#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
     _headerView = [[[NSBundle mainBundle] loadNibNamed:@"OrderHeaderView" owner:nil options:nil] firstObject];
    self.dataSource=[NSMutableArray array];
    for (int i=0; i<4;i++) {
        [self.dataSource addObject:@(i)];
    }
    [self.tableView registerNib:[UINib nibWithNibName:@"OrderCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    [self setNavBarView];
    self.tableView.tableHeaderView=self.headerView;
    self.tableView.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView reloadData];
    
}

#pragma mark - UI

-(void)setNavBarView {
    [self.navBarView setLeftWithImage:@"sort_icon" title:@"今天 . 12"];
    //[self.navBarView setTitle:SetTitle(@"navicon_order") image:nil];
    [self.view addSubview:self.navBarView];
}

#pragma mark - TableDatasource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 58.0f;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OrderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.orderModel=[self.dataSource objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(void)leftBtnClickByNavBarView:(NavBarView *)navView{
    NSLog(@"left bar click");
}
@end
