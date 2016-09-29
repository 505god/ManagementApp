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

#import "LeanChatMessageTableViewController.h"
#import "AVIMConversation+Custom.h"

@interface PrivateClientVC ()<MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *optionLab;
@property (weak, nonatomic) IBOutlet UILabel *commandLab;
@property (weak, nonatomic) IBOutlet UIButton *changeBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *priceBtn;
@property (weak, nonatomic) IBOutlet UIButton *stockBtn;
@property (weak, nonatomic) IBOutlet UIButton *memberBtn;

@end

@implementation PrivateClientVC

-(void)dealloc {
    SafeRelease(_nameLab);
    SafeRelease(_optionLab);
    SafeRelease(_commandLab);
    SafeRelease(_changeBtn);
    SafeRelease(_sendBtn);
    SafeRelease(_priceBtn);
    SafeRelease(_memberBtn);
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
    [self.navBarView setTitle:self.clientModel.isPrivate?SetTitle(@"private_client"):SetTitle(@"unprivate_client") image:nil];

    [self.view addSubview:self.navBarView];
    
    [self setXibData];
}

-(void)setXibData {
    self.nameLab.text = self.clientModel.clientName;
    
    if (!self.clientModel.disable) {
        if (self.clientModel.isCommand) {
            self.optionLab.text = SetTitle(@"command_use");
            
            [self.memberBtn setTitle:SetTitle(@"member_disable") forState:UIControlStateNormal];
        }else {
            self.optionLab.text = SetTitle(@"command_unuse");
            
            [self.memberBtn setTitle:SetTitle(@"member_disable") forState:UIControlStateNormal];
        }
    }else {
        self.optionLab.text = SetTitle(@"command_disabled");
        
        [self.memberBtn setTitle:SetTitle(@"member_enable") forState:UIControlStateNormal];
    }
    
    
    self.commandLab.text = self.clientModel.command;
    
    [self.changeBtn setTitle:SetTitle(@"command_change") forState:UIControlStateNormal];
    
    self.sendBtn.userInteractionEnabled = !self.clientModel.disable;
    [self.sendBtn setTitle:SetTitle(@"command_send") forState:UIControlStateNormal];
    
    if (self.clientModel.isShowPrice) {
        [self.priceBtn setTitle:SetTitle(@"price_show") forState:UIControlStateNormal];
    }else {
        [self.priceBtn setTitle:SetTitle(@"price_unshow") forState:UIControlStateNormal];
    }
    
    if (self.clientModel.isShowStock) {
        [self.stockBtn setTitle:SetTitle(@"stock_show") forState:UIControlStateNormal];
    }else {
        [self.stockBtn setTitle:SetTitle(@"stock_unshow") forState:UIControlStateNormal];
    }
}
#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - action

-(IBAction)changeCommandPressed:(id)sender {
    if ([DataShare sharedService].appDel.isReachable) {
        __weak __typeof(self)weakSelf = self;
        AVObject *post = [[AVQuery queryWithClassName:@"Client"] getObjectWithId:self.clientModel.clientId];
        
        NSString *code = [Utility getPlateForm];
        post[@"command"] = code;
        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                weakSelf.clientModel.command = code;
                weakSelf.commandLab.text = weakSelf.clientModel.command;
            }
        }];
    }else {
        [PopView showWithImageName:@"error" message:SetTitle(@"no_connect")];
    }
}

