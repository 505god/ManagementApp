//
//  OrderDetailVC.m
//  BApp
//
//  Created by 邱成西 on 16/1/11.
//  Copyright © 2016年 suda_505. All rights reserved.
//

#import "OrderDetailVC.h"
#import "OrderDetailCell.h"
#import "BlockActionSheet.h"
#import "ProductStockModel.h"

@interface OrderDetailVC ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *itemInfo;
@property (weak, nonatomic) IBOutlet UILabel *itemLab;
@property (weak, nonatomic) IBOutlet UILabel *countInfo;
@property (weak, nonatomic) IBOutlet UILabel *countLab;
@property (weak, nonatomic) IBOutlet UILabel *totalInfo;
@property (weak, nonatomic) IBOutlet UILabel *totalLab;

@property (weak, nonatomic) IBOutlet UILabel *deliverLab;
@property (weak, nonatomic) IBOutlet UILabel *payLab;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *discountLab;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation OrderDetailVC

#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
}

#pragma mark - UI

-(void)setPayLabUI {
    if (self.orderModel.isPay==0) {
        self.payLab.text = SetTitle(@"pay_none");
    }else if (self.orderModel.isPay==1){
        self.payLab.text = [NSString stringWithFormat:@"%@:%.2f",SetTitle(@"pay_part"),self.orderModel.arrearsPrice];
    }else {
        self.payLab.text = SetTitle(@"pay_all");
    }
}

-(void)setDeliverLabUI {
    if (self.orderModel.isDeliver==0) {
        self.deliverLab.text = SetTitle(@"deliver_none");
    }else if (self.orderModel.isDeliver==1){
        self.deliverLab.text = SetTitle(@"deliver_part");
    }else if (self.orderModel.isDeliver==2){
        self.deliverLab.text = SetTitle(@"deliver_all");
    }
}

-(void)setDeiscountLabUI {
    if (self.orderModel.discountType==-1) {
        self.discountLab.text = @"";
    }else if (self.orderModel.discountType==0) {
        self.discountLab.text = [NSString stringWithFormat:@"%@%d%%",SetTitle(@"order_zhekou"),(int)self.orderModel.discount];
    }else if (self.orderModel.discountType==1) {
        self.discountLab.text = [NSString stringWithFormat:@"%@%.2f",SetTitle(@"order_jine"),self.orderModel.discount];
    }
    
    self.totalLab.text = [NSString stringWithFormat:@"%.2f",self.orderModel.orderPrice];
    self.itemLab.text = [NSString stringWithFormat:@"%ld",self.orderModel.itemCount];
    self.countLab.text = [NSString stringWithFormat:@"%ld",self.orderModel.orderCount];
}

-(void)setNavBarView {
    
    [self.navBarView setTitle:self.orderModel.orderCode image:nil];
    
    //判断顾客是否被删除
    if (self.orderModel.clientId) {
        __weak __typeof(self)weakSelf = self;
        
        AVQuery *query = [AVQuery queryWithClassName:@"Client"];
        [query whereKey:@"objectId" equalTo:weakSelf.orderModel.clientId];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (objects.count>0) {
                [weakSelf.navBarView setRightWithArray:@[@"navicon_more"] type:0];
            }
            
        }];
    }else {
        [self.navBarView setRightWithArray:@[@"navicon_more"] type:0];
    }
    
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.view addSubview:self.navBarView];
    
    self.itemInfo.text = SetTitle(@"order_items");
    self.countInfo.text = SetTitle(@"order_count");
    self.totalInfo.text = SetTitle(@"order_totall");
    
    
    [self setPayLabUI];
    
    [self setDeliverLabUI];
    
    [self setDeiscountLabUI];
    
    self.nameLab.text = [NSString stringWithFormat:@"%@ %@ %@",self.orderModel.timeString,self.orderModel.clientName,SetTitle(@"order_creat")];
    
    [Utility setExtraCellLineHidden:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"OrderDetailCell" bundle:nil] forCellReuseIdentifier:@"OrderDetailCell"];
    
    [self.tableView reloadData];
    
}

#pragma mark -

