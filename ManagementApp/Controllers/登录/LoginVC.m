//
//  LoginVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/13.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "LoginVC.h"
//#import "PopView.h"
#import "CALayer+color.h"

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
    
    if ([DataShare sharedService].appDel.isReachable) {
        if ([Utility checkString:[NSString stringWithFormat:@"%@",self.userText.text]]) {
            if ([Utility checkString:[NSString stringWithFormat:@"%@",self.passwordText.text]]){
                
                [self.view endEditing:YES];
                
                ///接口请求
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                __weak __typeof(self)weakSelf = self;
                
                [AVUser logInWithMobilePhoneNumberInBackground:self.userText.text password:self.passwordText.text block:^(AVUser *user, NSError *error) {
                    if (!error) {
                        
                        BOOL isCheck = NO;
                        if ([user.objectId isEqualToString:MainId]) {
                            
                        }else {
                            isCheck = YES;
                        }
                        
                        BOOL expire = [[user objectForKey:@"expire"] boolValue];
                        if (expire && isCheck) {
                            [AVUser logOut];  //清除缓存用户对象
                            [PopView showWithImageName:@"error" message:SetTitle(@"Company_expire")];
                            return;
                        }else {
                            if (isCheck) {
                                NSInteger dayNum = [[user objectForKey:@"day"] integerValue];
                                
                                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                                NSDateComponents *components = [gregorian components:NSDayCalendarUnit fromDate:[AVUser currentUser].createdAt toDate:[NSDate date] options:0];
                                
                                NSInteger day = [components day];
                                
                                if (dayNum-day<=0) {
                                    user[@"expire"] = [NSNumber numberWithBool:true];
                                    [user saveInBackground];
                                    [AVUser logOut];  //清除缓存用户对象
                                    
                                    [PopView showWithImageName:@"error" message:SetTitle(@"Company_expire")];
                                    return;
                                }
                            }
                        }
                        
                        AVInstallation *installation = [AVInstallation currentInstallation];
                        [installation setObject:user.objectId forKey:@"cid"];
                        [installation saveInBackground];
                        
                        //登录成功---数据缓存到本地
                        [AVUser changeCurrentUser:user save:YES];

                        [[LeanChatManager manager] openSessionWithClientID:[AVUser currentUser].username completion:^(BOOL succeeded, NSError *error) {
                            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                            [[AppDelegate shareInstance] showRootVCWithType:1];
                        }];
                    }else {
                        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                        [PopView showWithImageName:@"error" message:SetTitle(@"log_error")];
                    }
                }];
            }else {
                [PopView showWithImageName:@"" message:SetTitle(@"logInPwdError")];
            }
        }else {
            [PopView showWithImageName:@"" message:SetTitle(@"logInNameError")];
        }
    }else {
        [PopView showWithImageName:@"error" message:SetTitle(@"no_connect")];
    }
}
@end
