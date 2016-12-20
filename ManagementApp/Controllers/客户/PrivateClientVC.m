//
//  PrivateClientVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/28.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "PrivateClientVC.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import "BlockActionSheet.h"
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
    
    self.view.backgroundColor = kThemeColor;
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
    if ([Utility isAuthority]) {
        
    }else {
        /*
        QWeakSelf(self);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"authority_tip") message:SetTitle(@"authority_error") preferredStyle:UIAlertControllerStyleAlert];
        [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
            
            AuthorityVC *vc = LOADVC(@"AuthorityVC");
            [weakself.navigationController pushViewController:vc animated:YES];
        }];
        [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
        [self presentViewController:alert animated:YES completion:nil];
         */
    }
    
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
    if ([Utility isAuthority]) {
        __weak __typeof(self)weakSelf = self;
        
        if (self.clientModel.isCommand) {
            
            BlockActionSheet *sheet = [BlockActionSheet sheetWithTitle:@""];
            
            [sheet addButtonWithTitle:SetTitle(@"sheet_sms") block:^{
                if (self.clientModel.clientPhone) {
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
                    }else {
                        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                    }
                }else {
                    [PopView showWithImageName:nil message:SetTitle(@"call_phone_error")];
                }
            }];
            
            if ([DataShare sharedService].escape==1) {
                [sheet addButtonWithTitle:SetTitle(@"sheet_message") block:^{
                    [DataShare sharedService].clientObject = weakSelf.clientModel;
                    
                    LCCKConversationViewController *conversationViewController =
                    [[LCCKConversationViewController alloc] initWithPeerId:weakSelf.clientModel.clientName];
                    
                    __weak __typeof(conversationViewController)weakConversation = conversationViewController;
                    conversationViewController.viewWillAppearBlock = ^(LCCKBaseViewController *viewController, BOOL aAnimated){
                        [weakConversation.navigationController setNavigationBarHidden:false animated:YES];
                        
                        weakConversation.navigationItem.title = @"";
                    };
                    conversationViewController.viewWillDisappearBlock = ^(LCCKBaseViewController *viewController, BOOL aAnimated){
                        //                    [DataShare sharedService].clientObject = nil;
                        [AppDelegate shareInstance].isInmessageVC = false;
                        [AppDelegate shareInstance].messageTo = nil;
                        [weakConversation.navigationController setNavigationBarHidden:YES animated:YES];
                    };
                    
                    [weakSelf.navigationController pushViewController:
                     conversationViewController animated:YES];
                    
                    [AppDelegate shareInstance].isInmessageVC = true;
                    [AppDelegate shareInstance].messageTo = weakSelf.clientModel.clientName;
                    [[DataShare sharedService].unreadMessageDic removeObjectForKey:weakSelf.clientModel.clientName];
                }];
            }
            
            [sheet setCancelButtonWithTitle:SetTitle(@"cancel") block:^{
                
            }];
            [sheet showInView:weakSelf.view];
        }else {
            if (self.clientModel.clientPhone) {
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
                }else {
                    [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                }
            }
        }
    }else {
//        QWeakSelf(self);
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"authority_tip") message:SetTitle(@"authority_error") preferredStyle:UIAlertControllerStyleAlert];
//        [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
//            
//            AuthorityVC *vc = LOADVC(@"AuthorityVC");
//            [weakself.navigationController pushViewController:vc animated:YES];
//        }];
//        [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
//        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(IBAction)priceBtnPressed:(id)sender {
    if ([Utility isAuthority]) {
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
    }else {
//        QWeakSelf(self);
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"authority_tip") message:SetTitle(@"authority_error") preferredStyle:UIAlertControllerStyleAlert];
//        [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
//            
//            AuthorityVC *vc = LOADVC(@"AuthorityVC");
//            [weakself.navigationController pushViewController:vc animated:YES];
//        }];
//        [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
//        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(IBAction)stockBtnPressed:(id)sender {
    if ([Utility isAuthority]) {
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
    }else {
//        QWeakSelf(self);
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"authority_tip") message:SetTitle(@"authority_error") preferredStyle:UIAlertControllerStyleAlert];
//        [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
//            
//            AuthorityVC *vc = LOADVC(@"AuthorityVC");
//            [weakself.navigationController pushViewController:vc animated:YES];
//        }];
//        [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
//        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(IBAction)membershipBtnPressed:(id)sender {
    if ([Utility isAuthority]) {
        if ([DataShare sharedService].appDel.isReachable) {
            __weak __typeof(self)weakSelf = self;
            AVObject *post = [[AVQuery queryWithClassName:@"Client"] getObjectWithId:self.clientModel.clientId];
            
            post[@"disable"] =  @(!self.clientModel.disable);
            [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    weakSelf.clientModel.disable = !weakSelf.clientModel.disable;
                    
                    if (weakSelf.clientModel.disable) {
                        if (weakSelf.clientModel.isCommand) {
                            weakSelf.optionLab.text = SetTitle(@"command_disabled");
                            
                            [weakSelf.memberBtn setTitle:SetTitle(@"member_enable") forState:UIControlStateNormal];
                        }else {
                            weakSelf.optionLab.text = SetTitle(@"command_unuse");
                            
                            [weakSelf.memberBtn setTitle:SetTitle(@"member_enable") forState:UIControlStateNormal];
                        }
                        
                        [[LCCKConversationService sharedInstance] sendWelcomeMessageToPeerId:weakSelf.clientModel.clientName text:@"xiaxian" block:^(BOOL succeeded, NSError *error) {
                            
                        }];
                    }else {
                        weakSelf.optionLab.text = SetTitle(@"command_use");
                        
                        [weakSelf.memberBtn setTitle:SetTitle(@"member_disable") forState:UIControlStateNormal];
                    }
                }
            }];
        }else {
            [PopView showWithImageName:@"error" message:SetTitle(@"no_connect")];
        }
    }else {
//        QWeakSelf(self);
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"authority_tip") message:SetTitle(@"authority_error") preferredStyle:UIAlertControllerStyleAlert];
//        [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
//            
//            AuthorityVC *vc = LOADVC(@"AuthorityVC");
//            [weakself.navigationController pushViewController:vc animated:YES];
//        }];
//        [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
//        [self presentViewController:alert animated:YES completion:nil];
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
