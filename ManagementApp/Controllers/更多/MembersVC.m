//
//  MembersVC.m
//  ManagementApp
//
//  Created by 邱成西 on 2016/11/17.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "MembersVC.h"
#import "AFNetworking.h"
#import "AddMemberVC.h"
@interface MembersVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *table;

@property (strong, nonatomic) NSMutableArray *dataArray;
@end

@implementation MembersVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
    
    //集成刷新控件
    [self addHeader];
    
    [self.table.mj_header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

-(void)setNavBarView {
    [self.navBarView setTitle:SetTitle(@"member") image:nil];
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.navBarView setRightWithArray:@[@"add"] type:0];
    [self.view addSubview:self.navBarView];
    
    [Utility setExtraCellLineHidden:self.table];
}

#pragma mark - private

- (void)addHeader {
    
    __weak __typeof(self)weakSelf = self;
    self.table.mj_header = [LCCKConversationRefreshHeader headerWithRefreshingBlock:^{
        [weakSelf getDataFromSever];
    }];
}

-(void)getDataFromSever {
    if ([DataShare sharedService].appDel.isReachable) {

        QWeakSelf(self);
        AVQuery *query = [AVQuery queryWithClassName:@"Member"];
        [query whereKey:@"user" equalTo:[AVUser currentUser]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [weakself.table.mj_header endRefreshing ];
            if (!error) {
                weakself.dataArray = nil;
                for (int i=0; i<objects.count; i++) {
                    AVObject *object = objects[i];
                    
                    UserModel *model = [[UserModel alloc]init];
                    model.userId = object.objectId;
                    model.userName = object[@"username"];
                    [weakself.dataArray addObject:model];
                }
                
                [weakself.table reloadData];
            }
        }];
        
    }else {
        [PopView showWithImageName:@"error" message:SetTitle(@"no_connect")];
    }
}


-(void)leftBtnClickByNavBarView:(NavBarView *)navView {

    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    AddMemberVC *vc = LOADVC(@"AddMemberVC");
    QWeakSelf(self);
    vc.completedBlock = ^(BOOL success){
        if (success) {
            [weakself.table.mj_header beginRefreshing];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
    SafeRelease(vc);
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"memberCell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"memberCell"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UserModel *model = (UserModel *)self.dataArray[indexPath.row];
    cell.textLabel.text = model.userName;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath  {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  UITableViewCellEditingStyleDelete;
}

- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete){
        
        QWeakSelf(self);
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:SetTitle(@"ConfirmDelete") preferredStyle:UIAlertControllerStyleAlert];
        
        [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
        
        [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
            [MBProgressHUD showHUDAddedTo:weakself.view animated:YES];
            
            UserModel *model = (UserModel *)weakself.dataArray[indexPath.row];
            
            AVObject *post = [AVObject objectWithClassName:@"Member" objectId:model.userId];
            [post deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [weakself.dataArray removeObjectAtIndex:indexPath.row];
                [weakself.table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [MBProgressHUD hideHUDForView:weakself.view animated:YES];
            }];
        }];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
@end