#pragma mark - table代理

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.orderModel.productArray.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 78;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderDetailCell" forIndexPath:indexPath];
    cell.orderStockModel = self.orderModel.productArray[indexPath.row];
    return cell;
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.orderModel.isPay==0 && self.orderModel.isDeliver==0) {
        return YES;
    }
    return NO;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  UITableViewCellEditingStyleDelete;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return SetTitle(@"product_edit");
}
- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([Utility isAuthority]) {
            if (self.orderModel.isPay==0 && self.orderModel.isDeliver==0 && [DataShare sharedService].appDel.isReachable){
                __weak __typeof(self)weakSelf = self;
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"order_edit_count") message:SetTitle(@"order_edit_count_info") preferredStyle:UIAlertControllerStyleAlert];
                [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                    textField.textAlignment = NSTextAlignmentCenter;
                }];
                
                [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
                    
                    UITextField *textField = (UITextField *)alert.textFields.firstObject;
                    
                    OrderStockModel *model = (OrderStockModel *)weakSelf.orderModel.productArray[indexPath.row];
                    
                    //数量判断
                    if ([textField.text integerValue] > model.num) {
                        [PopView showWithImageName:@"error" message:SetTitle(@"order_edit_count_error")];
                        return;
                    }
                    
                    //总价的变更
                    CGFloat tax = 0;
                    CGFloat profit = 0;
                    CGFloat chajia = weakSelf.orderModel.orderPrice;//差价
                    if (weakSelf.orderModel.discountType==0){
                        
                        weakSelf.orderModel.orderPrice -= [textField.text integerValue]*model.price*(100-weakSelf.orderModel.discount)/100;
                        
                        tax = [textField.text integerValue]*model.price*(100-weakSelf.orderModel.discount)/100*weakSelf.orderModel.taxNum;
                        weakSelf.orderModel.tax -= tax;
                        
                        profit = [textField.text integerValue]*(model.price*(100-weakSelf.orderModel.discount)/100-model.purchasePrice)- tax;
                    }else if (weakSelf.orderModel.discountType==1) {
                        weakSelf.orderModel.orderPrice -= [textField.text integerValue]*(model.price-weakSelf.orderModel.discount/weakSelf.orderModel.orderCount);
                        
                        tax = [textField.text integerValue]*(model.price-weakSelf.orderModel.discount/weakSelf.orderModel.orderCount)*weakSelf.orderModel.taxNum;
                        weakSelf.orderModel.tax -= tax;
                        
                        profit = [textField.text integerValue]*((model.price-weakSelf.orderModel.discount/weakSelf.orderModel.orderCount)-model.purchasePrice)-tax;
                        weakSelf.orderModel.profit -= profit;
                    }else {
                        weakSelf.orderModel.orderPrice -= [textField.text integerValue]*model.price;
                        
                        tax = [textField.text integerValue]*model.price*weakSelf.orderModel.taxNum;
                        weakSelf.orderModel.tax -= tax;
                        
                        profit = [textField.text integerValue]*(model.price-model.purchasePrice) - tax;
                        weakSelf.orderModel.profit -= profit;
                    }
                    
                    AVQuery *query1 = [AVQuery queryWithClassName:@"Statistics"];
                    [query1 whereKey:@"user" equalTo:[AVUser currentUser]];
                    AVObject *statistics_post = [query1 getFirstObject];
                    [statistics_post incrementKey:@"surplusStock" byAmount:[NSNumber numberWithInt:0-(int)[textField.text integerValue]]];
                    [statistics_post incrementKey:@"surplusMoney" byAmount:[NSNumber numberWithFloat:model.purchasePrice*[textField.text integerValue]]];
                    [statistics_post incrementKey:@"totalProfit" byAmount:[NSNumber numberWithFloat:0-profit]];
                    [statistics_post incrementKey:@"tax" byAmount:[NSNumber numberWithFloat:0-tax]];
                    [statistics_post saveInBackground];
                    
                    chajia -= weakSelf.orderModel.orderPrice;
                    
                    model.num -= [textField.text integerValue];
                    weakSelf.orderModel.orderCount -= [textField.text integerValue];
                    if (model.num==0) {
                        weakSelf.orderModel.itemCount --;
                        [weakSelf.orderModel.productArray removeObjectAtIndex:indexPath.row];
                        
                        if (weakSelf.orderModel.itemCount==0) {
                            if (weakSelf.orderModel.productArray.count>0) {
                                weakSelf.orderModel.itemCount = 1;
                            }else {
                                //订单删除
                            }
                        }
                    }
                    
                    [weakSelf pushOrderToServer:model num:[textField.text integerValue] price:chajia];
                }];
                
                [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
                [self presentViewController:alert animated:YES completion:nil];
            }
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
    }
}

-(void)pushOrderToServer:(OrderStockModel *)model num:(NSInteger)num price:(CGFloat)price{
    __weak __typeof(self)weakSelf = self;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    //订单
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^(){
        if (weakSelf.orderModel.itemCount==0 && weakSelf.orderModel.productArray.count==0) {//删除订单
            AVObject *post = [[AVQuery queryWithClassName:@"Order"] getObjectWithId:weakSelf.orderModel.orderId];
            [post delete];
        }else {
            AVObject *post = [[AVQuery queryWithClassName:@"Order"] getObjectWithId:weakSelf.orderModel.orderId];
            post[@"orderPrice"] =[NSString stringWithFormat:@"%.2f",weakSelf.orderModel.orderPrice];
            
            post[@"orderCount"] = [NSString stringWithFormat:@"%d",(int)weakSelf.orderModel.orderCount];//订单产品数量
            post[@"itemCount"] = [NSString stringWithFormat:@"%d",(int)weakSelf.orderModel.itemCount];//订单货号数量
            [post setObject:[NSNumber numberWithFloat:weakSelf.orderModel.profit] forKey:@"profit"];
            [post setObject:[NSNumber numberWithFloat:weakSelf.orderModel.tax] forKey:@"tax"];
            [post save];
        }
        dispatch_group_leave(group);
    });
    
    //客户
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^(){
        if (weakSelf.orderModel.clientId) {
            AVObject *client = [[AVQuery queryWithClassName:@"Client"] getObjectWithId:weakSelf.orderModel.clientId];
            
            if (weakSelf.orderModel.itemCount==0 && weakSelf.orderModel.productArray.count==0) {
                [client incrementKey:@"tradeNum" byAmount:[NSNumber numberWithInt:-1]];
            }
            
            [client incrementKey:@"arrearsPrice" byAmount:[NSNumber numberWithFloat:(0-price)]];
            [client incrementKey:@"totalPrice" byAmount:[NSNumber numberWithFloat:(0-price)]];
            [client save];
        }
        dispatch_group_leave(group);
    });
    
    //订单商品
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^(){
        AVObject *post = [[AVQuery queryWithClassName:@"OrderStock"] getObjectWithId:model.orderStockId];
        
        if (model.num==0) {
            if (weakSelf.orderModel.itemCount==0 && weakSelf.orderModel.productArray.count==0) {
                [post delete];
            }else {
                AVObject *post2 = [[AVQuery queryWithClassName:@"Order"] getObjectWithId:weakSelf.orderModel.orderId];
                
                [post2 removeObject:post forKey:@"products"];
                
                [post2 save];
                [post delete];
            }
        }else {
            post[@"num"] = @(model.num);
            [post save];
        }
        dispatch_group_leave(group);
    });
    
    //库存
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^(){
        AVObject *post = [[AVQuery queryWithClassName:@"ProductStock"] getObjectWithId:model.oid];
        [post incrementKey:[weakSelf returnSale:model.clientLevel] byAmount:[NSNumber numberWithInt:(int)(0-num)]];
        [post incrementKey:@"saleNum" byAmount:[NSNumber numberWithInt:(int)(0-num)]];
        
        ProductStockModel *pmodel = [ProductStockModel initWithObject:post];
        pmodel.stockNum += num;
        if (pmodel.isSetting) {
            if (pmodel.stockNum < pmodel.singleNum) {
                post[@"isWarning"] = @(true);
            }else {
                post[@"isWarning"] = @(false);
            }
        }
        
        [post save];
        dispatch_group_leave(group);
    });
    
    //商品
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^(){
        AVQuery *query1 = [AVQuery queryWithClassName:@"Product"];
        [query1 whereKey:@"user" equalTo:[AVUser currentUser]];
        [query1 whereKey:@"productCode" equalTo:model.pcode];
        AVObject *object = [query1 getFirstObject];
        
        [object incrementKey:@"saleNum" byAmount:[NSNumber numberWithInt:(int)(0-num)]];
        [object incrementKey:@"stockNum" byAmount:[NSNumber numberWithInt:(int)num]];
        
        CGFloat x = [[object objectForKey:@"profit"] floatValue];
        if (weakSelf.orderModel.discountType==0){
            x -= num * model.price*(100-weakSelf.orderModel.discount)/100*(1-weakSelf.orderModel.taxNum);
        }else if (weakSelf.orderModel.discountType==1){
            x -= num * (model.price-weakSelf.orderModel.discount/(num+weakSelf.orderModel.orderCount))*(1-weakSelf.orderModel.taxNum);
        }else {
            x -= num * model.price*(1-weakSelf.orderModel.taxNum);
        }
        if (x>0) {
            object[@"profitStatus"] = @(1);
        }else {
            object[@"profitStatus"] = @(0);
        }
        object[@"profit"] = @(x);
        
        if ([[object objectForKey:@"isWarning"] boolValue]) {
            NSInteger stock = [[object objectForKey:@"stockNum"] integerValue];
            NSInteger total = [[object objectForKey:@"totalNum"] integerValue];
            
            if (stock <total) {
                object[@"isWarning"] = @(true);
            }else {
                object[@"isWarning"] = @(false);
            }
        }
        
        [object save];
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^(){
        
        
        if (weakSelf.orderModel.clientId) {
            
            weakSelf.orderModel.cred = true;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                AVObject *object = [AVObject objectWithClassName:@"Order" objectId:weakSelf.orderModel.orderId];
                [object setObject:@(true) forKey:@"cred"];
                [object saveEventually];
            });
            
            //发推送
            AVQuery *queryquery = [AVInstallation query];
            [queryquery whereKey:@"user" equalTo:[AVUser currentUser]];
            [queryquery whereKey:@"cid" equalTo:weakSelf.orderModel.clientId];
            [queryquery whereKey:@"deviceProfile" equalTo:@"CAPP"];
            AVPush *push = [[AVPush alloc] init];
            [push setQuery:queryquery];
            NSDictionary *data = @{
                                   @"alert": [NSString stringWithFormat:SetTitle(@"push_order_edit_info"),weakSelf.orderModel.orderCode],
                                   @"type": @"4",
                                   @"badge":@"1"
                                   };
            [push setData:data];
            [AVPush setProductionMode:YES];
            [push sendPushInBackground];
        }
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        if (weakSelf.orderModel.itemCount==0 && weakSelf.orderModel.productArray.count==0) {
            if (weakSelf.deleteHandler) {
                weakSelf.deleteHandler(weakSelf.idxPath);
            }
            
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else {
            if (weakSelf.refreshHandler) {
                weakSelf.refreshHandler (weakSelf.orderModel,weakSelf.idxPath);
            }
            
            [weakSelf setDeiscountLabUI];
            [weakSelf.tableView reloadData];
        }
    });
}

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSArray *)deliverArray {
    NSMutableArray *array = [NSMutableArray array];
    if (self.orderModel.isDeliver==0) {
        [array addObject:SetTitle(@"deliver_part")];
        [array addObject:SetTitle(@"deliver_all")];
    }else if (self.orderModel.isDeliver==1) {
        [array addObject:SetTitle(@"deliver_none")];
        [array addObject:SetTitle(@"deliver_all")];
    }else {
        [array addObject:SetTitle(@"deliver_none")];
        [array addObject:SetTitle(@"deliver_part")];
    }
    return array;
}

