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

#import "OrderModel.h"


@interface ClientDetailVC ()

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) BOOL isLoadingMore;

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
    
    [self.tableView.mj_header beginRefreshing];
}


-(void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage) name:LCCKNotificationMessageReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage) name:LCCKNotificationUnreadsUpdated object:nil];
}

-(void)receiveMessage {
    [self.tableView reloadData];
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
    [self.tableView registerClass:[ClientDetailHeader class] forHeaderFooterViewReuseIdentifier:@"ClientDetailHeader"];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    if ([Utility isAuthority]) {
        AddClientVC *proVC = [[AddClientVC alloc]init];
        proVC.clientModel = self.clientModel;
        proVC.isEditing = YES;
        [self.navigationController pushViewController:proVC animated:YES];
        SafeRelease(proVC);
    }else {
        /*
        QWeakSelf(self);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"authority_tip") message:SetTitle(@"authority_error") preferredStyle:UIAlertControllerStyleAlert];
        [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
            
            AuthorityVC *vc = LOADVC(@"AuthorityVC");
            [weakself.navigationController pushViewController:vc animated:YES];
        }];
        [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
        [self presentViewController:alert animated:YES completion:nil];
         */
    }
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
    
    __weak ClientDetailHeader *weakheader = header;
    header.sendMessage = ^(ClientModel *clientModel){
        
        if ([Utility isAuthority]) {
            [DataShare sharedService].clientObject = clientModel;
            
            [weakheader.notificationHub setCount:-1];
            
            LCCKConversationViewController *conversationViewController =
            [[LCCKConversationViewController alloc] initWithPeerId:clientModel.clientName];
            
            __weak __typeof(conversationViewController)weakConversation = conversationViewController;
            conversationViewController.viewWillAppearBlock = ^(LCCKBaseViewController *viewController, BOOL aAnimated){
                [weakConversation.navigationController setNavigationBarHidden:false animated:YES];
                
                weakConversation.navigationItem.title = @"";
            };
            conversationViewController.viewWillDisappearBlock = ^(LCCKBaseViewController *viewController, BOOL aAnimated){
                [AppDelegate shareInstance].isInmessageVC = false;
                [AppDelegate shareInstance].messageTo = nil;
                [weakConversation.navigationController setNavigationBarHidden:YES animated:YES];
            };
            
            [weakSelf.navigationController pushViewController:
             conversationViewController animated:YES];
            
            [AppDelegate shareInstance].isInmessageVC = true;
            [AppDelegate shareInstance].messageTo = weakSelf.clientModel.clientName;
            [[DataShare sharedService].unreadMessageDic removeObjectForKey:weakSelf.clientModel.clientName];
        }else {
//            UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"authority_tip") message:SetTitle(@"authority_error") preferredStyle:UIAlertControllerStyleAlert];
//            [weakSelf addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
//                
//                AuthorityVC *vc = LOADVC(@"AuthorityVC");
//                [weakSelf.navigationController pushViewController:vc animated:YES];
//            }];
//            [weakSelf addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
//            [weakSelf presentViewController:alert animated:YES completion:nil];
        }
    };
    
    
    return header;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.index==0) {
        return self.dataArray.count;
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
        
        cell.orderModel = self.dataArray[indexPath.row];
        
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
    if ([DataShare sharedService].appDel.isReachable) {
        __weak __typeof(self)weakSelf = self;
        
        AVQuery *query1 = [AVQuery queryWithClassName:@"Order"];
        query1.cachePolicy = kAVCachePolicyNetworkElseCache;
        query1.maxCacheAge = 24*3600;// 一天的总秒数
        [query1 whereKey:@"user" equalTo:[AVUser currentUser]];
        [query1 orderByDescending:@"updatedAt"];
        
        [query1 whereKey:@"clientId" containsString:self.clientModel.clientId];
        
        query1.limit = 10;
        query1.skip = 10*self.start;
        
        [query1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            if (!error) {
                if (!weakSelf.isLoadingMore) {
                    weakSelf.dataArray = nil;
                }
                [weakSelf.tableView.mj_footer setHidden:YES];
                if (objects.count==10) {
                    [weakSelf addFooter];
                }
                for (int i=0; i<objects.count; i++) {
                    AVObject *object = objects[i];
                    OrderModel *model = [OrderModel initWithObject:object];
                    [weakSelf.dataArray addObject:model];
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

@end
