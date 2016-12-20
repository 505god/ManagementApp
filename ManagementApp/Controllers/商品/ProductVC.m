//
//  ProductVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/15.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "ProductVC.h"

#import "RFSegmentView.h"
#import "RETableViewManager.h"

#import "ProductPriceVC.h"
#import "MaterialVC.h"
#import "ClassifyVC.h"
#import "StockWarningVC.h"
#import "ColorVC.h"

#import "JKImagePickerController.h"


@interface ProductVC ()<RFSegmentViewDelegate>

@property (nonatomic, strong) RFSegmentView* segmentView;

@property (nonatomic, strong) UITableView *descriptionTable;
@property (nonatomic, strong) RETableViewManager *descriptionManager;

@property (nonatomic, strong) UITableView *stockTable;
@property (nonatomic, strong) RETableViewManager *stockManager;

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, assign) CGFloat keyboardHeight;


///根据productModel判断是新建还是修改
@property (nonatomic, assign) BOOL isNew;

///编辑商品下原来的货号
@property (nonatomic, strong) NSString *product_code;

@end

@implementation ProductVC

-(void)dealloc {
    SafeRelease(_productModel);
    SafeRelease(_segmentView);
    SafeRelease(_descriptionTable);
    SafeRelease(_descriptionManager);
    SafeRelease(_stockTable);
    SafeRelease(_stockManager);
}

#pragma mark - lifeStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.clipsToBounds = YES;
    
    if (self.productModel) {
        self.isNew = NO;
        
        self.product_code = self.productModel.productCode;
    }else {
        self.isNew = YES;
        self.productModel = [[ProductModel alloc]init];
        self.productModel.profitStatus = 0;
        self.productModel.isDisplay = YES;
        self.productModel.isHot = YES;
        self.productModel.selected = -1;
    }
    
    self.currentPage = 0;
    
    [self setNavBarView];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillShowKeyboardNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillHideKeyboardNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - getter/setter



#pragma mark - UI

-(void)setNavBarView {
    
    //左侧名称显示的分类名称
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.navBarView setRightWithArray:@[@"ok_bt"] type:0];
    [self.navBarView setTitle:self.isNew?SetTitle(@"product"):self.productModel.productCode image:nil];
    [self.view addSubview:self.navBarView];
    
    [self setSegmentControl];
}

-(void)setSegmentControl {
    self.segmentView = [[RFSegmentView alloc] initWithFrame:(CGRect){10,self.navBarView.bottom+10,[UIScreen mainScreen].bounds.size.width-20,40} items:@[SetTitle(@"Description"),SetTitle(@"stock")]];
    self.segmentView.tintColor       = COLOR(80, 80, 80, 1);
    self.segmentView.delegate        = self;
    self.segmentView.selectedIndex   = 0;
    [self.view addSubview:self.segmentView];
    
    UIImageView *img = [[UIImageView alloc]initWithFrame:(CGRect){0,self.segmentView.bottom+10,[UIScreen mainScreen].bounds.size.width,0.5}];
    img.backgroundColor = COLOR(80, 80, 80, 1);
    [self.view addSubview:img];
    
    [self setDescriptionTableView];
    [self setStockTableView];
    
    [self.view bringSubviewToFront:img];
    img = nil;
}

