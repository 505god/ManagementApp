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
    
    //检测登录与否
    AVUser *user = [AVUser currentUser];
    
    if (user != nil) {
        [[AVUser currentUser] refresh];
        
        BOOL isCheck = NO;
        if ([user.objectId isEqualToString:MainId]) {
            
        }else {
            isCheck = YES;
        }
        
        if (isCheck) {
            NSInteger dayNum = [[[AVUser currentUser] objectForKey:@"day"] integerValue];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *components = [gregorian components:NSDayCalendarUnit fromDate:[AVUser currentUser].createdAt toDate:[NSDate date] options:0];
            
            NSInteger day = [components day];
            
            if (dayNum-day<=0) {
                [[AVUser currentUser] setObject:[NSNumber numberWithBool:true] forKey:@"expire"];
                [[AVUser currentUser] saveEventually];
                
                [AVUser logOut];  //清除缓存用户对象
                
                [self performSelectorOnMainThread:@selector(loadLoginx) withObject:nil waitUntilDone:NO];
            }else {
                __weak __typeof(self)weakSelf = self;
                [[LeanChatManager manager] openSessionWithClientID:[AVUser currentUser].username completion:^(BOOL succeeded, NSError *error) {
                    [weakSelf performSelectorOnMainThread:@selector(loadRootVC) withObject:nil waitUntilDone:NO];
                }];
            }
        }else {
            __weak __typeof(self)weakSelf = self;
            [[LeanChatManager manager] openSessionWithClientID:[AVUser currentUser].username completion:^(BOOL succeeded, NSError *error) {
                [weakSelf performSelectorOnMainThread:@selector(loadRootVC) withObject:nil waitUntilDone:NO];
            }];
        }
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