-(void)dealDeliverArray:(int)tag {
    __weak __typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVObject *post = [[AVQuery queryWithClassName:@"Order"] getObjectWithId:weakSelf.orderModel.orderId];
        
        if (weakSelf.orderModel.isDeliver==0) {
            weakSelf.orderModel.isDeliver = tag+1;
            [post setObject:[NSNumber numberWithInt:(1+tag)] forKey:@"isDeliver"];
        }else if (weakSelf.orderModel.isDeliver==1) {
            weakSelf.orderModel.isDeliver = tag*2;
            [post setObject:[NSNumber numberWithInt:tag*2] forKey:@"isDeliver"];
        }else {
            weakSelf.orderModel.isDeliver = tag;
            [post setObject:[NSNumber numberWithInt:tag] forKey:@"isDeliver"];
        }
        [post saveEventually];
        
        if (weakSelf.orderModel.clientId && weakSelf.orderModel.isDeliver!=0) {
            
            weakSelf.orderModel.cred = true;
            AVObject *object = [AVObject objectWithClassName:@"Order" objectId:weakSelf.orderModel.orderId];
            [object setObject:@(true) forKey:@"cred"];
            [object saveEventually];
            
            //发推送push_order_edit_info
            AVQuery *queryquery = [AVInstallation query];
            [queryquery whereKey:@"user" equalTo:[AVUser currentUser]];
            [queryquery whereKey:@"cid" equalTo:weakSelf.orderModel.clientId];
            [queryquery whereKey:@"deviceProfile" equalTo:@"CAPP"];
            AVPush *push = [[AVPush alloc] init];
            [push setQuery:queryquery];
            NSDictionary *data = @{
                                   @"alert": [NSString stringWithFormat:SetTitle(@"push_order_deliver_info"),weakSelf.orderModel.orderCode,weakSelf.orderModel.isDeliver==1?SetTitle(@"deliver_part"):SetTitle(@"deliver_all")],
                                   @"type": @"3",
                                   @"badge":@"1"
                                   };
            [push setData:data];
            [AVPush setProductionMode:YES];
            [push sendPushInBackground];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf setDeliverLabUI];
            
            if (weakSelf.refreshHandler) {
                weakSelf.refreshHandler (weakSelf.orderModel,weakSelf.idxPath);
            }
        });
    });
}


-(NSArray *)payArray {
    NSMutableArray *array = [NSMutableArray array];
    if (self.orderModel.isPay==0) {
        [array addObject:SetTitle(@"pay_part")];
        [array addObject:SetTitle(@"pay_all")];
    }else if (self.orderModel.isPay==1) {
        [array addObject:SetTitle(@"pay_none")];
        [array addObject:SetTitle(@"pay_all")];
    }else {
        [array addObject:SetTitle(@"pay_none")];
        [array addObject:SetTitle(@"pay_part")];
    }
    return array;
}

