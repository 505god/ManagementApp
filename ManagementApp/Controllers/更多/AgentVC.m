//
//  AgentVC.m
//  ManagementApp
//
//  Created by 邱成西 on 16/1/14.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "AgentVC.h"

#import "SearchTable.h"
#import "ChineseInclude.h"
#import "PinYinForObjc.h"
#import "WQIndexedCollationWithSearch.h"

#import "UserModel.h"
#import "AgentCell.h"
#import "AgentDetailVC.h"

@interface AgentVC ()<SearchTableDelegate>

@property (nonatomic, strong) SearchTable *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation AgentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
    //集成刷新控件
    [self addHeader];
    
    [self.tableView.tableView.mj_header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter/setter

-(SearchTable *)tableView {
    if (!_tableView) {
        _tableView = [[SearchTable alloc] initWithFrame:(CGRect){0,self.navBarView.bottom,SCREEN_WIDTH,SCREEN_HEIGHT-self.navBarView.height}];
        _tableView.delegate = self;
        _tableView.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [Utility setExtraCellLineHidden:_tableView.tableView];
        [_tableView.tableView registerNib:[UINib nibWithNibName:@"AgentCell" bundle:nil] forCellReuseIdentifier:@"AgentCell"];
        
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}


#pragma mark - private

- (void)addHeader {
    
    __weak __typeof(self)weakSelf = self;
    self.tableView.tableView.mj_header = [LCCKConversationRefreshHeader headerWithRefreshingBlock:^{
        [weakSelf getDataFromSever];
    }];
}

#pragma mark - UI

-(void)setNavBarView {
    [self.navBarView setTitle:SetTitle(@"agent") image:nil];
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.view addSubview:self.navBarView];
}

#pragma mark - 获取列表

-(void)getDataFromSever {
    if ([DataShare sharedService].appDel.isReachable) {
        __weak __typeof(self)weakSelf = self;
        
        AVQuery *query = [AVUser query];
        [query whereKey:@"type" equalTo:@(0)];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [weakSelf.tableView.tableView.mj_header endRefreshing ];
            if (!error) {
                [DataShare sharedService].agentArray = nil;
                for (int i=0; i<objects.count; i++) {
                    AVObject *object = objects[i];
                    
                    UserModel *model = [UserModel initWithObject:object];
                    [[DataShare sharedService].agentArray addObject:model];
                }
                
                [[DataShare sharedService] sortAgent:[DataShare sharedService].agentArray CompleteBlock:^(NSArray *array) {
                    weakSelf.dataArray = [NSMutableArray arrayWithArray:array];
                    [weakSelf.tableView setHeaderAnimated:YES];
                    [weakSelf.tableView reloadData];
                }];
            } else {
                [PopView showWithImageName:@"error" message:SetTitle(@"connect_error")];
            }
        }];
        
    }else {
        [PopView showWithImageName:@"error" message:SetTitle(@"no_connect")];
    }
}

