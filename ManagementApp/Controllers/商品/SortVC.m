//
//  SortVC.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/12.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "SortVC.h"
#import "SortCell.h"

@interface SortVC ()

@end

@implementation SortVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DLog(@"currebtPage = %d",(int)self.currentPage);
    
    [self.sortTable reloadData];
    ///底部切换栏布局
    int num = (int)self.currentPage;
    if (num == 0) {
        self.leftIconImgV.image = [Utility getImgWithImageName:@"hot_s_bt@2x"];
        self.leftNameLab.text = SetTitle(@"best_sellers") ;
        self.rightIconImgV.image = [Utility getImgWithImageName:@"hide_s_bt@2x"];
        self.rightNameLab.text = SetTitle(@"off_the_shelf");
        
        SortModel *model1 = [[SortModel alloc] init];
        model1.sortId = 1;
        model1.sortName = SetTitle(@"navicon_all");
        model1.sortProductCount = 460;
        
        SortModel *model2 = [[SortModel alloc] init];
        model2.sortId = 2;
        model2.sortName = SetTitle(@"not_classified");
        model2.sortProductCount = 0;
        
        SortModel *model3 = [[SortModel alloc] init];
        model3.sortId = 3;
        model3.sortName = @"BORSE IN PELLE";
        model3.sortProductCount = 67;
        
        SortModel *model4 = [[SortModel alloc] init];
        model4.sortId = 4;
        model4.sortName = @"CLASSIC BAGS";
        model4.sortProductCount = 0;
        
        SortModel *model5 = [[SortModel alloc] init];
        model5.sortId = 5;
        model5.sortName = @"BORSE ESTIVO/SUMMER";
        model5.sortProductCount = 140;
        
        SortModel *model6 = [[SortModel alloc] init];
        model6.sortId = 6;
        model6.sortName = @"WINTER 2015 NEW!!!!!!";
        model6.sortProductCount = 121;
        
        SortModel *model7 = [[SortModel alloc] init];
        model7.sortId = 7;
        model7.sortName = @"BORSE IN PELLE VINTAGE";
        model7.sortProductCount = 36;
        
        SortModel *model8 = [[SortModel alloc] init];
        model8.sortId = 8;
        model8.sortName = @"FOULAR";
        model8.sortProductCount = 76;
        
        SortModel *model9 = [[SortModel alloc] init];
        model9.sortId = 9;
        model9.sortName = @"BORSE UOMO";
        model9.sortProductCount = 20;
        
        self.dataArray = [NSArray arrayWithObjects:model1,model2,model3,model4,model5,model6,model7,model8,model9, nil];
        
        
    }else{
        self.leftIconImgV.image = [Utility getImgWithImageName:@"vendor_drawer_icon@2x"];
        self.leftNameLab.text = SetTitle(@"private_client");
        self.rightIconImgV.image = [Utility getImgWithImageName:@"factory_drawer_icon@2x"];
        self.rightNameLab.text = SetTitle(@"supplier");
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.currentPage == 0) {
        return self.dataArray.count + 1;
    }else{
        return self.dataArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"sort_cell";
    
    if (self.currentPage == 0) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                
            }
            
            UIView *sv = [cell.contentView viewWithTag:100099];
            [sv.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [sv removeFromSuperview];
            UIView *customView = [[UIView alloc] initWithFrame:cell.contentView.frame];
            customView.tag = 100099;
            customView.backgroundColor = [UIColor clearColor];
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 25, 25)];
            img.image = [Utility getImgWithImageName:@"stock_warnning_icon@2x"];
            [customView addSubview:img];
            
            UILabel *stockWarnLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 12, 100, 21)];
            stockWarnLabel.text = SetTitle(@"stock_warning");
            stockWarnLabel.adjustsFontSizeToFitWidth = YES;
            stockWarnLabel.textColor = [UIColor whiteColor];
            [customView addSubview:stockWarnLabel];
            
            UILabel *sortNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(221, 12, 49, 21)];
            sortNumLabel.textColor = [UIColor whiteColor];
            sortNumLabel.text = @"137";
            sortNumLabel.textAlignment = NSTextAlignmentRight;
            [customView addSubview:sortNumLabel];
            
            cell.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:customView];
            return cell;
        }else{
            SortCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sort_cell2"];
            if (cell == nil) {
                NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SortCell" owner:self options:nil];
                cell = (SortCell *)[array objectAtIndex:0];
            }
            
            SortModel *sortModel = (SortModel *)self.dataArray[indexPath.row-1];
            [cell setSortModel:sortModel];
            
            return cell;

        }
    }else{
        return nil;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    ColorCell *cell = (ColorCell *)[tableView cellForRowAtIndexPath:indexPath];
//    if (self.isSelectedColor) {
//        ColorModel *colorModel = (ColorModel *)self.dataArray[indexPath.section][@"data"][indexPath.row];
//        
//        NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"colorId == %d", colorModel.colorId];
//        NSMutableArray *filteredArray = [NSMutableArray arrayWithArray:[self.hasSelectedColor filteredArrayUsingPredicate:predicateString]];
//        if (filteredArray.count>0) {
//            ///已经选择,取消选择
//            [cell setSelectedType:1];
//            [self.hasSelectedColor removeObjectsInArray:filteredArray];
//        }else {
//            ///选择
//            [cell setSelectedType:2];
//            [self.hasSelectedColor addObject:colorModel];
//        }
//    }else {
//        //do noting
//    }
}

-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [self.sortTable resignFirstResponder];
}

///segment切换
-(IBAction)leftBtnPressed:(id)sender
{
    
}
-(IBAction)rightBtnPressed:(id)sender{
    
}
#pragma mark - ICSDrawerControllerPresenting

- (void)drawerControllerWillOpen:(ICSDrawerController *)drawerController {
    self.view.userInteractionEnabled = NO;
}

- (void)drawerControllerDidOpen:(ICSDrawerController *)drawerController {
    self.view.userInteractionEnabled = YES;
}

- (void)drawerControllerWillClose:(ICSDrawerController *)drawerController {
    self.view.userInteractionEnabled = NO;
}

- (void)drawerControllerDidClose:(ICSDrawerController *)drawerController {
    self.view.userInteractionEnabled = YES;
}


@end