-(void)dealPayArray:(int)tag {
    
    __weak __typeof(self)weakSelf = self;
    
    AVObject *post = [[AVQuery queryWithClassName:@"Order"] getObjectWithId:weakSelf.orderModel.orderId];
    
    if (weakSelf.orderModel.isPay==0) {
        if (tag==0) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"pay_part_price") message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.keyboardType = UIKeyboardTypeNumberPad;
                textField.textAlignment = NSTextAlignmentCenter;
            }];
            
            [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
                UITextField *textField = (UITextField *)alert.textFields.firstObject;
                
                if (weakSelf.orderModel.orderPrice-weakSelf.orderModel.arrearsPrice-[textField.text floatValue]<0) {
                    [PopView showWithImageName:nil message:SetTitle(@"pay_price_error")];
                    
                    return;
                }
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    [post incrementKey:@"arrearsPrice" byAmount:[NSNumber numberWithFloat:[textField.text floatValue]]];
                    if (weakSelf.orderModel.orderPrice-weakSelf.orderModel.arrearsPrice-[textField.text floatValue]==0) {
                        //全部付款
                        [post setObject:[NSNumber numberWithInt:2] forKey:@"isPay"];
                        [post setObject:[NSNumber numberWithInt:2] forKey:@"status"];
                    }else{
                        [post setObject:[NSNumber numberWithInt:1] forKey:@"isPay"];
                        [post setObject:[NSNumber numberWithInt:1] forKey:@"status"];
                    }
                    
                    [post saveEventually];
                    
                    if (weakSelf.orderModel.clientId) {
                        AVObject *client = [[AVQuery queryWithClassName:@"Client"] getObjectWithId:weakSelf.orderModel.clientId];
                        [client incrementKey:@"arrearsPrice" byAmount:[NSNumber numberWithFloat:(0-[textField.text floatValue])]];
                        [client saveEventually];
                    }
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        weakSelf.orderModel.isPay = 1;
                        weakSelf.orderModel.orderStatus = 1;
                        if (weakSelf.orderModel.orderPrice-weakSelf.orderModel.arrearsPrice-[textField.text floatValue]==0) {
                            //全部付款
                            weakSelf.orderModel.isPay = 2;
                            weakSelf.orderModel.orderStatus = 2;
                        }
                        weakSelf.orderModel.arrearsPrice += [textField.text floatValue];
                        [weakSelf setPayLabUI];
                        
                        if (weakSelf.refreshHandler) {
                            weakSelf.refreshHandler (weakSelf.orderModel,weakSelf.idxPath);
                        }
                    });
                });
            }];
            [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel") action:^(UIAlertAction *action) {
            }];
            [self presentViewController:alert animated:YES completion:nil];
        }else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [post setObject:[NSNumber numberWithFloat:weakSelf.orderModel.orderPrice] forKey:@"arrearsPrice"];
                [post setObject:[NSNumber numberWithInt:2] forKey:@"isPay"];
                [post setObject:[NSNumber numberWithInt:2] forKey:@"status"];
                [post saveEventually];
                
                if (weakSelf.orderModel.clientId) {
                    AVObject *client = [[AVQuery queryWithClassName:@"Client"] getObjectWithId:weakSelf.orderModel.clientId];
                    [client incrementKey:@"arrearsPrice" byAmount:[NSNumber numberWithFloat:(0-(weakSelf.orderModel.orderPrice-weakSelf.orderModel.arrearsPrice))]];
                    [client saveEventually];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.orderModel.arrearsPrice = weakSelf.orderModel.orderPrice;
                    weakSelf.orderModel.isPay = 2;
                    weakSelf.orderModel.orderStatus = 2;
                    [weakSelf setPayLabUI];
                    
                    if (weakSelf.refreshHandler) {
                        weakSelf.refreshHandler (weakSelf.orderModel,weakSelf.idxPath);
                    }
                });
            });
        }
    }else if (weakSelf.orderModel.isPay==1) {
        if (tag==0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [post setObject:[NSNumber numberWithFloat:0] forKey:@"arrearsPrice"];
                [post setObject:[NSNumber numberWithInt:0] forKey:@"isPay"];
                [post setObject:[NSNumber numberWithInt:0] forKey:@"status"];
                [post saveEventually];
                
                if (weakSelf.orderModel.clientId){
                    AVObject *client = [[AVQuery queryWithClassName:@"Client"] getObjectWithId:weakSelf.orderModel.clientId];
                    [client incrementKey:@"arrearsPrice" byAmount:[NSNumber numberWithFloat:weakSelf.orderModel.arrearsPrice]];
                    [client saveEventually];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.orderModel.arrearsPrice = 0;
                    weakSelf.orderModel.isPay = 0;
                    weakSelf.orderModel.orderStatus = 0;
                    [weakSelf setPayLabUI];
                    
                    if (weakSelf.refreshHandler) {
                        weakSelf.refreshHandler (weakSelf.orderModel,weakSelf.idxPath);
                    }
                });
            });
        }else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [post setObject:[NSNumber numberWithFloat:weakSelf.orderModel.orderPrice] forKey:@"arrearsPrice"];
                [post setObject:[NSNumber numberWithInt:2] forKey:@"isPay"];
                [post setObject:[NSNumber numberWithInt:2] forKey:@"status"];
                [post saveEventually];
                
                if (weakSelf.orderModel.clientId) {
                    AVObject *client = [[AVQuery queryWithClassName:@"Client"] getObjectWithId:weakSelf.orderModel.clientId];
                    [client incrementKey:@"arrearsPrice" byAmount:[NSNumber numberWithFloat:(0-(weakSelf.orderModel.orderPrice-weakSelf.orderModel.arrearsPrice))]];
                    [client saveEventually];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.orderModel.arrearsPrice = weakSelf.orderModel.orderPrice;
                    weakSelf.orderModel.isPay = 2;
                    weakSelf.orderModel.orderStatus = 2;
                    [weakSelf setPayLabUI];
                    
                    if (weakSelf.refreshHandler) {
                        weakSelf.refreshHandler (weakSelf.orderModel,weakSelf.idxPath);
                    }
                });
            });
        }
    }else {
        if (tag==0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [post setObject:[NSNumber numberWithFloat:0] forKey:@"arrearsPrice"];
                [post setObject:[NSNumber numberWithInt:0] forKey:@"isPay"];
                [post setObject:[NSNumber numberWithInt:0] forKey:@"status"];
                [post saveEventually];
                
                if (weakSelf.orderModel.clientId){
                    AVObject *client = [[AVQuery queryWithClassName:@"Client"] getObjectWithId:weakSelf.orderModel.clientId];
                    [client incrementKey:@"arrearsPrice" byAmount:[NSNumber numberWithFloat:weakSelf.orderModel.orderPrice]];
                    [client saveEventually];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.orderModel.arrearsPrice = 0;
                    weakSelf.orderModel.isPay = 0;
                    weakSelf.orderModel.orderStatus = 0;
                    [weakSelf setPayLabUI];
                    
                    if (weakSelf.refreshHandler) {
                        weakSelf.refreshHandler (weakSelf.orderModel,weakSelf.idxPath);
                    }
                });
            });
        }else {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"pay_part_price") message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.keyboardType = UIKeyboardTypeNumberPad;
                textField.textAlignment = NSTextAlignmentCenter;
            }];
            
            [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
                UITextField *textField = (UITextField *)alert.textFields.firstObject;
                weakSelf.orderModel.arrearsPrice = [textField.text floatValue];
                
                if (weakSelf.orderModel.orderPrice-[textField.text floatValue]<0) {
                    [PopView showWithImageName:nil message:SetTitle(@"pay_price_error")];
                    
                    return;
                }
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    [post incrementKey:@"arrearsPrice" byAmount:[NSNumber numberWithFloat:0-(weakSelf.orderModel.orderPrice-[textField.text floatValue])]];
                    if (weakSelf.orderModel.orderPrice-[textField.text floatValue]==0) {
                        //全部付款
                        [post setObject:[NSNumber numberWithInt:2] forKey:@"isPay"];
                        [post setObject:[NSNumber numberWithInt:2] forKey:@"status"];
                    }else{
                        [post setObject:[NSNumber numberWithInt:1] forKey:@"isPay"];
                        [post setObject:[NSNumber numberWithInt:1] forKey:@"status"];
                    }
                    
                    [post saveEventually];
                    
                    if (weakSelf.orderModel.clientId) {
                        AVObject *client = [[AVQuery queryWithClassName:@"Client"] getObjectWithId:weakSelf.orderModel.clientId];
                        [client incrementKey:@"arrearsPrice" byAmount:[NSNumber numberWithFloat:(weakSelf.orderModel.orderPrice-[textField.text floatValue])]];
                        [client saveEventually];
                    }
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        weakSelf.orderModel.isPay = 1;
                        weakSelf.orderModel.orderStatus = 1;
                        if (weakSelf.orderModel.orderPrice-[textField.text floatValue]==0) {
                            //全部付款
                            weakSelf.orderModel.isPay = 2;
                            weakSelf.orderModel.orderStatus = 2;
                        }
                        
                        [weakSelf setPayLabUI];
                        
                        if (weakSelf.refreshHandler) {
                            weakSelf.refreshHandler (weakSelf.orderModel,weakSelf.idxPath);
                        }
                    });
                });
            }];
            [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel") action:^(UIAlertAction *action) {
            }];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}