-(IBAction)sendCommandPressed:(id)sender {
    __weak __typeof(self)weakSelf = self;
    
    if (self.clientModel.isCommand) {
        BlockActionSheet *sheet = [[BlockActionSheet alloc]initWithTitle:nil];
        [sheet addButtonWithTitle:SetTitle(@"sheet_sms") block:^{
            [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
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
            
            [LeanChatManager manager].isInmessageVC = true;
            [LeanChatManager manager].messageTo = weakSelf.clientModel.clientName;
            [[DataShare sharedService].unreadMessageDic removeObjectForKey:weakSelf.clientModel.clientName];
            
            LeanChatMessageTableViewController *leanChatMessageTableViewController = [[LeanChatMessageTableViewController alloc] initWithClientIDs:@[weakSelf.clientModel.clientName]];
            leanChatMessageTableViewController.clientModel = weakSelf.clientModel;
            [weakSelf.navigationController pushViewController:
             leanChatMessageTableViewController animated:YES];
            leanChatMessageTableViewController = nil;
        }];
        [sheet setCancelButtonWithTitle:SetTitle(@"cancel") block:^{
            
        }];
        [sheet showInView:self.view];
    }else {
        [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
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
    }
    
}

-(IBAction)priceBtnPressed:(id)sender {
    if ([DataShare sharedService].appDel.isReachable) {
        __weak __typeof(self)weakSelf = self;
        AVObject *post = [[AVQuery queryWithClassName:@"Client"] getObjectWithId:self.clientModel.clientId];
    
        post[@"isShowPrice"] =  @(!self.clientModel.isShowPrice);
        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                weakSelf.clientModel.isShowPrice = !weakSelf.clientModel.isShowPrice;

                if (weakSelf.clientModel.isShowPrice) {
                    [weakSelf.priceBtn setTitle:SetTitle(@"price_show") forState:UIControlStateNormal];
                }else {
                    [weakSelf.priceBtn setTitle:SetTitle(@"price_unshow") forState:UIControlStateNormal];
                }
            }
        }];
    }else {
        [PopView showWithImageName:@"error" message:SetTitle(@"no_connect")];
    }
}

-(IBAction)stockBtnPressed:(id)sender {
    if ([DataShare sharedService].appDel.isReachable) {
        __weak __typeof(self)weakSelf = self;
        AVObject *post = [[AVQuery queryWithClassName:@"Client"] getObjectWithId:self.clientModel.clientId];
        
        post[@"isShowStock"] =  @(!self.clientModel.isShowStock);
        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                weakSelf.clientModel.isShowStock = !weakSelf.clientModel.isShowStock;
                
                if (weakSelf.clientModel.isShowStock) {
                    [weakSelf.stockBtn setTitle:SetTitle(@"stock_show") forState:UIControlStateNormal];
                }else {
                    [weakSelf.stockBtn setTitle:SetTitle(@"stock_unshow") forState:UIControlStateNormal];
                }
            }
        }];
    }else {
        [PopView showWithImageName:@"error" message:SetTitle(@"no_connect")];
    }
}

-(IBAction)membershipBtnPressed:(id)sender {
    if ([DataShare sharedService].appDel.isReachable) {
        __weak __typeof(self)weakSelf = self;
        AVObject *post = [[AVQuery queryWithClassName:@"Client"] getObjectWithId:self.clientModel.clientId];
        
        post[@"disable"] =  @(!self.clientModel.disable);
        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                weakSelf.clientModel.disable = !weakSelf.clientModel.disable;
                
                if (weakSelf.clientModel.disable) {
                    if (weakSelf.clientModel.isCommand) {
                        weakSelf.optionLab.text = SetTitle(@"command_use");
                        
                        [weakSelf.memberBtn setTitle:SetTitle(@"member_disable") forState:UIControlStateNormal];
                    }else {
                        weakSelf.optionLab.text = SetTitle(@"command_unuse");
                        
                        [weakSelf.memberBtn setTitle:SetTitle(@"member_disable") forState:UIControlStateNormal];
                    }
                }else {
                    weakSelf.optionLab.text = SetTitle(@"command_disabled");
                    
                    [weakSelf.memberBtn setTitle:SetTitle(@"member_enable") forState:UIControlStateNormal];
                }
            }
        }];
    }else {
        [PopView showWithImageName:@"error" message:SetTitle(@"no_connect")];
    }
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (result == MessageComposeResultCancelled){
        DLog(@"Message cancelled");
    }else if (result == MessageComposeResultSent) {
        
    }
}

@end