#pragma mark - search代理
- (void)searchBarTextDidBeginEditing:(UISearchBar *)search {
    search.showsCancelButton = YES;
    for(id cc in [search subviews]) {
        if([cc isKindOfClass:[UIView class]]) {
            UIView *cc_view = (UIView *)cc;
            for (id vv in [cc_view subviews]){
                if([vv isKindOfClass:[UIButton class]]){
                    UIButton *btn = (UIButton *)vv;
                    [btn setTitle:SetTitle(@"cancel") forState:UIControlStateNormal];
                    [btn setTintColor:[UIColor lightGrayColor]];
                }
            }
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)search{
    search.showsCancelButton=NO;
    search.text=nil;
    [search resignFirstResponder];
    
    __weak __typeof(self)weakSelf = self;
    [[DataShare sharedService] sortAgent:[DataShare sharedService].agentArray CompleteBlock:^(NSArray *array) {
        weakSelf.dataArray = [NSMutableArray arrayWithArray:array];
        [weakSelf.tableView setHeaderAnimated:YES];
        [weakSelf.tableView reloadData];
    }];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSMutableArray *searchResults = [NSMutableArray array];
    
    if (searchBar.text.length>0 && ![ChineseInclude isIncludeChineseInString:searchBar.text]) {//英文或者数字搜素
        
        [[DataShare sharedService].agentArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UserModel *colorModel = (UserModel *)obj;
            
            if ([ChineseInclude isIncludeChineseInString:colorModel.userName]) {//名称含有中文
                //转换为拼音
                NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:colorModel.userName];
                NSRange titleResult=[tempPinYinStr rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0 && ![searchResults containsObject:colorModel]) {
                    [searchResults addObject:colorModel];
                }
                
                //转换为拼音首字母
                NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:colorModel.userName];
                NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
                if (titleHeadResult.length>0 && ![searchResults containsObject:colorModel]) {
                    [searchResults addObject:colorModel];
                }
            }else {
                //昵称含有数字
                NSRange titleResult=[colorModel.userName rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [searchResults addObject:colorModel];
                }
            }
        }];
        
    } else if (searchBar.text.length>0&&[ChineseInclude isIncludeChineseInString:searchBar.text]) {//中文搜索
        for (UserModel *colorModel in [DataShare sharedService].agentArray) {
            NSRange titleResult=[colorModel.userName rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
            if (titleResult.length>0) {
                [searchResults addObject:colorModel];
            }
        }
    }else if (searchBar.text.length == 0){
        [searchResults addObjectsFromArray:[DataShare sharedService].agentArray];
    }
    
    
    __weak __typeof(self)weakSelf = self;
    [[DataShare sharedService] sortAgent:searchResults CompleteBlock:^(NSArray *array) {
        weakSelf.dataArray = [NSMutableArray arrayWithArray:array];
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (NSArray *)sectionIndexTitlesForWQCustomerTable:(SearchTable *)tableView {
    NSMutableArray * indexTitles = [NSMutableArray array];
    for (NSDictionary * sectionDictionary in self.dataArray) {
        [indexTitles addObject:sectionDictionary[@"indexTitle"]];
    }
    return indexTitles;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.width, 15)];
    customView.backgroundColor = COLOR(230, 230, 230, 1);
    
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:(CGRect){10, 0.0, self.tableView.width-20, 15}];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor lightGrayColor];
    headerLabel.font = [UIFont systemFontOfSize:13];
    headerLabel.text = self.dataArray[section][@"indexTitle"];
    
    [customView addSubview:headerLabel];
    SafeRelease(headerLabel);
    
    return customView;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *aDic = (NSDictionary *)self.dataArray[section];
    NSArray *array = (NSArray *)aDic[@"data"];
    return [array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AgentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AgentCell" forIndexPath:indexPath];
    UserModel *colorModel = (UserModel *)self.dataArray[indexPath.section][@"data"][indexPath.row];
    [cell setUserModel:colorModel];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    __weak __typeof(self)weakSelf = self;
    UserModel *colorModel = (UserModel *)self.dataArray[indexPath.section][@"data"][indexPath.row];
    
    
    AgentDetailVC *vc = [[AgentDetailVC alloc]init];
    vc.completedBlock = ^(BOOL success){
        [weakSelf.tableView.tableView.mj_header beginRefreshing];
    };
    vc.model = colorModel;
    vc.idxPath = indexPath;
    vc.updateHandler = ^(NSIndexPath *idxPath,UserModel *model){
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:weakSelf.dataArray[idxPath.section]];
        NSMutableArray *arr = [NSMutableArray arrayWithArray:dic[@"data"]];
        [arr replaceObjectAtIndex:idxPath.row withObject:model];
        [dic setObject:arr forKey:@"data"];
        [weakSelf.dataArray replaceObjectAtIndex:idxPath.section withObject:dic];
        
        [weakSelf.tableView.tableView reloadRowsAtIndexPaths:@[idxPath] withRowAnimation:UITableViewRowAnimationNone];
    };
    [self.navigationController pushViewController:vc animated:YES];
    vc = nil;
}
@end