-(CGFloat)returnTaxWithType:(NSInteger)type {
    CGFloat tax = 0;
    for (int i=0; i<self.orderModel.productArray.count; i++) {
        OrderStockModel *model = (OrderStockModel *)self.orderModel.productArray[i];;
        if (type==0) {
            tax += model.price * (100-self.orderModel.discount)/100*self.orderModel.taxNum*model.num;
        }else if (type==1) {
            tax += (model.price - self.orderModel.discount/self.orderModel.orderCount)*model.num*self.orderModel.taxNum;
        }else {
            tax += model.price*model.num*self.orderModel.taxNum;
        }
    }
    
    return tax;
}
-(CGFloat)returnStaticProfitWithType:(NSInteger)type {
    CGFloat profit = 0;
    for (int i=0; i<self.orderModel.productArray.count; i++) {
        OrderStockModel *model = (OrderStockModel *)self.orderModel.productArray[i];
        if (type==0) {
            profit += (model.price * (100-self.orderModel.discount)/100 - model.purchasePrice)*model.num;
        }else if (type==1) {
            profit += (model.price - self.orderModel.discount/self.orderModel.orderCount - model.purchasePrice)*model.num;
        }else {
            profit += (model.price - model.purchasePrice)*model.num;
        }
    }
    
    return profit;
}

