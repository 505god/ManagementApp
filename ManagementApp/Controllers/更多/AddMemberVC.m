//
//  AddMemberVC.m
//  ManagementApp
//
//  Created by 邱成西 on 2016/11/17.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "AddMemberVC.h"

@interface AddMemberVC ()<UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *nameText;
@property (nonatomic, weak) IBOutlet UITextField *pwdText;

@property (nonatomic, strong) DeformationButton *registerBtn;

@property (nonatomic, weak) IBOutlet UILabel *label1;
@property (nonatomic, weak) IBOutlet UILabel *label2;
@end

@implementation AddMemberVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
    
    [self setText];
}

-(void)setNavBarView {
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.navBarView setTitle:SetTitle(@"member") image:nil];
    [self.view addSubview:self.navBarView];
}

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setText {
    self.label1.text = SetTitle(@"nick_name");
    self.label2.text = SetTitle(@"log_pwd");
    
    [self.nameText setPlaceholder:SetTitle(@"company_name")];
    [self.pwdText setPlaceholder:SetTitle(@"log_pwd")];
    
    [self registerBtn];
}

-(DeformationButton *)registerBtn {
    if (!_registerBtn) {
        _registerBtn = [[DeformationButton alloc]initWithFrame:(CGRect){15,303,SCREEN_WIDTH-30,40} withColor:kThemeColor];
        [_registerBtn.forDisplayButton setTitle:SetTitle(@"finish") forState:UIControlStateNormal];
        [_registerBtn addTarget:self action:@selector(registerBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_registerBtn];
    }
    return _registerBtn;
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.registerBtn stopLoading];
}

-(IBAction)registerBtnPressed:(id)sender {
    [self.view endEditing:YES];
    
    if (self.nameText.text.length==0) {
        //企业名称
        [PopView showWithImageName:nil message:SetTitle(@"company_name_error")];
        return;
    }
    
    if (![self checkPassWord]) {
        //密码6-20位数字和字母组成
        [PopView showWithImageName:nil message:SetTitle(@"pwd_error")];
        return;
    }
    if ([[[AVUser currentUser] objectForKey:@"members"]integerValue]<=0) {
        [PopView showWithImageName:nil message:SetTitle(@"member_error")];
        return;
    }
    if ([DataShare sharedService].appDel.isReachable) {
        [self.registerBtn startLoading];
        self.registerBtn.enabled = NO;
        QWeakSelf(self);
        
        AVQuery *query = [AVQuery queryWithClassName:@"Member"];
        [query whereKey:@"user" equalTo:[AVUser currentUser]];
        [query whereKey:@"username" equalTo:self.nameText.text];
        NSInteger count = [query countObjects];
        if (count>0) {
            [PopView showWithImageName:nil message:SetTitle(@"mem_name_error")];
            
            return;
        }
        
        AVObject *post = [AVObject objectWithClassName:@"Member"];
        
        [post setObject:self.nameText.text forKey:@"username"];
        [post setObject:self.pwdText.text forKey:@"password"];
        [post setObject:[AVUser currentUser] forKey:@"user"];
        
        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [weakself.registerBtn stopLoading];
            weakself.registerBtn.enabled = YES;
            [[AVUser currentUser] incrementKey:@"members" byAmount:[NSNumber numberWithInt:-1]];
            [[AVUser currentUser] saveInBackground];
            [[AVUser currentUser] refresh];
            
            if (weakself.completedBlock) {
                weakself.completedBlock(succeeded);
            }
            
            [weakself.navigationController popViewControllerAnimated:YES];
        }];
    }else {
        [PopView showWithImageName:nil message:SetTitle(@"no_connect")];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)checkPassWord {
    //6-20位数字和字母组成
    NSString *regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,20}$";
    NSPredicate *   pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([pred evaluateWithObject:self.pwdText.text]) {
        return YES ;
    }else
        return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.nameText) {
        [self.pwdText becomeFirstResponder];
    }else if (textField == self.pwdText){
        [self.pwdText resignFirstResponder];
    }
    return YES;
}
@end
