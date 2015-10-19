//
//  JKImagePickerController.h
//  JKImagePicker
//
//  Created by Jecky on 15/1/9.
//  Copyright (c) 2015年 Jecky. All rights reserved.
//

#import "BaseVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "JKAssets.h"

typedef NS_ENUM(NSUInteger, JKImagePickerControllerFilterType) {
    JKImagePickerControllerFilterTypeNone,
    JKImagePickerControllerFilterTypePhotos,
    JKImagePickerControllerFilterTypeVideos
};

UIKIT_EXTERN ALAssetsFilter * ALAssetsFilterFromJKImagePickerControllerFilterType(JKImagePickerControllerFilterType type);

@class JKImagePickerController;


@interface JKImagePickerController : BaseVC

@property (nonatomic, assign) JKImagePickerControllerFilterType filterType;
@property (nonatomic, assign) BOOL allowsMultipleSelection;
@property (nonatomic, assign) NSUInteger minimumNumberOfSelection;
@property (nonatomic, assign) NSUInteger maximumNumberOfSelection;
@property (nonatomic, strong) NSMutableArray *selectedAssetArray;

@property (copy, nonatomic) void (^selectAssets)(JKImagePickerController *imagePicker,NSArray *assets);

@property (copy, nonatomic) void (^cancelAssets)(JKImagePickerController *imagePicker);
@end