-(CGFloat)returnProfitWithType:(NSInteger)type {
    CGFloat profit = 0;
    CGFloat tax = 0;
    for (int i=0; i<self.orderModel.productArray.count; i++) {
        OrderStockModel *model = (OrderStockModel *)self.orderModel.productArray[i];
        CGFloat tax_tax = 0;
        if (type==0) {
            tax_tax = model.price * (100-self.orderModel.discount)/100*self.orderModel.taxNum*model.num;
            profit += (model.price * (100-self.orderModel.discount)/100 - model.purchasePrice)*model.num -tax_tax;
        }else if (type==1) {
            tax_tax = (model.price - self.orderModel.discount/self.orderModel.orderCount)*model.num*self.orderModel.taxNum;
            
            profit += (model.price - self.orderModel.discount/self.orderModel.orderCount - model.purchasePrice)*model.num-tax_tax;
        }else {
            tax_tax = model.price*model.num*self.orderModel.taxNum;
            profit += (model.price - model.purchasePrice)*model.num-tax_tax;
        }
        
        tax += tax_tax;
    }
    
    return profit;
}
-(void)dealDiscount:(NSInteger)type disType:(NSInteger)disType dis:(CGFloat)dis{
    __weak __typeof(self)weakSelf = self;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^(){
        AVObject *post = [[AVQuery queryWithClassName:@"Order"] getObjectWithId:weakSelf.orderModel.orderId];
        post[@"discountType"] = [NSString stringWithFormat:@"%d",(int)weakSelf.orderModel.discountType];//优惠方式
        post[@"discount"] = [NSString stringWithFormat:@"%.2f",weakSelf.orderModel.discount];
        post[@"orderPrice"] =[NSString stringWithFormat:@"%.2f",weakSelf.orderModel.orderPrice];
        [post setObject:[NSNumber numberWithFloat:weakSelf.orderModel.profit] forKey:@"profit"];
        [post setObject:[NSNumber numberWithFloat:weakSelf.orderModel.tax] forKey:@"tax"];
        [post save];
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^(){
        
        for (int i=0; i<weakSelf.orderModel.productArray.count; i++) {
            OrderStockModel *model = (OrderStockModel *)weakSelf.orderModel.productArray[i];
            
            AVQuery *query1 = [AVQuery queryWithClassName:@"Product"];
            [query1 whereKey:@"user" equalTo:[AVUser currentUser]];
            [query1 whereKey:@"productCode" equalTo:model.pcode];
            AVObject *object = [query1 getFirstObject];
            
            CGFloat x = [[object objectForKey:@"profit"] floatValue];
            
            if (disType==0) {
                x -= model.num * model.price*(100-dis)/100*(1-weakSelf.orderModel.taxNum);
            }else if (disType==1) {
                x -= (model.num * (model.price - dis/weakSelf.orderModel.orderCount)*(1-weakSelf.orderModel.taxNum));
            }else {
                x -= model.num * model.price*(1-weakSelf.orderModel.taxNum);
            }
            
            if (weakSelf.orderModel.discountType==-1) {
                x += model.num * model.price*(1-weakSelf.orderModel.taxNum);
            }else if (weakSelf.orderModel.discountType==0){
                x += model.num * model.price*(100-weakSelf.orderModel.discount)/100 *(1-weakSelf.orderModel.taxNum);
            }else {
                x += (model.num * (model.price- weakSelf.orderModel.discount/weakSelf.orderModel.orderCount) *(1-weakSelf.orderModel.taxNum));
            }
            
            if (x>0) {
                object[@"profitStatus"] = @(1);
            }else {
                object[@"profitStatus"] = @(0);
            }
            object[@"profit"] = @(x);
            [object save];
        }
        
        if (weakSelf.orderModel.clientId) {
            AVObject *client = [[AVQuery queryWithClassName:@"Client"] getObjectWithId:weakSelf.orderModel.clientId];
            
            [client incrementKey:@"arrearsPrice" byAmount:[NSNumber numberWithFloat:(0-(originPrice-weakSelf.orderModel.orderPrice))]];
            [client incrementKey:@"totalPrice" byAmount:[NSNumber numberWithFloat:(0-(originPrice-weakSelf.orderModel.orderPrice))]];
            [client save];
        }
        
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^(){
        if (weakSelf.orderModel.clientId) {
            
            weakSelf.orderModel.cred = true;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                AVObject *object = [AVObject objectWithClassName:@"Order" objectId:weakSelf.orderModel.orderId];
                [object setObject:@(true) forKey:@"cred"];
                [object saveEventually];
            });
            
            //发推送
            AVQuery *queryquery = [AVInstallation query];
            [queryquery whereKey:@"user" equalTo:[AVUser currentUser]];
            [queryquery whereKey:@"cid" equalTo:weakSelf.orderModel.clientId];
            [queryquery whereKey:@"deviceProfile" equalTo:@"CAPP"];
            AVPush *push = [[AVPush alloc] init];
            [push setQuery:queryquery];
            NSDictionary *data = @{
                                   @"alert": [NSString stringWithFormat:SetTitle(@"push_order_edit_info"),weakSelf.orderModel.orderCode],
                                   @"type": @"4",
                                   @"badge":@"1"
                                   };
            [push setData:data];
            [AVPush setProductionMode:YES];
            [push sendPushInBackground];
        }
        
        [weakSelf setDeiscountLabUI];
        
        if (weakSelf.refreshHandler) {
            weakSelf.refreshHandler (weakSelf.orderModel,weakSelf.idxPath);
        }
    });
}

