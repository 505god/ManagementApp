//
//  ProductDetailVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/23.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ProductDetailVC.h"

#import "ProductVC.h"

@interface ProductDetailVC ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation ProductDetailVC
-(void)dealloc {
    SafeRelease(_tableView);
}
#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
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
    
//    [self.tableView registerClass:[ProductHeader class] forHeaderFooterViewReuseIdentifier:@"ProductHeader"];
}

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    ProductVC *proVC = [[ProductVC alloc]init];
    proVC.productModel = self.productModel;
    [self.navigationController pushViewController:proVC animated:YES];
    SafeRelease(proVC);
}
@end
