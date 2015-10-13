//
//  LoginVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/13.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "LoginVC.h"
//#import "PopView.h"

@interface LoginVC ()<UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *userText;
@property (nonatomic, weak) IBOutlet UITextField *passwordText;

@property (nonatomic, weak) IBOutlet UIButton *loginBtn;
@end

@implementation LoginVC

#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.userText setPlaceholder:SetTitle(@"log_account")];
    [self.passwordText setPlaceholder:SetTitle(@"log_pwd")];
    [self.loginBtn setTitle:SetTitle(@"log_in") forState:UIControlStateNormal];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.userText becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

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
}

#pragma mark - action

-(IBAction)loginBtnPressed:(id)sender {
    
    if ([Utility checkString:[NSString stringWithFormat:@"%@",self.userText.text]]) {
        if ([Utility checkString:[NSString stringWithFormat:@"%@",self.passwordText.text]]){
            
            [self.view endEditing:YES];
            
            ///接口请求
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            __weak __typeof(self)weakSelf = self;
            [[APIClient sharedClient] POST:loginInterface parameters:@{} success:^(NSURLSessionDataTask *task, id responseObject) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
                
                NSDictionary *jsonData=(NSDictionary *)responseObject;
                
                
                ///登录成功
                [[AppDelegate shareInstance]showRootVCWithType:1];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
                
                [PopView showWithImageName:@"alert_sigh" message:SetTitle(@"connect_error")];
            }];
            
        }else {
            [PopView showWithImageName:@"" message:SetTitle(@"logInPwdError")];
        }
    }else {
        [PopView showWithImageName:@"" message:SetTitle(@"logInNameError")];
    }
}
@end