static CGFloat originPrice = 0;

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    if ([Utility isAuthority]) {
        __weak __typeof(self)weakSelf = self;
        BlockActionSheet *sheet = [BlockActionSheet sheetWithTitle:@""];
        
        if (self.orderModel.isPay==0 && self.orderModel.isDeliver==0) {//未付款可修改
            [sheet addButtonWithTitle:SetTitle(@"product_edit") block:^{
                
                BlockActionSheet *sheet1 = [BlockActionSheet sheetWithTitle:@""];
                
                [sheet1 addButtonWithTitle:SetTitle(@"order_edit_zhekou") block:^{
                    
                    
                    UIAlertController *alert_zhekou = [UIAlertController alertControllerWithTitle:SetTitle(@"jianzhekou") message:SetTitle(@"jianzhekou_info") preferredStyle:UIAlertControllerStyleAlert];
                    [alert_zhekou addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                        textField.keyboardType = UIKeyboardTypeNumberPad;
                        textField.textAlignment = NSTextAlignmentCenter;
                        
                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];
                    }];
                    
                    [weakSelf addActionTarget:alert_zhekou title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
                        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alert_zhekou.textFields.firstObject];
                        
                        UITextField *textField = (UITextField *)alert_zhekou.textFields.firstObject;
                        
                        //原来的价格
                        originPrice = weakSelf.orderModel.orderPrice;
                        NSInteger type = weakSelf.orderModel.discountType;
                        CGFloat dis = weakSelf.orderModel.discount;
                        if (weakSelf.orderModel.discountType==-1) {
                        }else {
                            if (weakSelf.orderModel.discountType==0){
                                weakSelf.orderModel.orderPrice = weakSelf.orderModel.orderPrice*100/(100-weakSelf.orderModel.discount);
                            }else {
                                weakSelf.orderModel.orderPrice += weakSelf.orderModel.discount;
                            }
                            weakSelf.orderModel.discountType = -1;
                            weakSelf.orderModel.discount = 0;
                        }
                        
                        //恢复
                        weakSelf.orderModel.discountType = 0;
                        weakSelf.orderModel.discount = [textField.text floatValue];
                        weakSelf.orderModel.orderPrice -= weakSelf.orderModel.orderPrice*[textField.text floatValue]/100;
                        
                        AVQuery *query1 = [AVQuery queryWithClassName:@"Statistics"];
                        [query1 whereKey:@"user" equalTo:[AVUser currentUser]];
                        AVObject *statistics_post = [query1 getFirstObject];
                        [statistics_post incrementKey:@"totalProfit" byAmount:[NSNumber numberWithFloat:0-(weakSelf.orderModel.profit-[weakSelf returnProfitWithType:0])]];
                        [statistics_post incrementKey:@"tax" byAmount:[NSNumber numberWithFloat:0-(weakSelf.orderModel.tax-[weakSelf returnTaxWithType:0])]];
                        [statistics_post saveInBackground];
                        
                        weakSelf.orderModel.tax = [weakSelf returnTaxWithType:0];
                        weakSelf.orderModel.profit = [weakSelf returnProfitWithType:0];
                        [weakSelf dealDiscount:0 disType:type dis:dis];
                    }];
                    
                    [weakSelf addCancelActionTarget:alert_zhekou title:SetTitle(@"alert_cancel")];
                    [weakSelf presentViewController:alert_zhekou animated:YES completion:nil];
                }];
                [sheet1 addButtonWithTitle:SetTitle(@"order_edit_jine") block:^{
                    
                    UIAlertController *alert_jine = [UIAlertController alertControllerWithTitle:SetTitle(@"jianjine") message:SetTitle(@"jianjine_info") preferredStyle:UIAlertControllerStyleAlert];
                    [alert_jine addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                        textField.keyboardType = UIKeyboardTypeNumberPad;
                        textField.textAlignment = NSTextAlignmentCenter;
                    }];
                    
                    [weakSelf addActionTarget:alert_jine title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
                        UITextField *textField = (UITextField *)alert_jine.textFields.firstObject;
                        
                        //原来的价格
                        originPrice = weakSelf.orderModel.orderPrice;
                        NSInteger type = weakSelf.orderModel.discountType;
                        CGFloat dis = weakSelf.orderModel.discount;
                        if (weakSelf.orderModel.discountType==-1) {
                        }else {
                            if (weakSelf.orderModel.discountType==0){
                                weakSelf.orderModel.orderPrice = weakSelf.orderModel.orderPrice*100/(100-weakSelf.orderModel.discount);
                            }else {
                                weakSelf.orderModel.orderPrice += weakSelf.orderModel.discount;
                            }
                            weakSelf.orderModel.discountType = -1;
                            weakSelf.orderModel.discount = 0;
                        }
                        
                        //恢复
                        weakSelf.orderModel.discountType = 1;
                        weakSelf.orderModel.discount = [textField.text floatValue];
                        weakSelf.orderModel.orderPrice -= [textField.text floatValue];
                        
                        AVQuery *query1 = [AVQuery queryWithClassName:@"Statistics"];
                        [query1 whereKey:@"user" equalTo:[AVUser currentUser]];
                        AVObject *statistics_post = [query1 getFirstObject];
                        [statistics_post incrementKey:@"totalProfit" byAmount:[NSNumber numberWithFloat:0-(weakSelf.orderModel.profit-[weakSelf returnProfitWithType:1])]];
                        [statistics_post incrementKey:@"tax" byAmount:[NSNumber numberWithFloat:0-(weakSelf.orderModel.tax-[weakSelf returnTaxWithType:1])]];
                        [statistics_post saveInBackground];
                        
                        weakSelf.orderModel.tax = [weakSelf returnTaxWithType:1];
                        weakSelf.orderModel.profit = [weakSelf returnProfitWithType:1];
                        [weakSelf dealDiscount:1 disType:type dis:dis];
                    }];
                    
                    [weakSelf addCancelActionTarget:alert_jine title:SetTitle(@"alert_cancel")];
                    [weakSelf presentViewController:alert_jine animated:YES completion:nil];
                }];
                
                [sheet1 addButtonWithTitle:SetTitle(@"qingchu") block:^{
                    originPrice = weakSelf.orderModel.orderPrice;
                    NSInteger type = weakSelf.orderModel.discountType;
                    CGFloat dis = weakSelf.orderModel.discount;
                    if (weakSelf.orderModel.discountType==-1) {
                    }else {
                        if (weakSelf.orderModel.discountType==0){
                            weakSelf.orderModel.orderPrice = weakSelf.orderModel.orderPrice*100/(100-weakSelf.orderModel.discount);
                        }else {
                            weakSelf.orderModel.orderPrice += weakSelf.orderModel.discount;
                        }
                        weakSelf.orderModel.discountType = -1;
                        weakSelf.orderModel.discount = 0;
                    }
                    
                    AVQuery *query1 = [AVQuery queryWithClassName:@"Statistics"];
                    [query1 whereKey:@"user" equalTo:[AVUser currentUser]];
                    AVObject *statistics_post = [query1 getFirstObject];
                    [statistics_post incrementKey:@"totalProfit" byAmount:[NSNumber numberWithFloat:0-(weakSelf.orderModel.profit-[weakSelf returnProfitWithType:-1])]];
                    [statistics_post incrementKey:@"tax" byAmount:[NSNumber numberWithFloat:0-(weakSelf.orderModel.tax-[weakSelf returnTaxWithType:-1])]];
                    [statistics_post saveInBackground];
                    
                    weakSelf.orderModel.tax = [weakSelf returnTaxWithType:-1];
                    weakSelf.orderModel.profit = [weakSelf returnProfitWithType:-1];
                    [weakSelf dealDiscount:2 disType:type dis:dis];
                }];
                
                [sheet1 setCancelButtonWithTitle:SetTitle(@"cancel") block:^{
                    
                }];
                [sheet1 showInView:weakSelf.view];
            }];
        }
        
        [sheet addButtonWithTitle:SetTitle(@"order_deliver") block:^{
            
            BlockActionSheet *sheet1 = [BlockActionSheet sheetWithTitle:@""];
            
            for (int i=0; i<[[weakSelf deliverArray] count]; i++) {
                [sheet1 addButtonWithTitle:[weakSelf deliverArray][i] block:^{
                    [weakSelf dealDeliverArray:i];
                }];
            }
            [sheet1 setCancelButtonWithTitle:SetTitle(@"cancel") block:^{
                
            }];
            [sheet1 showInView:weakSelf.view];
        }];
        
        
        [sheet addButtonWithTitle:SetTitle(@"order_pay") block:^{
            
            BlockActionSheet *sheet1 = [BlockActionSheet sheetWithTitle:@""];
            
            for (int i=0; i<[[weakSelf payArray] count]; i++) {
                [sheet1 addButtonWithTitle:[weakSelf payArray][i] block:^{
                    [weakSelf dealPayArray:i];
                }];
            }
            [sheet1 setCancelButtonWithTitle:SetTitle(@"cancel") block:^{
                
            }];
            [sheet1 showInView:weakSelf.view];
        }];
        
        if ((weakSelf.orderModel.isPay==0 && weakSelf.orderModel.isDeliver==0) || (weakSelf.orderModel.isPay==2 && weakSelf.orderModel.isDeliver==2)) {
            [sheet setDestructiveButtonWithTitle:SetTitle(@"order_delete") block:^{
                if (weakSelf.orderModel.isPay==0 && weakSelf.orderModel.isDeliver==0) {
                    [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        CGFloat profit = 0;
                        
                        for (int i=0; i<weakSelf.orderModel.productArray.count; i++) {
                            OrderStockModel *model = (OrderStockModel *)weakSelf.orderModel.productArray[i];
                            profit += model.num*model.purchasePrice;
                            
                            AVObject *orderPost = [[AVQuery queryWithClassName:@"OrderStock"] getObjectWithId:model.orderStockId];
                            [orderPost deleteEventually];
                            
                            AVObject *stockPost = [[AVQuery queryWithClassName:@"ProductStock"] getObjectWithId:model.oid];
                            ProductStockModel *model2 = [ProductStockModel initWithObject:stockPost];
                            
                            [stockPost incrementKey:[self returnSale:model.clientLevel] byAmount:[NSNumber numberWithInt:(0-(int)model.num)]];
                            [stockPost incrementKey:@"saleNum" byAmount:[NSNumber numberWithInt:(0-(int)model.num)]];
                            
                            BOOL iswarning = NO;
                            if (model2.isWarning) {
                                model2.stockNum += model.num;
                                if (model2.stockNum > model2.singleNum) {
                                    iswarning = YES;
                                    stockPost[@"isWarning"] = @(false);
                                }else {
                                    stockPost[@"isWarning"] = @(true);
                                }
                            }
                            [stockPost save];
                            
                            AVQuery *query1 = [AVQuery queryWithClassName:@"Product"];
                            [query1 whereKey:@"user" equalTo:[AVUser currentUser]];
                            [query1 whereKey:@"productCode" equalTo:model.pcode];
                            AVObject *object22 = [query1 getFirstObject];
                            
                            [object22 incrementKey:@"saleNum" byAmount:[NSNumber numberWithInt:(0-(int)model.num)]];
                            [object22 incrementKey:@"stockNum" byAmount:[NSNumber numberWithInt:(int)model.num]];
                            
                            CGFloat x = [[object22 objectForKey:@"profit"] floatValue];
                            if (weakSelf.orderModel.discountType==0){
                                x -= model.num * model.price*(100-weakSelf.orderModel.discount)/100 *(1-weakSelf.orderModel.taxNum);
                            }else if (weakSelf.orderModel.discountType==1){
                                x -= model.num * (model.price-weakSelf.orderModel.discount/weakSelf.orderModel.orderCount)*(1-weakSelf.orderModel.taxNum);
                            }else {
                                x -= model.num * model.price*(1-weakSelf.orderModel.taxNum);
                            }
                            if (x>0) {
                                object22[@"profitStatus"] = @(1);
                            }else {
                                object22[@"profitStatus"] = @(0);
                            }
                            object22[@"profit"] = @(x);
                            
                            if (iswarning) {
                                object22[@"isWarning"] = @(NO);
                            }else {
                                if ([[object22 objectForKey:@"isSetting"] boolValue]) {
                                    NSInteger stock = [[object22 objectForKey:@"stockNum"] integerValue];
                                    NSInteger total = [[object22 objectForKey:@"totalNum"] integerValue];
                                    
                                    if (stock >total) {
                                        object22[@"isWarning"] = @(NO);
                                    }
                                }
                            }
                            [object22 save];
                        }
                        
                        AVQuery *query1 = [AVQuery queryWithClassName:@"Statistics"];
                        [query1 whereKey:@"user" equalTo:[AVUser currentUser]];
                        AVObject *statistics_post = [query1 getFirstObject];
                        [statistics_post incrementKey:@"surplusStock" byAmount:[NSNumber numberWithInt:0-(int)weakSelf.orderModel.orderCount]];
                        [statistics_post incrementKey:@"surplusMoney" byAmount:[NSNumber numberWithFloat:profit]];
                        [statistics_post incrementKey:@"totalProfit" byAmount:[NSNumber numberWithFloat:0-weakSelf.orderModel.profit]];
                        [statistics_post incrementKey:@"tax" byAmount:[NSNumber numberWithFloat:0-weakSelf.orderModel.tax]];
                        [statistics_post saveInBackground];
                        
                        AVObject *client = [[AVQuery queryWithClassName:@"Client"] getObjectWithId:weakSelf.orderModel.clientId];
                        
                        [client incrementKey:@"tradeNum" byAmount:[NSNumber numberWithInt:-1]];
                        [client incrementKey:@"arrearsPrice" byAmount:[NSNumber numberWithFloat:(0-weakSelf.orderModel.orderPrice)]];
                        [client incrementKey:@"totalPrice" byAmount:[NSNumber numberWithFloat:(0-weakSelf.orderModel.orderPrice)]];
                        [client save];
                        
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            AVObject *post = [[AVQuery queryWithClassName:@"Order"] getObjectWithId:weakSelf.orderModel.orderId];
                            [post deleteEventually];
                            
                            if (weakSelf.deleteHandler) {
                                weakSelf.deleteHandler(weakSelf.idxPath);
                            }
                            
                            [weakSelf.navigationController popViewControllerAnimated:YES];
                            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                        });
                    });
                }else {
                    [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                    AVObject *post = [[AVQuery queryWithClassName:@"Order"] getObjectWithId:weakSelf.orderModel.orderId];
                    [post deleteEventually];
                    
                    if (weakSelf.deleteHandler) {
                        weakSelf.deleteHandler(weakSelf.idxPath);
                    }
                    
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                    [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                }
            }];
        }
        
        [sheet setCancelButtonWithTitle:SetTitle(@"cancel") block:^{
            
        }];
        [sheet showInView:self.view];
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
}

-(NSString *)returnSale:(NSInteger)type {
    if (type==0) {
        return @"saleA";
    }else if (type==1) {
        return @"saleB";
    }else if (type==2) {
        return @"saleC";
    }else if (type==3) {
        return @"saleD";
    }
    return @"saleA";
}

- (void)handleTextFieldTextDidChangeNotification:(NSNotification *)notification {
    UITextField *textField = notification.object;
    
    NSString *toBeString = textField.text;
    
    
    for(UITextInputMode *mode in [UITextInputMode activeInputModes]) {
        
        NSString *lang = mode.primaryLanguage;
        
        if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入
            UITextRange *selectedRange = [textField markedTextRange];
            UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
            if (!position) {
                if (toBeString.length > 2) {
                    textField.text = [toBeString substringToIndex:2];
                }
            }
        }else {
            if (toBeString.length > 2) {
                textField.text = [toBeString substringToIndex:2];
            }
        }
    }
}
@end