-(void)setDescriptionTableView {
    self.descriptionTable = [[UITableView alloc]initWithFrame:(CGRect){0,self.navBarView.bottom+60,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height-self.navBarView.bottom-60} style:UITableViewStylePlain];
    [Utility setExtraCellLineHidden:self.descriptionTable];
    [self.view addSubview:self.descriptionTable];
    
    // Create manager
    _descriptionManager = [[RETableViewManager alloc] initWithTableView:self.descriptionTable];
    
    // Add a section
    RETableViewSection *section = [RETableViewSection section];
    [_descriptionManager addSection:section];
    
    // Add items
    __weak __typeof(self)weakSelf = self;
    //货号必填
    RETextItem *codeItem = [RETextItem itemWithTitle:SetTitle(@"product_code") value:self.productModel.productCode.length>0?self.productModel.productCode:@"" placeholder:SetTitle(@"product_required")];
    codeItem.onChange = ^(RETextItem *item){
        weakSelf.productModel.productCode = item.value;
    };
    codeItem.alignment = NSTextAlignmentRight;
    [section addItem:codeItem];
    
    //价格选择
    NSString *value = @"";
    UIImage *infoImage = nil;
    if (self.productModel.selected>=0) {
        if (self.productModel.selected==0) {
            value = [NSString stringWithFormat:@"%.2f",self.productModel.aPrice];
            infoImage = [Utility getImgWithImageName:@"charc_1_28@2x"];
        }else if (self.productModel.selected==1) {
            value = [NSString stringWithFormat:@"%.2f",self.productModel.bPrice];
            infoImage = [Utility getImgWithImageName:@"charc_2_28@2x"];
        }
        else if (self.productModel.selected==2) {
            value = [NSString stringWithFormat:@"%.2f",self.productModel.cPrice];
            infoImage = [Utility getImgWithImageName:@"charc_3_28@2x"];
        }
        else if (self.productModel.selected==3) {
            value = [NSString stringWithFormat:@"%.2f",self.productModel.dPrice];
            infoImage = [Utility getImgWithImageName:@"charc_4_28@2x"];
        }
    }else {
        if (self.productModel.aPrice>0) {
            value = [NSString stringWithFormat:@"%.2f",self.productModel.aPrice];
            infoImage = [Utility getImgWithImageName:@"charc_1_28@2x"];
        }else {
            value = @"";
            infoImage = nil;
        }
    }
    RERadioItem *radioItem = [RERadioItem itemWithTitle:SetTitle(@"sale_price") value:value selectionHandler:^(RERadioItem *item) {
        [item deselectRowAnimated:YES];
        
        ProductPriceVC *priceVC = LOADVC(@"ProductPriceVC");
        
        priceVC.productPriceModel = weakSelf.productModel;
        priceVC.completedBlock = ^(ProductModel *productPriceModel, BOOL editting){
            if (editting) {
                weakSelf.productModel.selected = productPriceModel.selected;
                weakSelf.productModel.aPrice = productPriceModel.aPrice;
                weakSelf.productModel.bPrice = productPriceModel.bPrice;
                weakSelf.productModel.cPrice = productPriceModel.cPrice;
                weakSelf.productModel.dPrice = productPriceModel.dPrice;
                
                if (productPriceModel.selected==0) {
                    item.value = [NSString stringWithFormat:@"%.2f",productPriceModel.aPrice];
                    item.infoImg = [Utility getImgWithImageName:@"charc_1_28@2x"];
                }else if (productPriceModel.selected==1) {
                    item.value = [NSString stringWithFormat:@"%.2f",productPriceModel.bPrice];
                    item.infoImg = [Utility getImgWithImageName:@"charc_2_28@2x"];
                }
                else if (productPriceModel.selected==2) {
                    item.value = [NSString stringWithFormat:@"%.2f",productPriceModel.cPrice];
                    item.infoImg = [Utility getImgWithImageName:@"charc_3_28@2x"];
                }
                else if (productPriceModel.selected==3) {
                    item.value = [NSString stringWithFormat:@"%.2f",productPriceModel.dPrice];
                    item.infoImg = [Utility getImgWithImageName:@"charc_4_28@2x"];
                }else {
                    item.value = [NSString stringWithFormat:@"%.2f",productPriceModel.aPrice];
                    item.infoImg = [Utility getImgWithImageName:@"charc_1_28@2x"];
                }
                
                [item reloadRowWithAnimation:UITableViewRowAnimationNone];
            }
        };
        [weakSelf.navigationController pushViewController:priceVC animated:YES];
        SafeRelease(priceVC);
        
    }];
    radioItem.infoImg = infoImage;
    [section addItem:radioItem];
    
    //进货价
    RETextItem *purchaseItem = [RETextItem itemWithTitle:SetTitle(@"purchase_price") value:self.productModel.purchaseprice==0?@"":[NSString stringWithFormat:@"%.2f",self.productModel.purchaseprice] placeholder:SetTitle(@"product_required")];
    purchaseItem.onChange = ^(RETextItem *item){
        //判读是否为数字
        if ([Utility predicateText:item.value regex:@"^[0-9]+(.[0-9]{1,2})?$"]){
            item.textFieldColor = [UIColor blackColor];
            weakSelf.productModel.purchaseprice = [item.value floatValue];
            weakSelf.productModel.profitStatus = 0;
        }else {
            weakSelf.productModel.profitStatus = -1;
            item.textFieldColor = kDeleteColor;
        }
    };
    purchaseItem.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    purchaseItem.alignment = NSTextAlignmentRight;
    [section addItem:purchaseItem];
    
    //详情
    RELongTextItem *longTextItem = [RELongTextItem itemWithValue:nil placeholder:SetTitle(@"product_detail")];
    longTextItem.onChange = ^(RETextItem *item){
        weakSelf.productModel.productDetails = item.value;
    };
    longTextItem.cellHeight = 88;
    [section addItem:longTextItem];
    
    //包装数
    self.productModel.packageNum = 1;
    REPickerItem *pickerItem = [REPickerItem itemWithTitle:SetTitle(@"product_package") value:@[@"1"] placeholder:nil options:@[@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30"]]];
    pickerItem.onChange = ^(REPickerItem *item){
        weakSelf.productModel.packageNum =  [item.value[0] integerValue];
    };
    pickerItem.inlinePicker = YES;
    [section addItem:pickerItem];
    
    //名称
    RETextItem *nameItem = [RETextItem itemWithTitle:SetTitle(@"product_name") value:self.productModel.productName?self.productModel.productName:@"" placeholder:SetTitle(@"product_required")];
    nameItem.enabled = !self.isEditing;//编辑状态下不可更改
    nameItem.onChange = ^(RETextItem *item){
        weakSelf.productModel.productName = item.value;
    };
    nameItem.alignment = NSTextAlignmentRight;
    [section addItem:nameItem];
    
    //材质
    RERadioItem *materialItem = [RERadioItem itemWithTitle:SetTitle(@"material") value:self.productModel.materialModel?self.productModel.materialModel.materialName:@"" selectionHandler:^(RERadioItem *item) {
        [item deselectRowAnimated:YES];
        
        MaterialVC *materialVC = [[MaterialVC alloc]init];
        materialVC.isSelectedMaterial = YES;
        if (weakSelf.productModel.materialModel) {
            materialVC.selectedMaterialModel = weakSelf.productModel.materialModel;
        }
        materialVC.completedBlock = ^(MaterialModel *materialModel){
            if (materialModel != nil) {
                item.value = materialModel.materialName;
            }else {
                item.value = @"";
            }
            weakSelf.productModel.materialModel = materialModel;
            [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        };
        [weakSelf.navigationController pushViewController:materialVC animated:YES];
        SafeRelease(materialVC);
        
    }];
    [section addItem:materialItem];
    
    //分类
    RERadioItem *classifyItem = [RERadioItem itemWithTitle:SetTitle(@"classify") value:self.productModel.sortModel?self.productModel.sortModel.sortName:@"" selectionHandler:^(RERadioItem *item) {
        [item deselectRowAnimated:YES];
        
        ClassifyVC *classifyVC = [[ClassifyVC alloc]init];
        classifyVC.isSelectedClassify = YES;
        if (weakSelf.productModel.sortModel) {
            classifyVC.selectedSortModel = weakSelf.productModel.sortModel;
        }
        classifyVC.completedBlock = ^(SortModel *sortModel){
            if (sortModel != nil) {
                item.value = sortModel.sortName;
            }else {
                item.value = @"";
            }
            
            weakSelf.productModel.sortModel = sortModel;
            [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        };
        [weakSelf.navigationController pushViewController:classifyVC animated:YES];
        SafeRelease(classifyVC);
        
    }];
    [section addItem:classifyItem];
    
    //备注
    RETextItem *markItem = [RETextItem itemWithTitle:SetTitle(@"product_mark") value:self.productModel.productMark?self.productModel.productMark:@"" placeholder:SetTitle(@"product_set")];
    markItem.onChange = ^(RETextItem *item){
        weakSelf.productModel.productMark = item.value;
    };
    markItem.alignment = NSTextAlignmentRight;
    [section addItem:markItem];
    
    //上架
    REBoolItem *displayItem = [REBoolItem itemWithTitle:SetTitle(@"product_display") value:YES switchValueChangeHandler:^(REBoolItem *item) {
        weakSelf.productModel.isDisplay = item.value;
    }];
    [section addItem:displayItem];
    
    //热卖
    REBoolItem *promotionlItem = [REBoolItem itemWithTitle:SetTitle(@"product_promotion") value:YES switchValueChangeHandler:^(REBoolItem *item) {
        weakSelf.productModel.isHot = item.value;
    }];
    [section addItem:promotionlItem];
    
    //库存警告
    RERadioItem *stockItem = [RERadioItem itemWithTitle:SetTitle(@"stock_warning") value:@"" selectionHandler:^(RERadioItem *item) {
        [item deselectRowAnimated:YES];
        
        StockWarningVC *stockVC = [[StockWarningVC alloc]init];
        
        stockVC.stockWarningModel = weakSelf.productModel;
        stockVC.completedBlock = ^(ProductModel *stockWarningModel,BOOL editting){
            if (editting) {
                weakSelf.productModel.isSetting = stockWarningModel.isSetting;
                weakSelf.productModel.totalNum = stockWarningModel.totalNum;
                weakSelf.productModel.singleNum = stockWarningModel.singleNum;
            }
        };
        [weakSelf.navigationController pushViewController:stockVC animated:YES];
        SafeRelease(stockVC);
        
    }];
    [section addItem:stockItem];
    
//    //优惠选择
//    RERadioItem *discountItem = [RERadioItem itemWithTitle:SetTitle(@"product_disount") value:@"" selectionHandler:^(RERadioItem *item) {
//        [item deselectRowAnimated:YES];
//        
//        DiscountVC *stockVC = [[DiscountVC alloc]init];
//        
//        stockVC.discountType = weakSelf.productModel.discountType;
//        stockVC.discount = weakSelf.productModel.discount;
//        
//        stockVC.completedBlock = ^(NSInteger discountType,CGFloat discount){
//            weakSelf.productModel.discountType = discountType;
//            
//            weakSelf.productModel.discount = discount;
//        };
//        [weakSelf.navigationController pushViewController:stockVC animated:YES];
//        SafeRelease(stockVC);
//        
//    }];
//    [section addItem:discountItem];
}

-(void)setStockTableView {
    self.stockTable = [[UITableView alloc]initWithFrame:(CGRect){[UIScreen mainScreen].bounds.size.width,self.navBarView.bottom+60,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height-self.navBarView.bottom-60} style:UITableViewStylePlain];
    self.stockTable.backgroundColor = [UIColor whiteColor];
    [Utility setExtraCellLineHidden:self.stockTable];
    [self.view addSubview:self.stockTable];
    
    // Create manager
    _stockManager = [[RETableViewManager alloc] initWithTableView:self.stockTable];
    
    // Add a section
    RETableViewSection *section = [RETableViewSection section];
    [_stockManager addSection:section];
    
    // Add Item
    //选择颜色后保存的item数组
    NSMutableArray *expandedItems = [NSMutableArray array];
    NSMutableArray *collapsedItems = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    
    if (self.productModel.productStockArray.count>0) {
        for (int i=0; i<self.productModel.productStockArray.count; i++) {
            ProductStockModel *model = (ProductStockModel *)self.productModel.productStockArray[i];
            
            REProductItem *picItem = [self returnProductItemWithTitle:model.colorModel.colorName value:[NSString stringWithFormat:@"%d",(int)model.stockNum] image:nil imageString:model.picHeader bySection:section index:i isExit:model.isExit];
            
            [section addItem:picItem];
        }
    }
    
    RETableViewItem *buttonItem = [RETableViewItem itemWithTitle:SetTitle(@"addColor") accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        
        [weakSelf.view endEditing:YES];
        //颜色model的数组
        NSMutableArray *colorArray = [NSMutableArray array];
        
        NSMutableArray *tempArray = [NSMutableArray array];
        
        if (weakSelf.productModel.productStockArray.count>0) {
            for (int i=0; i<weakSelf.productModel.productStockArray.count; i++) {
                ProductStockModel *model = (ProductStockModel *)weakSelf.productModel.productStockArray[i];
                
                model.colorModel.index = i;
                [colorArray addObject:model.colorModel];
            }
        }
        
        ColorVC *colorVC = [[ColorVC alloc]init];
        colorVC.isSelectedColor = YES;
        colorVC.hasSelectedColor = [NSMutableArray arrayWithArray:colorArray];
        colorVC.completedBlock = ^(NSArray *array){
            //比较原有的颜色数组和颜色页面传过来的
            for (int i=0; i<array.count; i++) {
                ColorModel *colorModel = (ColorModel *)array[i];
                
                if (colorArray.count>0) {
                    NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"colorId == %@", colorModel.colorId];
                    NSMutableArray *filteredArray = [NSMutableArray arrayWithArray:[colorArray filteredArrayUsingPredicate:predicateString]];
                    if (filteredArray.count>0) {
                        ColorModel *colorModel2 = filteredArray[0];
                        [tempArray addObject:weakSelf.productModel.productStockArray[colorModel2.index]];
                    }else {
                        ProductStockModel *model2 = [[ProductStockModel alloc]init];
                        model2.colorModel = colorModel;
                        [tempArray addObject:model2];
                    }
                }else {
                    ProductStockModel *model2 = [[ProductStockModel alloc]init];
                    model2.colorModel = colorModel;
                    [tempArray addObject:model2];
                }
            }
            
            weakSelf.productModel.productStockArray = nil;
            [weakSelf.productModel.productStockArray addObjectsFromArray:tempArray];
            [expandedItems removeAllObjects];
            
            for (int i=0; i<tempArray.count; i++) {
                ProductStockModel *model = (ProductStockModel *)tempArray[i];
                
                REProductItem *picItem = [weakSelf returnProductItemWithTitle:model.colorModel?model.colorModel.colorName:@"" value:[NSString stringWithFormat:@"%d",(int)model.stockNum] image:model.picHeader?nil:model.image imageString:model.picHeader?model.picHeader:nil bySection:section index:i isExit:model.isExit];
                [expandedItems addObject:picItem];
            }
            [expandedItems addObjectsFromArray:collapsedItems];
            [section replaceItemsWithItemsFromArray:expandedItems];
            [section reloadSectionWithAnimation:UITableViewRowAnimationAutomatic];
        };
        [weakSelf.navigationController pushViewController:colorVC animated:YES];
        SafeRelease(colorVC);
    }];
    buttonItem.textAlignment = NSTextAlignmentCenter;
    [section addItem:buttonItem];
    
    [collapsedItems addObject:buttonItem];
}

-(REProductItem *)returnProductItemWithTitle:(NSString *)string value:(NSString *)value image:(UIImage *)image imageString:(NSString *)imageString bySection:(RETableViewSection *)section index:(NSInteger)index isExit:(BOOL)isExit{
    __weak typeof(self) weakSelf = self;
    
    REProductItem *picItem = [REProductItem itemWithTitle:string value:value placeholder:@"0" image:image imageString:imageString];
    picItem.cellHeight = 88;
    picItem.index = index;
    picItem.isEditing = isExit;
    picItem.deleteHandler = ^(REProductItem *item){
        [weakSelf.productModel.productStockArray removeObjectAtIndex:index];
        [section removeItem:item];
        [section reloadSectionWithAnimation:UITableViewRowAnimationAutomatic];
    };
    
    picItem.onEndEditing = ^(RETextItem *item) {
        ProductStockModel *model = (ProductStockModel *)weakSelf.productModel.productStockArray[index];
        model.stockNum = [item.value integerValue];
    };
    
    picItem.selectedPictureHandler= ^(REProductItem *item) {
        [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
        
        __block JKImagePickerController *imagePicker = [[JKImagePickerController alloc] init];
        imagePicker.allowsMultipleSelection = NO;
        imagePicker.minimumNumberOfSelection = 1;
        imagePicker.maximumNumberOfSelection = 1;
        
        imagePicker.selectAssets = ^(JKImagePickerController *imagePicker,NSArray *assets){
            JKAssets *asset = (JKAssets *)assets[0];
            
            __block UIImage *image = nil;
            ALAssetsLibrary   *lib = [[ALAssetsLibrary alloc] init];
            [lib assetForURL:asset.assetPropertyURL resultBlock:^(ALAsset *asset) {
                if (asset) {
                    UIImage *tempImg = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                    image = [Utility dealImageData:tempImg];//图片处理
                    SafeRelease(tempImg);
                }
            } failureBlock:^(NSError *error) {
                [PopView showWithImageName:@"error" message:SetTitle(@"PhotoSelectedError")];
                [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
            }];
            
            [imagePicker dismissViewControllerAnimated:YES completion:^{
                ProductStockModel *model = (ProductStockModel *)weakSelf.productModel.productStockArray[index];
                model.image = image;
                model.picHeader = nil;
                item.imageString = nil;
                item.picImg = image;
                [item reloadRowWithAnimation:UITableViewRowAnimationNone];
                
                [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
            }];
            
        };
        imagePicker.cancelAssets = ^(JKImagePickerController *imagePicker){
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
            [imagePicker dismissViewControllerAnimated:YES completion:^{
            }];
        };
        
        [weakSelf.view.window.rootViewController presentViewController:imagePicker animated:YES completion:^{
            SafeRelease(imagePicker);
        }];
    };
    
    return picItem;
}

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    [self.navigationController popViewControllerAnimated:YES];
}

static NSString * materialId = nil;
static NSString * sortId = nil;
-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    [self.view endEditing:YES];
    
    if (![DataShare sharedService].appDel.isReachable) {
        [PopView showWithImageName:@"error" message:SetTitle(@"no_connect")];
        return;
    }
    
    NSString *msg = @"";
    if (self.productModel.productCode.length==0) {
        msg = SetTitle(@"product_code_error");
    }else if (self.productModel.aPrice==0 || self.productModel.bPrice==0 || self.productModel.cPrice==0 || self.productModel.dPrice==0) {
        msg = SetTitle(@"sale_price_error");
    }else if (self.productModel.purchaseprice == 0) {
        msg = SetTitle(@"purchase_price_error");
    }else if (self.productModel.productName.length == 0) {
        msg = SetTitle(@"product_name_error");
    }
    
    if (msg.length>0) {
        [PopView showWithImageName:nil message:msg];
        
        return;
    }
    
    //货号--------------------------------------------------
    if (self.product_code && [self.product_code isEqualToString:self.productModel.productCode]) {
        //存在且未改变
    }else {
        AVQuery *code_query = [AVQuery queryWithClassName:@"ProductCode"];
        [code_query whereKey:@"pcode" equalTo:self.productModel.productCode];
        [code_query whereKey:@"user" equalTo:[AVUser currentUser]];
        
        NSInteger code_num = [code_query countObjects];
        if (code_num>0) {
            [PopView showWithImageName:@"error" message:SetTitle(@"productError")];
            return;
        }else {
            //货号－－－－－－－－－－－－－－－－－－－－－－－－－
            AVObject *code_post = [AVObject objectWithClassName:@"ProductCode"];
            code_post[@"pcode"] = self.productModel.productCode;
            [code_post setObject:[AVUser currentUser] forKey:@"user"];
            [code_post saveInBackground];
        }
    }
    
    //统计--------------------------------------------------
    AVQuery *statistics_query = [AVQuery queryWithClassName:@"Statistics"];
    [statistics_query whereKey:@"user" equalTo:[AVUser currentUser]];
    AVObject *statistics_post = [statistics_query getFirstObject];
    
    if (!statistics_post) {
        statistics_post = [AVObject objectWithClassName:@"Statistics"];
        [statistics_post setObject:[AVUser currentUser] forKey:@"user"];
    }
    
    
    __weak __typeof(self)weakSelf = self;
    if ([Utility checkString:self.productModel.productId] && self.isEditing) {//修改商品
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"product_editing") message:[NSString stringWithFormat:@"%@:%@",SetTitle(@"product_code"),self.productModel.productCode] preferredStyle:UIAlertControllerStyleAlert];
        [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
            [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                AVObject *post = [[AVQuery queryWithClassName:@"Product"] getObjectWithId:weakSelf.productModel.productId];
                
                post[@"productCode"] = weakSelf.productModel.productCode;
                post[@"purchasePrice"] = @(weakSelf.productModel.purchaseprice);
                post[@"remark"] = weakSelf.productModel.productMark;
                post[@"hot"] = @(weakSelf.productModel.isHot);
                post[@"details"] = weakSelf.productModel.productDetails;
                post[@"sale"] = @(weakSelf.productModel.isDisplay);
                post[@"profitStatus"] = @(weakSelf.productModel.profitStatus);
                post[@"packingNumber"] = @(weakSelf.productModel.packageNum);
                post[@"productName"] = weakSelf.productModel.productName;
                post[@"isSetting"] = @(weakSelf.productModel.isSetting);
                post[@"totalNum"] = @(weakSelf.productModel.totalNum);
                post[@"singleNum"] = @(weakSelf.productModel.singleNum);
                post[@"a"] = @(weakSelf.productModel.aPrice);
                post[@"b"] = @(weakSelf.productModel.bPrice);
                post[@"c"] = @(weakSelf.productModel.cPrice);
                post[@"d"] = @(weakSelf.productModel.dPrice);
                post[@"selected"] = @(weakSelf.productModel.selected);
                if (weakSelf.productModel.productStockArray.count>0) {
                    NSInteger num = 0;
                    for (int i=0; i<weakSelf.productModel.productStockArray.count; i++) {
                        ProductStockModel *model = (ProductStockModel *)weakSelf.productModel.productStockArray[i];
                        num += model.stockNum-(model.num-model.saleANum-model.saleBNum-model.saleCNum-model.saleDNum);
                        
                    }
                    [post incrementKey:@"stockNum" byAmount:[NSNumber numberWithInteger:num]];
                    post[@"profit"] = @(weakSelf.productModel.profit-weakSelf.productModel.purchaseprice*num);
                    
                    //------------------------------------------
                    [statistics_post incrementKey:@"totalStock" byAmount:[NSNumber numberWithInt:(int)num]];
                    [statistics_post incrementKey:@"totalMoney" byAmount:[NSNumber numberWithFloat:num *weakSelf.productModel.purchaseprice]];
                    [statistics_post saveInBackground];
                    
                    //颜色----------------------------------------
                    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
                    
                    BOOL isExit = NO;
                    for (int i=0; i<weakSelf.productModel.productStockArray.count; i++) {
                        
                        ProductStockModel *model = (ProductStockModel *)weakSelf.productModel.productStockArray[i];
                        
                        if ([Utility checkString:model.ProductStockId]) {
                            //修改的
                            AVObject *p_post = [[AVQuery queryWithClassName:@"ProductStock"] getObjectWithId:model.ProductStockId];
                            
                            NSInteger num = model.stockNum-(model.num-model.saleANum-model.saleBNum-model.saleCNum-model.saleDNum);
                            p_post[@"stockNum"] = @(model.num+num);
                            p_post[@"hot"] = @(weakSelf.productModel.isHot);
                            p_post[@"sale"] = @(weakSelf.productModel.isDisplay);
                            p_post[@"pcode"] = weakSelf.productModel.productCode;
                            p_post[@"a"] = @(weakSelf.productModel.aPrice);
                            p_post[@"b"] = @(weakSelf.productModel.bPrice);
                            p_post[@"c"] = @(weakSelf.productModel.cPrice);
                            p_post[@"d"] = @(weakSelf.productModel.dPrice);
                            p_post[@"purchasePrice"] = @(weakSelf.productModel.purchaseprice);
                            p_post[@"details"] = weakSelf.productModel.productDetails;
                            p_post[@"selected"] = @(weakSelf.productModel.selected);
                            p_post[@"isSetting"] = @(weakSelf.productModel.isSetting);
                            p_post[@"singleNum"] = @(weakSelf.productModel.singleNum);
                            
                            if (model.image) {
                                AVFile *attachment = [p_post objectForKey:@"header"];
                                [attachment deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                }];
                                
                                NSData *imageData = UIImageJPEGRepresentation(model.image,0.8);
                                AVFile *imageFile = [AVFile fileWithName:@"image.png" data:imageData];
                                [p_post setObject:imageFile  forKey:@"header"];
                                if (!isExit) {
                                    [post setObject:imageFile forKey:@"header"];
                                    isExit = true;
                                }
                            }
                            
                            //材质
                            if (weakSelf.productModel.materialModel!=nil && ![weakSelf.productModel.materialModel.materialId isEqualToString:weakSelf.productModel.materialId]) {
                                materialId = weakSelf.productModel.materialId;
                                AVObject *mPost = [[AVQuery queryWithClassName:@"Material"] getObjectWithId:weakSelf.productModel.materialModel.materialId];
                                [post setObject:mPost forKey:@"material"];
                                [p_post setObject:mPost forKey:@"material"];
                                
                                weakSelf.productModel.materialId = weakSelf.productModel.materialModel.materialId;
                            }
                            
                            //分类
                            if (weakSelf.productModel.sortModel!=nil && ![weakSelf.productModel.sortModel.sortId isEqualToString:weakSelf.productModel.sortId]) {
                                sortId = weakSelf.productModel.sortId;
                                AVObject *cPost = [[AVQuery queryWithClassName:@"Sort"] getObjectWithId:weakSelf.productModel.sortModel.sortId];
                                [post setObject:cPost forKey:@"sort"];
                                [p_post setObject:cPost forKey:@"sort"];
                                
                                weakSelf.productModel.sortId = weakSelf.productModel.sortModel.sortId;
                            }
                            
                            [tempArray addObject:p_post];
                        }else {
                            AVObject *stockPost = [AVObject objectWithClassName:@"ProductStock"];
                            
                            stockPost[@"details"] = weakSelf.productModel.productDetails;
                            stockPost[@"stockNum"] = @(model.stockNum);
                            stockPost[@"hot"] = @(weakSelf.productModel.isHot);
                            stockPost[@"sale"] = @(weakSelf.productModel.isDisplay);
                            stockPost[@"pcode"] = weakSelf.productModel.productCode;
                            stockPost[@"a"] = @(weakSelf.productModel.aPrice);
                            stockPost[@"b"] = @(weakSelf.productModel.bPrice);
                            stockPost[@"c"] = @(weakSelf.productModel.cPrice);
                            stockPost[@"d"] = @(weakSelf.productModel.dPrice);
                            stockPost[@"purchasePrice"] = @(weakSelf.productModel.purchaseprice);
                            stockPost[@"selected"] = @(weakSelf.productModel.selected);
                            stockPost[@"isSetting"] = @(weakSelf.productModel.isSetting);
                            stockPost[@"singleNum"] = @(weakSelf.productModel.singleNum);
                            [stockPost setObject:[AVUser currentUser] forKey:@"user"];
                            
                            if (weakSelf.productModel.isSetting) {
                                if (model.stockNum<weakSelf.productModel.singleNum) {
                                    stockPost[@"isWarning"] = @(true);
                                }
                            }
                            
                            if (model.image) {
                                NSData *imageData = UIImageJPEGRepresentation(model.image,0.8);
                                AVFile *imageFile = [AVFile fileWithName:@"image.png" data:imageData];
                                [stockPost setObject:imageFile forKey:@"header"];
                                
                                if (!isExit) {
                                    [post setObject:imageFile forKey:@"header"];
                                    isExit = true;
                                }
                            }
                            
                            //材质
                            if (weakSelf.productModel.materialModel!=nil) {
                                AVObject *mPost = [[AVQuery queryWithClassName:@"Material"] getObjectWithId:weakSelf.productModel.materialModel.materialId];
                                [post setObject:mPost forKey:@"material"];
                                [stockPost setObject:mPost forKey:@"material"];
                            }
                            
                            //分类
                            if (weakSelf.productModel.sortModel!=nil) {
                                AVObject *cPost = [[AVQuery queryWithClassName:@"Sort"] getObjectWithId:weakSelf.productModel.sortModel.sortId];
                                [post setObject:cPost forKey:@"sort"];
                                [stockPost setObject:cPost forKey:@"sort"];
                            }
                            
                            //颜色
                            AVObject *cPost = [[AVQuery queryWithClassName:@"Color"] getObjectWithId:model.colorModel.colorId];
                            [stockPost setObject:cPost forKey:@"color"];
                            stockPost[@"colorName"] = model.colorModel.colorName;
                            
                            [tempArray addObject:stockPost];
                        }
                    }
                    
                    [AVObject saveAll:tempArray];
                    
                    [post addUniqueObjectsFromArray:tempArray forKey:@"products"];
                }else {
                    //材质
                    if (weakSelf.productModel.materialModel!=nil && ![weakSelf.productModel.materialModel.materialId isEqualToString:weakSelf.productModel.materialId]) {
                        materialId = weakSelf.productModel.materialId;
                        AVObject *mPost = [[AVQuery queryWithClassName:@"Material"] getObjectWithId:weakSelf.productModel.materialModel.materialId];
                        [post setObject:mPost forKey:@"material"];
                        
                        weakSelf.productModel.materialId = weakSelf.productModel.materialModel.materialId;
                    }
                    
                    //分类
                    if (weakSelf.productModel.sortModel!=nil && ![weakSelf.productModel.sortModel.sortId isEqualToString:weakSelf.productModel.sortId]) {
                        sortId = weakSelf.productModel.sortId;
                        AVObject *cPost = [[AVQuery queryWithClassName:@"Sort"] getObjectWithId:weakSelf.productModel.sortModel.sortId];
                        [post setObject:cPost forKey:@"sort"];
                        
                        weakSelf.productModel.sortId = weakSelf.productModel.sortModel.sortId;
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //保存
                    [AVObject saveAllInBackground:@[post] block:^(BOOL succeeded, NSError *error) {
                        if (!error) {
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                //材质
                                if (weakSelf.productModel.materialModel!=nil && [Utility checkString:materialId]) {
                                    AVObject *mPost = [[AVQuery queryWithClassName:@"Material"] getObjectWithId:weakSelf.productModel.materialModel.materialId];
                                    [mPost incrementKey:@"productCount"];
                                    [mPost save];
                                    
                                    AVObject *mmPost = [[AVQuery queryWithClassName:@"Material"] getObjectWithId:materialId];
                                    [mmPost incrementKey:@"productCount" byAmount:[NSNumber numberWithInt:(-1)]];
                                    [mmPost save];
                                    
                                    materialId = nil;
                                }
                                
                                //分类
                                if (weakSelf.productModel.sortModel!=nil && [Utility checkString:sortId]) {
                                    AVObject *cPost = [[AVQuery queryWithClassName:@"Sort"] getObjectWithId:weakSelf.productModel.sortModel.sortId];
                                    [cPost incrementKey:@"productCount"];
                                    [cPost save];
                                    
                                    AVObject *ccPost = [[AVQuery queryWithClassName:@"Sort"] getObjectWithId:sortId];
                                    [ccPost incrementKey:@"productCount" byAmount:[NSNumber numberWithInt:(-1)]];
                                    [ccPost save];
                                    
                                    sortId = nil;
                                }
                                //颜色
                                if (weakSelf.productModel.productStockArray.count>0) {
                                    for (int i=0; i<weakSelf.productModel.productStockArray.count; i++) {
                                        ProductStockModel *model = (ProductStockModel *)weakSelf.productModel.productStockArray[i];
                                        
                                        if (![Utility checkString:model.ProductStockId]) {
                                            AVObject *cPost = [[AVQuery queryWithClassName:@"Color"] getObjectWithId:model.colorModel.colorId];
                                            [cPost incrementKey:@"productCount"];
                                            [cPost save];
                                        }
                                    }
                                }
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                                    [weakSelf.navigationController popViewControllerAnimated:YES];
                                });
                            });
                        }else {
                            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                        }
                    }];
                    
                });
            });
        }];
        [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
        [self presentViewController:alert animated:YES completion:nil];
    }else {//创建商品
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:SetTitle(@"product_creat") message:[NSString stringWithFormat:@"%@:%@",SetTitle(@"product_code"),self.productModel.productCode] preferredStyle:UIAlertControllerStyleAlert];
        [self addActionTarget:alert title:SetTitle(@"alert_confirm") color:kThemeColor action:^(UIAlertAction *action) {
            [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //保存对象
                AVObject *post = [AVObject objectWithClassName:@"Product"];
                [post setObject:[AVUser currentUser] forKey:@"user"];
                post[@"productCode"] = weakSelf.productModel.productCode;
                post[@"purchasePrice"] = @(weakSelf.productModel.purchaseprice);
                post[@"remark"] = weakSelf.productModel.productMark;
                post[@"hot"] = @(weakSelf.productModel.isHot);
                post[@"details"] = weakSelf.productModel.productDetails;
                post[@"sale"] = @(weakSelf.productModel.isDisplay);
                post[@"profitStatus"] = @(weakSelf.productModel.profitStatus);
                post[@"isSetting"] = @(weakSelf.productModel.isSetting);
                post[@"totalNum"] = @(weakSelf.productModel.totalNum);
                post[@"singleNum"] = @(weakSelf.productModel.singleNum);
                post[@"packingNumber"] = @(weakSelf.productModel.packageNum);
                post[@"productName"] = weakSelf.productModel.productName;
                post[@"a"] = @(weakSelf.productModel.aPrice);
                post[@"b"] = @(weakSelf.productModel.bPrice);
                post[@"c"] = @(weakSelf.productModel.cPrice);
                post[@"d"] = @(weakSelf.productModel.dPrice);
                post[@"selected"] = @(weakSelf.productModel.selected);
                
                if (weakSelf.productModel.productStockArray.count>0) {
                    NSInteger num = 0;//总的库存－－－－－
                    for (int i=0; i<weakSelf.productModel.productStockArray.count; i++) {
                        ProductStockModel *model = (ProductStockModel *)weakSelf.productModel.productStockArray[i];
                        num += model.stockNum;
                    }
                    //------------------------------------------
                    [statistics_post incrementKey:@"totalStock" byAmount:[NSNumber numberWithInt:(int)num]];
                    [statistics_post incrementKey:@"totalMoney" byAmount:[NSNumber numberWithFloat:num *weakSelf.productModel.purchaseprice]];
                    [statistics_post incrementKey:@"surplusMoney" byAmount:[NSNumber numberWithFloat:num *weakSelf.productModel.purchaseprice]];
                    [statistics_post saveInBackground];
                    
                    post[@"stockNum"] = @(num);
                    post[@"profit"] = @(-num*weakSelf.productModel.purchaseprice);
                    
                    if (weakSelf.productModel.isSetting) {
                        if (num<weakSelf.productModel.totalNum) {
                            post[@"isWarning"] = @(true);
                        }
                    }
                    
                    //颜色----------------------------------------
                    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
                    
                    BOOL isExit = NO;
                    for (int i=0; i<weakSelf.productModel.productStockArray.count; i++) {
                        AVObject *stockPost = [AVObject objectWithClassName:@"ProductStock"];
                        
                        ProductStockModel *model = (ProductStockModel *)weakSelf.productModel.productStockArray[i];
                        stockPost[@"details"] = weakSelf.productModel.productDetails;
                        stockPost[@"stockNum"] = @(model.stockNum);
                        stockPost[@"hot"] = @(weakSelf.productModel.isHot);
                        stockPost[@"sale"] = @(weakSelf.productModel.isDisplay);
                        stockPost[@"pcode"] = weakSelf.productModel.productCode;
                        [stockPost setObject:[AVUser currentUser] forKey:@"user"];
                        stockPost[@"a"] = @(weakSelf.productModel.aPrice);
                        stockPost[@"b"] = @(weakSelf.productModel.bPrice);
                        stockPost[@"c"] = @(weakSelf.productModel.cPrice);
                        stockPost[@"d"] = @(weakSelf.productModel.dPrice);
                        stockPost[@"purchasePrice"] = @(weakSelf.productModel.purchaseprice);
                        stockPost[@"selected"] = @(weakSelf.productModel.selected);
                        stockPost[@"isSetting"] = @(weakSelf.productModel.isSetting);
                        stockPost[@"singleNum"] = @(weakSelf.productModel.singleNum);
                        if (weakSelf.productModel.isSetting) {
                            if (model.stockNum<weakSelf.productModel.singleNum) {
                                stockPost[@"isWarning"] = @(true);
                            }
                        }
                        if (model.image) {
                            NSData *imageData = UIImageJPEGRepresentation(model.image,0.8);
                            AVFile *imageFile = [AVFile fileWithName:@"image.png" data:imageData];
                            [stockPost setObject:imageFile forKey:@"header"];
                            if (!isExit) {
                                [post setObject:imageFile forKey:@"header"];
                                isExit = true;
                            }
                        }
                        
                        //材质
                        if (weakSelf.productModel.materialModel != nil) {
                            AVObject *mPost = [[AVQuery queryWithClassName:@"Material"] getObjectWithId:weakSelf.productModel.materialModel.materialId];
                            [post setObject:mPost forKey:@"material"];
                            [stockPost setObject:mPost forKey:@"material"];
                        }
                        
                        //分类
                        if (weakSelf.productModel.sortModel != nil) {
                            AVObject *cPost = [[AVQuery queryWithClassName:@"Sort"] getObjectWithId:weakSelf.productModel.sortModel.sortId];
                            [post setObject:cPost forKey:@"sort"];
                            [stockPost setObject:cPost forKey:@"sort"];
                        }
                        //颜色
                        AVObject *cPost = [[AVQuery queryWithClassName:@"Color"] getObjectWithId:model.colorModel.colorId];
                        [stockPost setObject:cPost forKey:@"color"];
                        stockPost[@"colorName"] = model.colorModel.colorName;
                        
                        [tempArray addObject:stockPost];
                    }
                    
                    [AVObject saveAll:tempArray];
                    
                    [post addUniqueObjectsFromArray:tempArray forKey:@"products"];
                }else {
                    //材质
                    if (weakSelf.productModel.materialModel != nil) {
                        AVObject *mPost = [[AVQuery queryWithClassName:@"Material"] getObjectWithId:weakSelf.productModel.materialModel.materialId];
                        [post setObject:mPost forKey:@"material"];
                    }
                    
                    //分类
                    if (weakSelf.productModel.sortModel != nil) {
                        AVObject *cPost = [[AVQuery queryWithClassName:@"Sort"] getObjectWithId:weakSelf.productModel.sortModel.sortId];
                        [post setObject:cPost forKey:@"sort"];
                        
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [AVObject saveAllInBackground:@[post] block:^(BOOL succeeded, NSError *error) {
                        
                        if (!error) {
                            //发推送
                            AVQuery *queryquery = [AVInstallation query];
                            [queryquery whereKey:@"user" equalTo:[AVUser currentUser]];
                            [queryquery whereKey:@"deviceProfile" equalTo:@"CAPP"];
                            AVPush *push = [[AVPush alloc] init];
                            [push setQuery:queryquery];
                            NSDictionary *data = @{
                                                   @"alert": [NSString stringWithFormat:SetTitle(@"product_push"),[AVUser currentUser].username],
                                                   @"type": @"1",
                                                   @"badge":@"1"
                                                   };
                            [push setData:data];
                            [AVPush setProductionMode:YES];
                            [push sendPushInBackground];
                            
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                //材质
                                if (weakSelf.productModel.materialModel != nil) {
                                    AVObject *mPost = [[AVQuery queryWithClassName:@"Material"] getObjectWithId:weakSelf.productModel.materialModel.materialId];
                                    [mPost incrementKey:@"productCount"];
                                    [mPost save];
                                }
                                
                                //分类
                                if (weakSelf.productModel.sortModel != nil) {
                                    AVObject *cPost = [[AVQuery queryWithClassName:@"Sort"] getObjectWithId:weakSelf.productModel.sortModel.sortId];
                                    [cPost incrementKey:@"productCount"];
                                    [cPost save];
                                }
                                
                                //颜色
                                if (weakSelf.productModel.productStockArray.count>0) {
                                    for (int i=0; i<weakSelf.productModel.productStockArray.count; i++) {
                                        ProductStockModel *model = (ProductStockModel *)weakSelf.productModel.productStockArray[i];
                                        AVObject *cPost = [[AVQuery queryWithClassName:@"Color"] getObjectWithId:model.colorModel.colorId];
                                        [cPost incrementKey:@"productCount"];
                                        [cPost save];
                                    }
                                }
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    if (weakSelf.addHandler) {
                                        weakSelf.addHandler();
                                    }
                                    
                                    [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                                    [weakSelf.navigationController popViewControllerAnimated:YES];
                                });
                            });
                            
                        }else {
                            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                        }
                        
                    }];
                });
            });
        }];
        [self addCancelActionTarget:alert title:SetTitle(@"alert_cancel")];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - segmentView代理

