//
//  AddDateVC.m
//  ManagementApp
//
//  Created by 邱成西 on 2016/11/17.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "AddDateVC.h"
#import "RETableViewManager.h"
#import "NSDate+Utils.h"

#import "AFNetworking.h"
#import "NSString+md5.h"


@interface AddDateVC ()

@property (nonatomic, weak) IBOutlet UITableView *table;
@property (strong, nonatomic) RETableViewManager *manager;

@property (strong, readwrite, nonatomic) REDateTimeItem *dateTimeItem;

@property (strong, nonatomic) NSDate *selectedDate;
@end

@implementation AddDateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
    
    _manager = [[RETableViewManager alloc] initWithTableView:self.table];
    RETableViewSection *section = [RETableViewSection section];
    [_manager addSection:section];
    
    //至少1天
    NSDate *date;
    if (!self.model.isExpire) {
        date = [NSDate dateWithTimeIntervalSince1970:self.model.expireDate];
        date = [date dateByAddingTimeInterval:60*60*24*1];
    }else {
        date = [[NSDate date] dateByAddingTimeInterval:60*60*24*1];
    }
    
    self.selectedDate = date;
    
    QWeakSelf(self);
    self.dateTimeItem = [REDateTimeItem itemWithTitle:SetTitle(@"Company_date") value:date placeholder:nil format:@"MM/dd/yyyy hh:mm" datePickerMode:UIDatePickerModeDateAndTime];
    self.dateTimeItem.onChange = ^(REDateTimeItem *item){
        
        weakself.selectedDate = item.value;
    };
    self.dateTimeItem.minimumDate = date;
    self.dateTimeItem.inlineDatePicker = YES;
    [section addItem:self.dateTimeItem];
}

-(void)setNavBarView {
    [self.navBarView setTitle:SetTitle(@"authority_add") image:nil];
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.navBarView setRightWithArray:@[@"ok_bt"] type:0];
    [self.view addSubview:self.navBarView];
    
    [Utility setExtraCellLineHidden:self.table];
}

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    [self.view endEditing:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    [self.view endEditing:YES];

    double time;
    NSString *timeString;
    time = [self.selectedDate timeIntervalSince1970];
    timeString = [self.selectedDate stringCutSeconds];
    
    QWeakSelf(self);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"authority_add") message:[NSString stringWithFormat:@"%@:%@",SetTitle(@"Company_date"),timeString] preferredStyle:UIAlertControllerStyleAlert];
    [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
        
        AFHTTPClient * Client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://us-api.leancloud.cn"]];
        [Client setDefaultHeader:@"Content-Type" value:@"application/json"];
        [Client setDefaultHeader:@"X-LC-Id" value:kApplicationId];
        [Client setDefaultHeader:@"X-LC-Key" value:[NSString stringWithFormat:@"%@,master",MASTERKEY]];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:[NSNumber numberWithDouble:time] forKey:@"expireDate"];
        NSString* path = [NSString stringWithFormat:@"/1.1/classes/_User/%@",weakself.model.userId];
        
        [Client putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if (weakself.completedBlock) {
                weakself.completedBlock(YES);
            }
            [PopView showWithImageName:@"error" message:SetTitle(@"update_success")];
            
            [weakself.navigationController popViewControllerAnimated:YES];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [PopView showWithImageName:@"error" message:SetTitle(@"connect_error")];
        }];
    }];
    [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
    [self presentViewController:alert animated:YES completion:nil];
    
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

@end
