//
//  ClientDetailVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/27.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ClientDetailVC.h"

#import "AddClientVC.h"
#import "ClientDetailHeader.h"

#import "ClientDetailCell.h"
#import "ClientInfoCell.h"

#import "PrivateClientVC.h"

@interface ClientDetailVC ()

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ClientDetailVC

-(void)dealloc {
    SafeRelease(_tableView);
    SafeRelease(_clientModel);
    SafeRelease(_dataArray);
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
    [self.tableView registerClass:[ClientDetailHeader class] forHeaderFooterViewReuseIdentifier:@"ClientDetailHeader"];
}

#pragma mark - private

- (void)addHeader {
    __weak __typeof(self)weakSelf = self;
    [self.tableView addHeaderWithCallback:^{
        [weakSelf getDataFromSever];
    } dateKey:@"ClientDetailVC"];
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
    AddClientVC *proVC = [[AddClientVC alloc]init];
    proVC.clientModel = self.clientModel;
    [self.navigationController pushViewController:proVC animated:YES];
    SafeRelease(proVC);
}

#pragma mark -

#pragma mark - table代理

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [ClientDetailHeader returnHeightWithIndex:self.index];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ClientDetailHeader *header = (ClientDetailHeader*)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ClientDetailHeader"];
    header.clientModel = self.clientModel;
    header.selectedIndex = self.index;
    
    __weak __typeof(self)weakSelf = self;
    header.segmentChange = ^(NSInteger index){
        weakSelf.index = index;
        
        if (weakSelf.index==1) {
            weakSelf.tableView.contentInset = UIEdgeInsetsMake(0,0,0,0);
        }
        [weakSelf.tableView reloadData];
    };
    header.showPrivate = ^(ClientModel *clientModel){
        PrivateClientVC *privateVC = LOADVC(@"PrivateClientVC");
        privateVC.clientModel = weakSelf.clientModel;
        [weakSelf.navigationController pushViewController:privateVC animated:YES];
        SafeRelease(privateVC);
    };
    
    header.sendMessage = ^(ClientModel *clientModel){
        
    };
    
    
    return header;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.index==0) {
        return 100;
    }
    return 3;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.index==0) {
        static NSString * identifier = @"ClientDetailCell";
        
        ClientDetailCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell=[[ClientDetailCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
//        cell.clientDetailModel = self.dataArray[indexPath.row];
        
        return cell;
        
    }else if (self.index==1){
        static NSString * identifier = @"ClientInfoCell";
        
        ClientInfoCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell=[[ClientInfoCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.idxPath = indexPath;
        cell.clientModel = self.clientModel;
        
        return cell;
    }
    return nil;
}

//去掉UItableview headerview黏性(sticky)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView && self.index==0) {
        CGFloat sectionHeaderHeight = [ClientDetailHeader returnHeightWithIndex:self.index];
        if (self.index==0) {
            sectionHeaderHeight -= 80;
        }else {
            sectionHeaderHeight -= 52;
        }
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
            
            
        }else {
            [Utility interfaceWithStatus:[jsonData[@"status"] integerValue] msg:jsonData[@"msg"]];
        }
        
        [strongSelf.tableView headerEndRefreshing];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [strongSelf.tableView headerEndRefreshing];
        
        [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
        
        [PopView showWithImageName:@"error" message:SetTitle(@"connect_error")];
    }];
}

@end
