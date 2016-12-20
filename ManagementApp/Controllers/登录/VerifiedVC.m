//
//  VerifiedVC.m
//  ManagementApp
//
//  Created by 邱成西 on 16/10/25.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "VerifiedVC.h"

#import "CodeVC.h"

@interface VerifiedVC ()

@property (nonatomic, strong) DeformationButton *emailBtn;
@property (nonatomic, weak) IBOutlet UILabel *label2;

@property (nonatomic, strong) NSTimer *timer;
@end

@implementation VerifiedVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];

    self.label2.text = SetTitle(@"Verification_email_info");

    [self emailBtn];
    
    [self checkData];
}

-(void)checkData {
    //邮箱
    if ([AVUser currentUser].email != nil) {
        if ([[[AVUser currentUser] objectForKey:@"emailVerified"]boolValue]) {
            self.emailBtn.enabled = NO;
            [self.emailBtn.forDisplayButton setTitle:SetTitle(@"Verification_email_ok") forState:UIControlStateNormal];
        }
    }else {
        [self.emailBtn.forDisplayButton setTitle:SetTitle(@"Verification_email_false") forState:UIControlStateNormal];
        self.emailBtn.enabled = NO;
        
//        self.label2.text = SetTitle(@"Verification_email_false_info");
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setNavBarView {
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.navBarView setTitle:SetTitle(@"Verification") image:nil];
//    [self.navBarView setRightWithArray:@[SetTitle(@"skip")] type:1];
    [self.view addSubview:self.navBarView];
}

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    [[AppDelegate shareInstance] showRootVCWithType:1];
}

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {

    [[AppDelegate shareInstance] showRootVCWithType:1];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.emailBtn stopLoading];
}

#pragma mark - setter/getter

-(DeformationButton *)emailBtn {
    if (!_emailBtn) {
        _emailBtn = [[DeformationButton alloc]initWithFrame:(CGRect){15,95,SCREEN_WIDTH-30,40} withColor:kThemeColor];
        [_emailBtn.forDisplayButton setTitle:SetTitle(@"Verification_email") forState:UIControlStateNormal];
        [_emailBtn addTarget:self action:@selector(emailBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_emailBtn];
    }
    return _emailBtn;
}

-(void)emailBtnPressed:(id)sender {
    [self.emailBtn startLoading];
    self.emailBtn.enabled = NO;
    
    QWeakSelf(self);
    
    [AVUser requestEmailVerify:[AVUser currentUser].email withBlock:^(BOOL succeeded, NSError *error) {
        
        if (!error) {
            [PopView showWithImageName:nil message:SetTitle(@"email_send")];
            
            //定时刷新user
            weakself.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(reloadUser) userInfo:nil repeats:YES];
        }
    }];
}

-(void)reloadUser {
    [[AVUser currentUser] refresh];
    
    UserModel *user = [UserModel initWithObject:[AVUser currentUser]];
    
    [DataShare sharedService].userObject = user;
    
    if ([DataShare sharedService].userObject.emailVerified) {
        [self.timer invalidate];
        self.timer = nil;
        [self.emailBtn stopLoading];
        
        [PopView showWithImageName:nil message:SetTitle(@"Verification_email_ok")];
        [[AppDelegate shareInstance] showRootVCWithType:1];
    }
}


@end
