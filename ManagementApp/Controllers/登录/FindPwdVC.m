//
//  FindPwdVC.m
//  ManagementApp
//
//  Created by 邱成西 on 16/10/26.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "FindPwdVC.h"

#import "XLTextField.h"

@interface FindPwdVC ()<XLEmailTextFieldDelegate>

@property (nonatomic, weak) IBOutlet XLTextField *emailText;

@property (nonatomic, weak) IBOutlet UIView *line1;
@property (nonatomic, weak) IBOutlet UILabel *label1;
@property (nonatomic, strong) DeformationButton *registerBtn;
@end

@implementation FindPwdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
    
    self.label1.text = SetTitle(@"email");
    [self.emailText setPlaceholder:SetTitle(@"email")];
    
    self.emailText.mailTypeArray = [NSMutableArray arrayWithObjects:@"@libero.it",@"@xxx.meh.es",@"@terra.es",@"@qq.com",@"@163.com",@"@126.com",@"@yahoo.com",@"@139.com", nil];
    self.emailText.customDelegate = self;
    
    [self registerBtn];
}

-(void)setNavBarView {
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.navBarView setTitle:SetTitle(@"find_pwd") image:nil];
    [self.view addSubview:self.navBarView];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.registerBtn stopLoading];
}

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setter/getter

-(DeformationButton *)registerBtn {
    if (!_registerBtn) {
        _registerBtn = [[DeformationButton alloc]initWithFrame:(CGRect){15,181,SCREEN_WIDTH-30,40} withColor:kThemeColor];
        [_registerBtn.forDisplayButton setTitle:SetTitle(@"register") forState:UIControlStateNormal];
        [_registerBtn addTarget:self action:@selector(registerBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_registerBtn];
    }
    return _registerBtn;
}

#pragma mark - UITextFieldDelegate
- (void)XLTextFieldDidBeginEditing:(UITextField *)textField{
    self.line1.backgroundColor = kThemeColor;
}

- (void)XLTextFieldDidEndEditing:(UITextField *)textField {
    self.line1.backgroundColor = kLightGrayColor;
}

#pragma mark - touchesBegan
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    
    self.line1.backgroundColor = kLightGrayColor;
}


-(IBAction)registerBtnPressed:(id)sender {
    [self.view endEditing:YES];
    
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *   pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![pred evaluateWithObject:self.emailText.text]){
        [PopView showWithImageName:nil message:SetTitle(@"erroremail")];
        return;
    }
    
    [self.registerBtn startLoading];
    self.registerBtn.enabled = NO;
    QWeakSelf(self);
    
    if ([DataShare sharedService].appDel.isReachable) {
        
        [AVUser requestPasswordResetForEmailInBackground:self.emailText.text block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [PopView showWithImageName:nil message:SetTitle(@"email_send")];
                
                
                [weakself.navigationController popViewControllerAnimated:YES];
            }
            
            [weakself.registerBtn stopLoading];
            weakself.registerBtn.enabled = YES;
            
        }];
        
    }else {
        [PopView showWithImageName:nil message:SetTitle(@"no_connect")];
    }
}
@end
