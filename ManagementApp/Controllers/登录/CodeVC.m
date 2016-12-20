//
//  CodeVC.m
//  ManagementApp
//
//  Created by 邱成西 on 16/10/24.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "CodeVC.h"

@interface CodeVC ()<UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel *label0;
@property (nonatomic, weak) IBOutlet UILabel *phoneLab;
@property (nonatomic, weak) IBOutlet UIView *line1;
@property (nonatomic, weak) IBOutlet UILabel *label1;
@property (nonatomic, weak) IBOutlet UITextField *codeText;

@property (nonatomic, strong) DeformationButton *finishBtn;

@end

@implementation CodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
    
    [self setText];
    
//    self.phoneLab.text = [NSString stringWithFormat:@"%@ %@",[DataShare sharedService].userObject.zone,[DataShare sharedService].userObject.phone];
    
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.label0.text];
    
    NSRange range = [self.label0.text rangeOfString:SetTitle(@"code")];
    [attributedString addAttribute:NSForegroundColorAttributeName value:kThemeColor range:range];
    self.label0.attributedText = attributedString;
}

-(void)setNavBarView {
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.navBarView setTitle:SetTitle(@"code_input") image:nil];
    [self.view addSubview:self.navBarView];
}

-(void)setText {
    self.label0.text = SetTitle(@"code_info");
    self.label1.text = SetTitle(@"code");
    [self.codeText setPlaceholder:SetTitle(@"code")];
    
    [self finishBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.finishBtn stopLoading];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.line1.backgroundColor = kThemeColor;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.line1.backgroundColor = kLightGrayColor;
}


#pragma mark - setter/getter

-(DeformationButton *)finishBtn {
    if (!_finishBtn) {
        _finishBtn = [[DeformationButton alloc]initWithFrame:(CGRect){15,264,SCREEN_WIDTH-30,40} withColor:kThemeColor];
        [_finishBtn.forDisplayButton setTitle:SetTitle(@"confirm") forState:UIControlStateNormal];
        [_finishBtn addTarget:self action:@selector(finishBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_finishBtn];
    }
    return _finishBtn;
}

#pragma mark - action

-(IBAction)finishBtnPressed:(id)sender {
    [self.finishBtn startLoading];
    self.finishBtn.enabled = NO;
    
    if (self.codeText.text.length==0) {
        [PopView showWithImageName:nil message:SetTitle(@"code_error")];
        return;
    }
    
    QWeakSelf(self);
    
    [AVUser verifyMobilePhone:self.codeText.text withBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [DataShare sharedService].userObject.phoneVerified = YES;
            
            [PopView showWithImageName:nil message:SetTitle(@"Verification_phone_ok")];
            
            [[AppDelegate shareInstance] showRootVCWithType:1];
        }
        
        [weakself.finishBtn stopLoading];
        weakself.finishBtn.enabled = YES;
    }];
}
@end
