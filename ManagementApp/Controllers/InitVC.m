//
//  InitVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "InitVC.h"

#import "VerifiedVC.h"

@interface InitVC ()

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* activityView;

@end

@implementation InitVC

#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AVQuery *query = [AVQuery queryWithClassName:@"Apple"];
    AVObject *object = [query getFirstObject];
    [DataShare sharedService].escape = [[object objectForKey:@"escape"]integerValue];
    
//    [self performSelectorOnMainThread:@selector(loadLogin) withObject:nil waitUntilDone:NO];

    
    //检测登录与否
    AVUser *user = [AVUser currentUser];
    
    if (user != nil) {
        [[AVUser currentUser] refresh];
        
        [[AppDelegate shareInstance] saveUserInfo];
        
        [self performSelectorOnMainThread:@selector(loadRootVC) withObject:nil waitUntilDone:NO];
    }else {
        [self performSelectorOnMainThread:@selector(loadLogin) withObject:nil waitUntilDone:NO];
    }
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

- (void)loadLoginx {
    [[AppDelegate shareInstance]showRootVCWithType:2];
}
@end
