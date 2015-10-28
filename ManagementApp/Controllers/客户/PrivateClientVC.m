//
//  PrivateClientVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/28.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "PrivateClientVC.h"
#import "BlockActionSheet.h"
#import "BlockAlertView.h"
#import <MessageUI/MFMessageComposeViewController.h>

@interface PrivateClientVC ()<MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *optionLab;
@property (weak, nonatomic) IBOutlet UILabel *commandLab;
@property (weak, nonatomic) IBOutlet UIButton *changeBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *priceBtn;
@property (weak, nonatomic) IBOutlet UIButton *memberBtn;

@end

@implementation PrivateClientVC

-(void)dealloc {

}

#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavBarView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

-(void)setNavBarView {
    
    //左侧名称显示的分类名称
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.navBarView setTitle:SetTitle(@"private_client") image:nil];

    [self.view addSubview:self.navBarView];
    
    [self setXibData];
}

-(void)setXibData {
    self.nameLab.text = self.clientModel.clientName;
    
    if (self.clientModel.isCommand) {
        self.optionLab.text = SetTitle(@"command_use");
        
        [self.memberBtn setTitle:SetTitle(@"member_disable") forState:UIControlStateNormal];
    }else {
        self.optionLab.text = SetTitle(@"command_unuse");
        
        [self.memberBtn setTitle:SetTitle(@"member_enable") forState:UIControlStateNormal];
    }
    
    self.commandLab.text = self.clientModel.command;
    
    [self.changeBtn setTitle:SetTitle(@"command_change") forState:UIControlStateNormal];
    
    [self.sendBtn setTitle:SetTitle(@"command_send") forState:UIControlStateNormal];
    
    if (self.clientModel.isShowPrice) {
        [self.priceBtn setTitle:SetTitle(@"price_show") forState:UIControlStateNormal];
    }else {
        [self.priceBtn setTitle:SetTitle(@"price_unshow") forState:UIControlStateNormal];
    }
}
#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - action

-(IBAction)changeCommandPressed:(id)sender {
    
}

-(IBAction)sendCommandPressed:(id)sender {
    __weak __typeof(self)weakSelf = self;
    
    BlockActionSheet *sheet = [[BlockActionSheet alloc]initWithTitle:nil];
    [sheet addButtonWithTitle:SetTitle(@"sheet_sms") block:^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText])
        {
            controller.body = [NSString stringWithFormat:@"%@:%@",SetTitle(@"command"),weakSelf.clientModel.command];
            controller.recipients = @[weakSelf.clientModel.clientPhone];
            controller.messageComposeDelegate = weakSelf;
            [weakSelf presentViewController:controller animated:YES completion:^{
                [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
            }];
        }
    }];
    [sheet addButtonWithTitle:SetTitle(@"sheet_message") block:^{
        
    }];
    [sheet setCancelButtonWithTitle:SetTitle(@"cancel") block:^{
        
    }];
    [sheet showInView:self.view];
}

-(IBAction)priceBtnPressed:(id)sender {
    
}

-(IBAction)membershipBtnPressed:(id)sender {
    
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (result == MessageComposeResultCancelled){
        DLog(@"Message cancelled");
    }else if (result == MessageComposeResultSent) {
        
    }
}
@end
