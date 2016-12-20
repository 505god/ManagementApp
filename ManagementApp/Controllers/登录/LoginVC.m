//
//  LoginVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/13.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "LoginVC.h"
#import "CALayer+color.h"

#import "RegisterVC.h"
#import "FindPwdVC.h"
@interface LoginVC ()<UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel *login_title_info;
@property (nonatomic, weak) IBOutlet UIView *line1;
@property (nonatomic, weak) IBOutlet UIView *line2;
@property (nonatomic, weak) IBOutlet UILabel *label1;
@property (nonatomic, weak) IBOutlet UILabel *label2;
@property (nonatomic, weak) IBOutlet UITextField *userText;
@property (nonatomic, weak) IBOutlet UITextField *passwordText;

@property (nonatomic, weak) IBOutlet UIButton *pwdBtn;
@property (nonatomic, weak) IBOutlet UIButton *registerBtn;
@property (nonatomic, strong) DeformationButton *loginBtn;
@end

@implementation LoginVC

#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setText];
}

-(void)setText {
    self.login_title_info.text = SetTitle(@"login_title_info");
    
    self.label1.text = SetTitle(@"log_account");
    self.label2.text = SetTitle(@"log_pwd");
    
    [self.userText setPlaceholder:SetTitle(@"log_account_phone")];
    [self.passwordText setPlaceholder:SetTitle(@"log_pwd")];
    
    
    [self.registerBtn setTitle:SetTitle(@"register") forState:UIControlStateNormal];
    [self.pwdBtn setTitle:SetTitle(@"forget_pwd") forState:UIControlStateNormal];
    
    [self loginBtn];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if ([DataShare sharedService].escape==0) {
        self.registerBtn.hidden = YES;
        self.pwdBtn.hidden = YES;
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.loginBtn stopLoading];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setter/getter

-(DeformationButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [[DeformationButton alloc]initWithFrame:(CGRect){15,347,SCREEN_WIDTH-30,40} withColor:kThemeColor];
        [_loginBtn.forDisplayButton setTitle:SetTitle(@"log_in") forState:UIControlStateNormal];
        [_loginBtn addTarget:self action:@selector(loginBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_loginBtn];
    }
    return _loginBtn;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.userText) {
        self.line1.backgroundColor = kThemeColor;
        self.line2.backgroundColor = kLightGrayColor;
    } else {
        self.line1.backgroundColor = kLightGrayColor;
        self.line2.backgroundColor = kThemeColor;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.userText) {
        self.line1.backgroundColor = kLightGrayColor;
    } else {
        self.line2.backgroundColor = kLightGrayColor;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userText) {
        return [self.passwordText becomeFirstResponder];
    } else {
        return [self.passwordText resignFirstResponder];
    }
}

#pragma mark - touchesBegan
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    
    self.line1.backgroundColor = kLightGrayColor;
    self.line2.backgroundColor = kLightGrayColor;
}

#pragma mark - action

-(IBAction)registerBtnPressed:(id)sender {
    [self.view endEditing:YES];
    
    RegisterVC *vc = LOADVC(@"RegisterVC");
    [self.navigationController pushViewController:vc animated:YES];
    SafeRelease(vc);
}

-(void)loginBtnPressed:(id)sender {
    [self.view endEditing:YES];
    
    if (self.userText.text.length==0) {
        //帐号
        [PopView showWithImageName:nil message:SetTitle(@"company_name_error")];
        return;
    }
    
    if (![self checkPassWord]) {
        //密码6-20位数字和字母组成
        [PopView showWithImageName:nil message:SetTitle(@"pwd_error")];
        return;
    }
    
    if ([DataShare sharedService].appDel.isReachable) {
        self.loginBtn.enabled = NO;
        [self.loginBtn startLoading];
        
        QWeakSelf(self);
        [AVUser logInWithUsernameInBackground:self.userText.text password:self.passwordText.text block:^(AVUser *user, NSError *error) {
            if (!error) {
                //登录成功---数据缓存到本地
                [AVUser changeCurrentUser:user save:YES];
                
                [[AppDelegate shareInstance] saveUserInfo];
                
                [[AppDelegate shareInstance] showRootVCWithType:1];
            }else {
                [PopView showWithImageName:@"error" message:SetTitle(@"log_error")];
            }
            
            weakself.loginBtn.enabled = YES;
            [weakself.loginBtn stopLoading];
        }];
    }else {
        [PopView showWithImageName:@"error" message:SetTitle(@"no_connect")];
    }
}

-(BOOL)checkPassWord {
    //6-20位数字和字母组成
    NSString *regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,20}$";
    NSPredicate *   pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([pred evaluateWithObject:self.passwordText.text]) {
        return YES ;
    }else
        return NO;
}

-(IBAction)findPwdPressed:(id)sender {
    
    [self.view endEditing:YES];
    
    FindPwdVC *vc = LOADVC(@"FindPwdVC");
    [self.navigationController pushViewController:vc animated:YES];
    SafeRelease(vc);
}
@end
