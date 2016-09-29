//
//  XHDisplayMediaViewController.m
//  MessageDisplayExample
//
//  Created by HUAJIE-1 on 14-5-6.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHDisplayMediaViewController.h"
#import <MediaPlayer/MediaPlayer.h>

#import "UIView+XHRemoteImage.h"
#import "XHConfigurationHelper.h"

@interface XHDisplayMediaViewController ()

@property (nonatomic, strong) MPMoviePlayerController *moviePlayerController;

@property (nonatomic, weak) UIImageView *photoImageView;

@end

@implementation XHDisplayMediaViewController

- (MPMoviePlayerController *)moviePlayerController {
    if (!_moviePlayerController) {
        _moviePlayerController = [[MPMoviePlayerController alloc] init];
        _moviePlayerController.repeatMode = MPMovieRepeatModeOne;
        _moviePlayerController.scalingMode = MPMovieScalingModeAspectFill;
        _moviePlayerController.view.frame = (CGRect){0,self.navBarView.bottom,self.view.width,self.view.height-self.navBarView.height};
        [self.view addSubview:_moviePlayerController.view];
    }
    return _moviePlayerController;
}

- (UIImageView *)photoImageView {
    if (!_photoImageView) {
        UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:(CGRect){0,self.navBarView.bottom,self.view.width,self.view.height-self.navBarView.height}];
        photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        photoImageView.clipsToBounds = YES;
        [self.view addSubview:photoImageView];
        _photoImageView = photoImageView;
    }
    return _photoImageView;
}

- (void)setMessage:(id<XHMessageModel>)message {
    _message = message;
    if ([message messageMediaType] == XHBubbleMessageMediaTypeVideo) {
        self.title = NSLocalizedStringFromTable(@"Video", @"MessageDisplayKitString", @"详细视频");
        self.moviePlayerController.contentURL = [NSURL fileURLWithPath:[message videoPath]];
        [self.moviePlayerController play];
    } else if ([message messageMediaType] ==XHBubbleMessageMediaTypePhoto) {
        self.photoImageView.image = message.photo;
        if (message.thumbnailUrl) {
            NSString *placeholderImageName = [[XHConfigurationHelper appearance].messageInputViewStyle objectForKey:kXHMessageTablePlaceholderImageNameKey];
            if (!placeholderImageName) {
                placeholderImageName = @"placeholderImage";
            }
            
            [self.photoImageView setImageWithURL:[NSURL URLWithString:[message thumbnailUrl]] placeholer:[UIImage imageNamed:placeholderImageName]];
        }
    }
}

#pragma mark - Life cycle

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.message messageMediaType] == XHBubbleMessageMediaTypeVideo) {
        [self.moviePlayerController stop];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarView];
}

#pragma mark - UI

-(void)setNavBarView {
    
    //左侧名称显示的分类名称
    [self.navBarView setLeftWithImage:@"back_nav" title:nil];
    
    [self.navBarView setTitle:SetTitle(@"Photo") image:nil];
    [self.view addSubview:self.navBarView];
}

#pragma mark - 导航栏代理

-(void)leftBtnClickByNavBarView:(NavBarView *)navView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_moviePlayerController stop];
    _moviePlayerController = nil;
    
    _photoImageView = nil;
}

@end
