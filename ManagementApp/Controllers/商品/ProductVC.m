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
    }else {
        self.isNew = YES;
        self.productModel = [[ProductModel alloc]init];
        self.productModel.isDisplay = YES;
        self.productModel.isHot = YES;
    }
    
    self.currentPage = 0;
    
    [self setNavBarView];
    [self setSegmentControl];
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
    
    if (!self.view.window){
        SafeRelease(_productModel);
        SafeRelease(_segmentView);
        SafeRelease(_descriptionTable);
        SafeRelease(_descriptionManager);
        SafeRelease(_stockTable);
        SafeRelease(_stockManager);
        self.view=nil;
    }
}

#pragma mark - getter/setter



#pragma mark - UI

-(void)setNavBarView {
    
    //左侧名称显示的分类名称
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    [self.navBarView setRightWithArray:@[@"ok_bt"] type:0];
    [self.navBarView setTitle:self.isNew?SetTitle(@"product"):self.productModel.productCode image:nil];
    [self.view addSubview:self.navBarView];
}

-(void)setSegmentControl {
    self.segmentView = [[RFSegmentView alloc] initWithFrame:(CGRect){10,self.navBarView.bottom+10,self.view.width-20,40} items:@[SetTitle(@"Description"),SetTitle(@"stock")]];
    self.segmentView.tintColor       = COLOR(80, 80, 80, 1);
    self.segmentView.delegate        = self;
    self.segmentView.selectedIndex   = 0;
    [self.view addSubview:self.segmentView];
    
    UIImageView *img = [[UIImageView alloc]initWithFrame:(CGRect){0,self.segmentView.bottom+10,self.view.width,0.5}];
    img.backgroundColor = COLOR(80, 80, 80, 1);
    [self.view addSubview:img];
    
    [self setDescriptionTableView];
    [self setStockTableView];
    
    [self.view bringSubviewToFront:img];
    img = nil;
}

