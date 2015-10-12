//
//  InitVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "InitVC.h"

@interface InitVC ()

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* activityView;

@end

@implementation InitVC

#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //TODO:检测登录与否
    
    [self performSelectorOnMainThread:@selector(loadRootVC) withObject:nil waitUntilDone:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.activityView startAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 加载VC

- (void)loadRootVC {
    [[AppDelegate shareInstance]showRootVCWithType:1];
}

- (void)loadLogin {
    [[AppDelegate shareInstance]showRootVCWithType:0];
}


@end
