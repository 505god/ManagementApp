//
//  OptionsVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "OptionsVC.h"

#import "RETableViewManager.h"

#import "ClassifyVC.h"
#import "MaterialVC.h"
#import "ColorVC.h"
#import "CompanyVC.h"
#import "StaticVC.h"
#import "AgentVC.h"
#import "ContactVC.h"

@interface OptionsVC ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) RETableViewManager *manager;


@end

@implementation OptionsVC

#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
#pragma mark - UI

-(void)setNavBarView {
    [self.navBarView setTitle:SetTitle(@"navicon_options") image:nil];
    [self.view addSubview:self.navBarView];
    
    [self setTableView];
    
    [Utility setExtraCellLineHidden:self.tableView];
}

-(void)setTableView {
    self.tableView = [[UITableView alloc]initWithFrame:(CGRect){0,self.navBarView.bottom,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height-self.navBarView.bottom} style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    
    // Create manager
    self.manager = [[RETableViewManager alloc] initWithTableView:self.tableView];
    
    __weak __typeof(self)weakSelf = self;
    
    //------------------------------------------------------------------
    RETableViewSection *section = [RETableViewSection section];
    [self.manager addSection:section];
    //分类
    RERadioItem *classifyItem = [RERadioItem itemWithTitle:SetTitle(@"classify") value:@"" selectionHandler:^(RERadioItem *item) {
        [item deselectRowAnimated:YES];
        
        ClassifyVC *classifyVC = [[ClassifyVC alloc]init];
        classifyVC.isSelectedClassify = NO;
        [weakSelf.navigationController pushViewController:classifyVC animated:YES];
        SafeRelease(classifyVC);
        
    }];
    [section addItem:classifyItem];
    
    //材质
    RERadioItem *materialItem = [RERadioItem itemWithTitle:SetTitle(@"material") value:@"" selectionHandler:^(RERadioItem *item) {
        [item deselectRowAnimated:YES];
        
        MaterialVC *materialVC = [[MaterialVC alloc]init];
        materialVC.isSelectedMaterial = NO;
        [weakSelf.navigationController pushViewController:materialVC animated:YES];
        SafeRelease(materialVC);
        
    }];
    [section addItem:materialItem];
    
    //颜色
    RERadioItem *colorItem = [RERadioItem itemWithTitle:SetTitle(@"color") value:@"" selectionHandler:^(RERadioItem *item) {
        [item deselectRowAnimated:YES];
        
        ColorVC *colorVC = [[ColorVC alloc]init];
        colorVC.isSelectedColor = NO;
        [weakSelf.navigationController pushViewController:colorVC animated:YES];
        SafeRelease(colorVC);
        
    }];
    [section addItem:colorItem];
    
    RETableViewSection *section10 = [RETableViewSection section];
    section10.headerHeight = 10;
    [self.manager addSection:section10];
    RERadioItem *staticItem = [RERadioItem itemWithTitle:SetTitle(@"statistics") value:@"" selectionHandler:^(RERadioItem *item) {
        [item deselectRowAnimated:YES];
        
        StaticVC *colorVC = LOADVC(@"StaticVC");
        [weakSelf.navigationController pushViewController:colorVC animated:YES];
        SafeRelease(colorVC);
        
    }];
    [section10 addItem:staticItem];
    
    RETableViewSection *section2 = [RETableViewSection section];
    [self.manager addSection:section2];
    section2.headerHeight = 10;
    //公司
    RERadioItem *companyItem = [RERadioItem itemWithTitle:SetTitle(@"Company") value:@"" selectionHandler:^(RERadioItem *item) {
        [item deselectRowAnimated:YES];
        
        CompanyVC *vc = [[CompanyVC alloc]init];
        [weakSelf.navigationController pushViewController:vc animated:YES];
        SafeRelease(vc);
        
    }];
    [section2 addItem:companyItem];
    
    if ([DataShare sharedService].userObject.type==1) {
        RETableViewSection *section4 = [RETableViewSection section];
        [self.manager addSection:section4];
        section4.headerHeight = 10;
        //代理列表
        RERadioItem *agentItem = [RERadioItem itemWithTitle:SetTitle(@"agent") value:@"" selectionHandler:^(RERadioItem *item) {
            [item deselectRowAnimated:YES];
            
            AgentVC *vc = [[AgentVC alloc]init];
            [weakSelf.navigationController pushViewController:vc animated:YES];
            vc = nil;
        }];
        [section4 addItem:agentItem];
    }
    
    
    if ([DataShare sharedService].userObject.type!=1) {
        RETableViewSection *section13 = [RETableViewSection section];
        section13.headerHeight = 10;
        [self.manager addSection:section13];
        RERadioItem *pwdItem = [RERadioItem itemWithTitle:SetTitle(@"contact") value:@"" selectionHandler:^(RERadioItem *item) {
            [item deselectRowAnimated:YES];
            
            ContactVC *vc = LOADVC(@"ContactVC");
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }];
        [section13 addItem:pwdItem];
    }
    
    //------------------------------------------------------------------
    RETableViewSection *section3 = [RETableViewSection section];
    [self.manager addSection:section3];
    section3.headerHeight = 10;
    
    RETableViewItem *buttonItem = [RETableViewItem itemWithTitle:SetTitle(@"log_out") accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"log_out_info") message:nil preferredStyle:UIAlertControllerStyleAlert];
        [weakSelf addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
            [AVUser logOut];  //清除缓存用户对象
            [Utility dataShareClear];
            
            [weakSelf performSelectorOnMainThread:@selector(loadLogin) withObject:nil waitUntilDone:NO];
        }];
        [weakSelf addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
        [weakSelf presentViewController:alert animated:YES completion:nil];
        
    }];
    buttonItem.titleColor = kDeleteColor;
    buttonItem.textAlignment = NSTextAlignmentCenter;
    [section3 addItem:buttonItem];
}

- (void)loadLogin {
    [[AppDelegate shareInstance]showRootVCWithType:0];
}
@end