-(void)setDescriptionTableView {
    self.descriptionTable = [[UITableView alloc]initWithFrame:(CGRect){0,self.navBarView.bottom+60,self.view.width,self.view.height-self.navBarView.bottom-60} style:UITableViewStylePlain];
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
    codeItem.validators = @[@"presence"];
    [section addItem:codeItem];
    
    //价格选择
    NSString *value = @"";
    UIImage *infoImage = nil;
    if (self.productModel.productPriceModel) {
        if (self.productModel.productPriceModel.selected==0) {
            value = [NSString stringWithFormat:@"%.2f",self.productModel.productPriceModel.aPrice];
            infoImage = [Utility getImgWithImageName:@"charc_1_28@2x"];
        }else if (self.productModel.productPriceModel.selected==1) {
            value = [NSString stringWithFormat:@"%.2f",self.productModel.productPriceModel.bPrice];
            infoImage = [Utility getImgWithImageName:@"charc_2_28@2x"];
        }
        else if (self.productModel.productPriceModel.selected==2) {
            value = [NSString stringWithFormat:@"%.2f",self.productModel.productPriceModel.cPrice];
            infoImage = [Utility getImgWithImageName:@"charc_3_28@2x"];
        }
        else if (self.productModel.productPriceModel.selected==3) {
            value = [NSString stringWithFormat:@"%.2f",self.productModel.productPriceModel.dPrice];
            infoImage = [Utility getImgWithImageName:@"charc_4_28@2x"];
        }
    }
    RERadioItem *radioItem = [RERadioItem itemWithTitle:SetTitle(@"sale_price") value:value selectionHandler:^(RERadioItem *item) {
        [item deselectRowAnimated:YES];
        
        ProductPriceVC *priceVC = LOADVC(@"ProductPriceVC");
        priceVC.completedBlock = ^(ProductPriceModel *productPriceModel, BOOL editting){
            if (editting) {
                weakSelf.productModel.productPriceModel = productPriceModel;
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
    RETextItem *purchaseItem = [RETextItem itemWithTitle:SetTitle(@"purchase_price") value:@"" placeholder:SetTitle(@"product_set")];
    purchaseItem.onChange = ^(RETextItem *item){
        //判读是否为数字
        if ([Utility predicateText:item.value regex:@"^[0-9]+(.[0-9]{1,2})?$"]){
            item.textFieldColor = [UIColor blackColor];
            weakSelf.productModel.purchaseprice = [item.value floatValue];
        }else {
            item.textFieldColor = COLOR(251, 0, 41, 1);
        }
    };
    purchaseItem.validators = @[@"price"];
    purchaseItem.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    purchaseItem.alignment = NSTextAlignmentRight;
    [section addItem:purchaseItem];
    
    //包装数
    REPickerItem *pickerItem = [REPickerItem itemWithTitle:SetTitle(@"product_package") value:@[@"1"] placeholder:nil options:@[@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30"]]];
    pickerItem.onChange = ^(REPickerItem *item){
        weakSelf.productModel.packageNum =  [item.value[0] integerValue];
    };
    pickerItem.inlinePicker = YES;
    [section addItem:pickerItem];
    
    //名称
    RETextItem *nameItem = [RETextItem itemWithTitle:SetTitle(@"product_name") value:self.productModel.productName?self.productModel.productName:@"" placeholder:SetTitle(@"product_set")];
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
            item.value = materialModel.materialName;
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
            item.value = sortModel.sortName;
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
        
        if (weakSelf.productModel.stockWarningModel) {
            stockVC.stockWarningModel = weakSelf.productModel.stockWarningModel;
        }
        stockVC.completedBlock = ^(StockWarningModel *stockWarningModel,BOOL editting){
            if (editting) {
                weakSelf.productModel.stockWarningModel = stockWarningModel;
            }
        };
        [weakSelf.navigationController pushViewController:stockVC animated:YES];
        SafeRelease(stockVC);
        
    }];
    [section addItem:stockItem];
}

-(void)setStockTableView {
    self.stockTable = [[UITableView alloc]initWithFrame:(CGRect){self.view.width,self.navBarView.bottom+60,self.view.width,self.view.height-self.navBarView.bottom-60} style:UITableViewStylePlain];
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
            
            REProductItem *picItem = [self returnProductItemWithTitle:model.colorModel.colorName value:[NSString stringWithFormat:@"%d",(int)model.stockNum] image:nil imageString:model.picHeader bySection:section index:i];

            [section addItem:picItem];
        }
    }
    
    RETableViewItem *buttonItem = [RETableViewItem itemWithTitle:SetTitle(@"addColor") accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        
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
        colorVC.hasSelectedColor = colorArray;
        colorVC.completedBlock = ^(NSArray *array){
            //比较原有的颜色数组和颜色页面传过来的
            for (int i=0; i<array.count; i++) {
                ColorModel *colorModel = (ColorModel *)array[i];
                
                NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"colorId == %d", colorModel.colorId];
                NSMutableArray *filteredArray = [NSMutableArray arrayWithArray:[colorArray filteredArrayUsingPredicate:predicateString]];
                if (filteredArray.count>0) {
                    ColorModel *colorModel2 = filteredArray[0];
                    [tempArray addObject:weakSelf.productModel.productStockArray[colorModel2.index]];
                }else {
                    ProductStockModel *model2 = [[ProductStockModel alloc]init];
                    model2.colorModel = colorModel;
                    [tempArray addObject:model2];
                }
            }
            
            if (tempArray.count>0) {
                [expandedItems removeAllObjects];
                
                for (int i=0; i<tempArray.count; i++) {
                    ProductStockModel *model = (ProductStockModel *)tempArray[i];
                    
                    REProductItem *picItem = [weakSelf returnProductItemWithTitle:model.colorModel?model.colorModel.colorName:@"" value:[NSString stringWithFormat:@"%d",(int)model.stockNum] image:nil imageString:model.picHeader bySection:section index:i];
                    [expandedItems addObject:picItem];
                }
                [expandedItems addObjectsFromArray:collapsedItems];
                [section replaceItemsWithItemsFromArray:expandedItems];
                [section reloadSectionWithAnimation:UITableViewRowAnimationAutomatic];
            }

        };
        [weakSelf.navigationController pushViewController:colorVC animated:YES];
        SafeRelease(colorVC);
    }];
    buttonItem.textAlignment = NSTextAlignmentCenter;
    [section addItem:buttonItem];
    
    [collapsedItems addObject:buttonItem];
}

-(REProductItem *)returnProductItemWithTitle:(NSString *)string value:(NSString *)value image:(UIImage *)image imageString:(NSString *)imageString bySection:(RETableViewSection *)section index:(NSInteger)index{
    __weak typeof(self) weakSelf = self;
    
     REProductItem *picItem = [REProductItem itemWithTitle:string value:value placeholder:@"0" image:image imageString:imageString];
    picItem.cellHeight = 88;
    picItem.index = index;
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
        
        [self.view.window.rootViewController presentViewController:imagePicker animated:YES completion:^{
            SafeRelease(imagePicker);
        }];
    };
    
    return picItem;
}

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnClickByNavBarView:(NavBarView *)navView tag:(NSUInteger)tag {
    
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
                weakSelf.descriptionTable.frame = (CGRect){0,self.navBarView.bottom+60,self.view.width,self.view.height-self.navBarView.bottom-60};
                weakSelf.stockTable.frame = (CGRect){self.view.width,self.navBarView.bottom+60,self.view.width,self.view.height-self.navBarView.bottom-60};
            }];
        }else {
            [UIView animateWithDuration:0.25f animations:^{
                weakSelf.descriptionTable.frame = (CGRect){0-self.view.width,self.navBarView.bottom+60,self.view.width,self.view.height-self.navBarView.bottom-60};
                weakSelf.stockTable.frame = (CGRect){0,self.navBarView.bottom+60,self.view.width,self.view.height-self.navBarView.bottom-60};
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
