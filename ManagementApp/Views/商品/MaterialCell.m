//
//  MaterialCell.m
//  ManagementApp
//
//  Created by 邱成西 on 15/10/14.
//  Copyright © 2015年 suda_505. All rights reserved.
//

#import "MaterialCell.h"

@interface MaterialCell ()

///标题
@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIImageView *lineView;

@property (nonatomic, strong) UIImageView *deleteGreyImageView;
@property (nonatomic, strong) UIImageView *deleteRedImageView;

@property (nonatomic, strong) UIImageView *accessView;

@end

@implementation MaterialCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
        
        self.titleLab = [[UILabel alloc]initWithFrame:CGRectZero];
        self.titleLab.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.titleLab];
        
        self.lineView = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.lineView.image = [Utility getImgWithImageName:@"line@2x"];
        [self.contentView addSubview:self.lineView];
        
        self.accessView = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.accessView.contentMode = UIViewContentModeScaleAspectFit;
        [self.accessView setHidden:YES];
        [self.accessView setImage:[Utility getImgWithImageName:@"uncheck@2x"]];
        [self.contentView addSubview:self.accessView];
        
        self.textLabel.font = [UIFont systemFontOfSize:15];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor lightGrayColor];
    }
    return self;
}
#pragma mark - getter/setter

-(UIImageView*)deleteGreyImageView {
    if (!_deleteGreyImageView) {
        _deleteGreyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.contentView.frame), (self.height-40)/2, 40, 40)];
        [_deleteGreyImageView setImage:[Utility getImgWithImageName:@"DeleteGrey@2x"]];
        [_deleteGreyImageView setContentMode:UIViewContentModeCenter];
        [self.backView addSubview:_deleteGreyImageView];
    }
    return _deleteGreyImageView;
}

-(UIImageView*)deleteRedImageView {
    if (!_deleteRedImageView) {
        _deleteRedImageView = [[UIImageView alloc] initWithFrame:self.deleteGreyImageView.bounds];
        [_deleteRedImageView setImage:[Utility getImgWithImageName:@"DeleteRed@2x"]];
        [_deleteRedImageView setContentMode:UIViewContentModeCenter];
        [self.deleteGreyImageView addSubview:_deleteRedImageView];
    }
    return _deleteRedImageView;
}

-(void)setSelectedType:(NSInteger)selectedType {
    _selectedType = selectedType;
    
    self.titleLab.textColor = [UIColor blackColor];
    
    if (selectedType==0) {
        [self.accessView setHidden:YES];
    }else {
        [self.accessView setHidden:NO];
        if (selectedType==1) {
            [self.accessView setImage:[Utility getImgWithImageName:@"uncheck2x"]];
        }else {
            [self.accessView setImage:[Utility getImgWithImageName:@"check@2x"]];
            self.titleLab.textColor = COLOR(12, 96, 254, 1);
        }
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.frame = (CGRect){0,0,self.width,self.height};
    
    [self.textLabel sizeToFit];
    self.imageView.frame = (CGRect){20,(self.height-20)/2,20,20};
    self.textLabel.frame = (CGRect){self.imageView.right+10,(self.height-self.textLabel.height)/2,self.textLabel.width,self.textLabel.height};
    
    self.titleLab.frame = (CGRect){10,(self.contentView.height-20)/2,self.contentView.width-40,20};
    
    self.accessView.frame = (CGRect){self.titleLab.right,(self.contentView.height-10)/2,14,10};
    
    self.lineView.frame = (CGRect){self.titleLab.left,self.height-1,self.contentView.width-20,2};
}

-(void)setMaterialModel:(MaterialModel *)materialModel {
    _materialModel = materialModel;
    
    self.titleLab.text = [NSString stringWithFormat:@"%@  (%ld)",materialModel.materialName,materialModel.productCount];
}

-(void)setIndexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
}


-(void)prepareForReuse {
    [super prepareForReuse];
    self.textLabel.text = @"";
    self.titleLab.text = @"";
    self.imageView.image = nil;
    [self cleanupBackView];
}
-(void)cleanupBackView {
    [super cleanupBackView];
    [_deleteGreyImageView removeFromSuperview];
    _deleteGreyImageView = nil;
    [_deleteRedImageView removeFromSuperview];
    _deleteRedImageView = nil;
}

#pragma mark -

-(void)animateContentViewForPoint:(CGPoint)point velocity:(CGPoint)velocity {
    [super animateContentViewForPoint:point velocity:velocity];
    if (point.x < 0) {
        [self.deleteGreyImageView setFrame:CGRectMake(MAX(CGRectGetMaxX(self.frame) - CGRectGetWidth(self.deleteGreyImageView.frame), CGRectGetMaxX(self.contentView.frame)), CGRectGetMinY(self.deleteGreyImageView.frame), CGRectGetWidth(self.deleteGreyImageView.frame), CGRectGetHeight(self.deleteGreyImageView.frame))];
        if (-point.x >= CGRectGetHeight(self.contentView.frame)) {
            [self.deleteRedImageView setAlpha:1];
        } else {
            [self.deleteRedImageView setAlpha:0];
        }
    }
}

-(void)resetCellFromPoint:(CGPoint)point velocity:(CGPoint)velocity {
    [super resetCellFromPoint:point velocity:velocity];
    if (point.x < 0) {
        if (-point.x <= CGRectGetHeight(self.contentView.frame)) {
            [UIView animateWithDuration:self.animationDuration
                             animations:^{
                                 [self.deleteGreyImageView setFrame:CGRectMake(CGRectGetMaxX(self.contentView.frame), CGRectGetMinY(self.deleteGreyImageView.frame), CGRectGetWidth(self.deleteGreyImageView.frame), CGRectGetHeight(self.deleteGreyImageView.frame))];
                             }];
        } else {
            [UIView animateWithDuration:self.animationDuration
                             animations:^{
                                 [self.deleteGreyImageView.layer setTransform:CATransform3DMakeScale(2, 2, 2)];
                                 [self.deleteGreyImageView setAlpha:0];
                                 [self.deleteRedImageView.layer setTransform:CATransform3DMakeScale(2, 2, 2)];
                                 [self.deleteRedImageView setAlpha:0];
                             }];
        }
    }
}


@end
