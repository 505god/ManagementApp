//
//  SortVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "SortVC.h"
#import "SortCell.h"

#import "MainVC.h"

@interface SortVC ()
@property(nonatomic, assign) NSInteger previousRowProduct;

@property(nonatomic, assign) NSInteger previousRowClient;

@property (nonatomic, assign) NSInteger waringCount;
@end

@implementation SortVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.previousRowProduct = 1;
    //集成刷新控件
    [self addHeader];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [Utility setExtraCellLineHidden:self.sortTable];
    
    ///底部切换栏布局
    int num = (int)self.currentPage;
    if (num == 0) {
        self.leftIconImgV.image = [Utility getImgWithImageName:@"hot_s_bt@2x"];
        self.leftNameLab.text = SetTitle(@"best_sellers") ;
        self.rightIconImgV.image = [Utility getImgWithImageName:@"hide_s_bt@2x"];
        self.rightNameLab.text = SetTitle(@"off_the_shelf");
        
        
        if (self.dataArray.count==0) {
            [self.sortTable headerBeginRefreshing];
        }else {
            [self.sortTable reloadData];
        }
    }else{
        self.leftIconImgV.image = [Utility getImgWithImageName:@"vendor_drawer_icon@2x"];
        self.leftNameLab.text = SetTitle(@"private_client");
        self.rightIconImgV.image = [Utility getImgWithImageName:@"factory_drawer_icon@2x"];
        self.rightNameLab.text = SetTitle(@"supplier");
        
        if (self.typeArray.count==0) {
            [self.sortTable headerBeginRefreshing];
        }else {
            [self.sortTable reloadData];
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter/setter

-(NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

-(NSMutableArray *)typeArray {
    if (!_typeArray) {
        _typeArray = [NSMutableArray array];
    }
    return _typeArray;
}

#pragma mark - private

- (void)addHeader {
    
    __weak __typeof(self)weakSelf = self;
    [self.sortTable addHeaderWithCallback:^{
        if (weakSelf.currentPage==0) {
            [weakSelf getSortDataFromSever];
        }else {
            [weakSelf getClientTypeNum];
        }
        
    } dateKey:@"SortVC"];
}

#pragma mark - 获取分类列表

-(void)getSortDataFromSever {
    
    if ([DataShare sharedService].appDel.isReachable) {
        __weak __typeof(self)weakSelf = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            weakSelf.dataArray = nil;
            //库存预警
            AVQuery *query1 = [AVQuery queryWithClassName:@"Product"];
            [query1 whereKey:@"user" equalTo:[AVUser currentUser]];
            [query1 whereKey:@"isWaring" equalTo:[NSNumber numberWithBool:true]];
            weakSelf.waringCount = [query1 countObjects];
            
            //全部
            AVQuery *query2 = [AVQuery queryWithClassName:@"Product"];
            [query2 whereKey:@"user" equalTo:[AVUser currentUser]];
            NSInteger all = [query2 countObjects];
            [weakSelf.dataArray addObject:@[SetTitle(@"navicon_all"),@(all)]];
            
            //未分类
            AVQuery *query3 = [AVQuery queryWithClassName:@"Product"];
            [query3 whereKey:@"user" equalTo:[AVUser currentUser]];
            [query3 whereKeyDoesNotExist:@"sort"];
            NSInteger notFliter = [query3 countObjects];
            [weakSelf.dataArray addObject:@[SetTitle(@"not_classified"),@(notFliter)]];
            
            AVQuery *query = [AVQuery queryWithClassName:@"Sort"];
            //查询行为先尝试从网络加载，若加载失败，则从缓存加载结果
            query.cachePolicy = kAVCachePolicyNetworkElseCache;
            //设置缓存有效期
            query.maxCacheAge = 24*3600;// 一天的总秒数
            [query whereKey:@"user" equalTo:[AVUser currentUser]];

            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    for (int i=0; i<objects.count; i++) {
                        AVObject *object = objects[i];
                        
                        SortModel *model = [SortModel initWithObject:object];
                        [weakSelf.dataArray addObject:model];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.sortTable headerEndRefreshing];
                        [weakSelf.sortTable reloadData];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.sortTable headerEndRefreshing];
                        [PopView showWithImageName:@"error" message:SetTitle(@"connect_error")];
                    });
                }
            }];
        });
        
    }else {
        [PopView showWithImageName:@"error" message:SetTitle(@"no_connect")];
    }
}

#pragma mark - 获取客户类型数量

