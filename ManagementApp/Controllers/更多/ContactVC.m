//
//  ContactVC.m
//  ManagementApp
//
//  Created by 邱成西 on 2016/11/18.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "ContactVC.h"
#import "UICustomerBtn.h"
@interface ContactVC ()

@property (nonatomic, weak) IBOutlet UIButton *phoneBtn;

@property (nonatomic, weak) IBOutlet UICustomerBtn *wxBtn;

@property (nonatomic, weak) IBOutlet UILabel *info1;
@property (nonatomic, weak) IBOutlet UILabel *info2;

@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *wx;
@end

@implementation ContactVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
     [self setNavBarView];
    
    AVQuery *query = [AVUser query];
    [query whereKey:@"type" equalTo:@(1)];
    AVUser *user = (AVUser *)[query getFirstObject];
    self.phone = user.mobilePhoneNumber;
    self.wx = [user objectForKey:@"wx"];
    
    [self.phoneBtn setTitle:SetTitle(@"contact_phone") forState:UIControlStateNormal];
    
    [self.wxBtn setTitle:[user objectForKey:@"wx"] forState:UIControlStateNormal];
    
    self.info1.text = [NSString stringWithFormat:@"%@:",SetTitle(@"log_phone")];
    
    self.info2.text = SetTitle(@"wechat");
}

-(void)setNavBarView {
    [self.navBarView setTitle:SetTitle(@"contact") image:nil];
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.view addSubview:self.navBarView];
}

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(IBAction)phonePressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.phone]];
}

-(IBAction)wxPressed:(id)sender {
    
    [self.wxBtn becomeFirstResponder];
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:self.wxBtn.frame inView:self.wxBtn.superview];
    [menu setMenuVisible:YES animated:YES];
}
@end