- (void)segmentViewDidSelected:(NSUInteger)index {
    if (index==self.currentPage) {
        //do nothing
    }else {
        self.currentPage = index;
        __weak __typeof(self)weakSelf = self;
        if (index==0) {
            [UIView animateWithDuration:0.25f animations:^{
                weakSelf.descriptionTable.frame = (CGRect){0,self.navBarView.bottom+60,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height-self.navBarView.bottom-60};
                weakSelf.stockTable.frame = (CGRect){[UIScreen mainScreen].bounds.size.width,self.navBarView.bottom+60,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height-self.navBarView.bottom-60};
            }];
        }else {
            [UIView animateWithDuration:0.25f animations:^{
                weakSelf.descriptionTable.frame = (CGRect){0-[UIScreen mainScreen].bounds.size.width,self.navBarView.bottom+60,[UIScreen mainScreen].bounds.size.width,self.view.height-self.navBarView.bottom-60};
                weakSelf.stockTable.frame = (CGRect){0,self.navBarView.bottom+60,[UIScreen mainScreen].bounds.size.width,self.view.height-self.navBarView.bottom-60};
            }];
        }
    }
}

#pragma mark - keyboard

- (void)handleWillShowKeyboardNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         CGRect frame = self.descriptionTable.frame;
                         frame.size.height += self.keyboardHeight;
                         frame.size.height -= keyboardRect.size.height;
                         self.descriptionTable.frame = frame;
                         self.keyboardHeight = keyboardRect.size.height;
                     }];
}

- (void)handleWillHideKeyboardNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         CGRect frame = self.descriptionTable.frame;
                         frame.size.height += self.keyboardHeight;
                         self.descriptionTable.frame = frame;
                         self.keyboardHeight = 0;
                     }];
}

@end