-(void)getClientTypeNum {
    if ([DataShare sharedService].appDel.isReachable) {
        __weak __typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            weakSelf.typeArray = nil;
            
            AVQuery *query1 = [AVQuery queryWithClassName:@"Client"];
            [query1 whereKey:@"user" equalTo:[AVUser currentUser]];
            NSInteger all = [query1 countObjects];
            [weakSelf.typeArray addObject:@[SetTitle(@"navicon_all"),@(all)]];
            
            [query1 whereKey:@"clientType" equalTo:@(0)];
            [query1 whereKey:@"clientLevel" equalTo:@(0)];
            NSInteger aCount = [query1 countObjects];
            [weakSelf.typeArray addObject:@[@"A",@(aCount)]];
            
            [query1 whereKey:@"clientLevel" equalTo:@(1)];
            NSInteger bCount = [query1 countObjects];
            [weakSelf.typeArray addObject:@[@"B",@(bCount)]];
            
            [query1 whereKey:@"clientLevel" equalTo:@(2)];
            NSInteger cCount = [query1 countObjects];
            [weakSelf.typeArray addObject:@[@"C",@(cCount)]];
            
            [query1 whereKey:@"clientLevel" equalTo:@(3)];
            NSInteger dCount = [query1 countObjects];
            [weakSelf.typeArray addObject:@[@"D",@(dCount)]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.sortTable headerEndRefreshing];
                [weakSelf.sortTable reloadData];
            });
        });
    }else {
        [PopView showWithImageName:@"error" message:SetTitle(@"no_connect")];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.currentPage == 0) {
        return self.dataArray.count + 1;
    }else{
        return self.typeArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.currentPage == 0) {
        static NSString * CellIdentifier = @"sort_cell";
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                
            }
            
            UIView *sv = [cell.contentView viewWithTag:100099];
            [sv.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [sv removeFromSuperview];
            UIView *customView = [[UIView alloc] initWithFrame:cell.contentView.frame];
            customView.tag = 100099;
            customView.backgroundColor = [UIColor clearColor];
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 25, 25)];
            img.image = [Utility getImgWithImageName:@"stock_warnning_icon@2x"];
            [customView addSubview:img];
            
            UILabel *stockWarnLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 12, 100, 21)];
            stockWarnLabel.text = SetTitle(@"stock_warning");
            stockWarnLabel.adjustsFontSizeToFitWidth = YES;
            stockWarnLabel.textColor = [UIColor whiteColor];
            [customView addSubview:stockWarnLabel];
            
            UILabel *sortNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(221, 12, 49, 21)];
            sortNumLabel.textColor = [UIColor whiteColor];
            sortNumLabel.text = [NSString stringWithFormat:@"%d",(int)self.waringCount];
            sortNumLabel.textAlignment = NSTextAlignmentRight;
            [customView addSubview:sortNumLabel];
            
            cell.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:customView];
            return cell;
        }else{
            SortCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sort_cell2"];
            if (cell == nil) {
                NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SortCell" owner:self options:nil];
                cell = (SortCell *)[array objectAtIndex:0];
            }
            
            id object = self.dataArray[indexPath.row-1];
            if ([object isKindOfClass:[NSArray class]]) {
                [cell setResultArray:self.dataArray[indexPath.row-1]];
            }else if ([object isKindOfClass:[SortModel class]]){
                SortModel *sortModel = (SortModel *)self.dataArray[indexPath.row-1];
                [cell setSortModel:sortModel];

            }

            return cell;
        }
    }else{
        SortCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sort_cell2"];
        if (cell == nil) {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SortCell" owner:self options:nil];
            cell = (SortCell *)[array objectAtIndex:0];
        }
        
        [cell setResultArray:self.typeArray[indexPath.row]];
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.currentPage==0) {
        [self.drawer close];
        if (indexPath.row == self.previousRowProduct){
        }else {
            if (indexPath.row<3) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"fliterProductDataWithNotification" object:[NSString stringWithFormat:@"%d",(int)indexPath.row]];
            }else {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"fliterProductDataWithNotification" object:@[[NSString stringWithFormat:@"%d",(int)-100],self.dataArray[indexPath.row-1]]];
            }
        }
        self.previousRowProduct = indexPath.row;
    }else {
        [self.drawer close];
        if (indexPath.row == self.previousRowClient){
        }else {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"fliterDataWithNotification" object:[NSString stringWithFormat:@"%d",(int)indexPath.row]];
        }
        self.previousRowClient = indexPath.row;
    }
}

-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [self.sortTable resignFirstResponder];
}

///segment切换
-(IBAction)leftBtnPressed:(id)sender
{
    if (self.currentPage==0) {
        [self.drawer close];
        if (self.previousRowProduct==-1) {
        }else {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"fliterProductDataWithNotification" object:[NSString stringWithFormat:@"%d",-1]];
        }
        self.previousRowProduct=-1;
    }else {
        [self.drawer close];
        if (self.previousRowClient==5){
        }else {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"fliterDataWithNotification" object:[NSString stringWithFormat:@"%d",5]];
        }
        self.previousRowClient = 5;
    }
}
-(IBAction)rightBtnPressed:(id)sender{
    if (self.currentPage==0) {
        [self.drawer close];
        if (self.previousRowProduct==-2) {
        }else {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"fliterProductDataWithNotification" object:[NSString stringWithFormat:@"%d",-2]];
        }
        self.previousRowProduct=-2;
    }else {
        [self.drawer close];
        if (self.previousRowClient == 6){
        }else {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"fliterDataWithNotification" object:[NSString stringWithFormat:@"%d",6]];
        }
        self.previousRowClient = 6;
    }
}
#pragma mark - ICSDrawerControllerPresenting

- (void)drawerControllerWillOpen:(ICSDrawerController *)drawerController {
    self.view.userInteractionEnabled = NO;
}

- (void)drawerControllerDidOpen:(ICSDrawerController *)drawerController {
    self.view.userInteractionEnabled = YES;
}

- (void)drawerControllerWillClose:(ICSDrawerController *)drawerController {
    self.view.userInteractionEnabled = NO;
}

- (void)drawerControllerDidClose:(ICSDrawerController *)drawerController {
    self.view.userInteractionEnabled = YES;
}


@end
