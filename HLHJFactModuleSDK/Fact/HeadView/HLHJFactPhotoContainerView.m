//
//  HLHJFactPhotoContainerView.m
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/14.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "HLHJFactPhotoContainerView.h"

#import "UIView+SDAutoLayout.h"
#import "UIImageView+WebCache.h"
#import "SDPhotoBrowser.h"



//@interface HLHJFactPhotoContainerView () <SDPhotoBrowserDelegate>
//
//@property (nonatomic, strong) NSArray *imageViewsArray;
//
//@end
//
//@implementation HLHJFactPhotoContainerView
//
//- (instancetype)initWithFrame:(CGRect)frame
//{
//    if (self = [super initWithFrame:frame]) {
//        [self setup];
//    }
//    return self;
//}
//
//- (void)setup
//{
//    NSMutableArray *temp = [NSMutableArray new];
//
//    for (int i = 0; i < 9; i++) {
//        UIImageView *imageView = [UIImageView new];
//        [self addSubview:imageView];
//        imageView.userInteractionEnabled = YES;
//        imageView.tag = i;
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
//        [imageView addGestureRecognizer:tap];
//        [temp addObject:imageView];
//    }
//
//    self.imageViewsArray = [temp copy];
//}
//
//
//- (void)setPicPathStringsArray:(NSArray *)picPathStringsArray
//{
//    _picPathStringsArray = picPathStringsArray;
//
//    for (long i = _picPathStringsArray.count; i < self.imageViewsArray.count; i++) {
//        UIImageView *imageView = [self.imageViewsArray objectAtIndex:i];
//        imageView.hidden = YES;
//    }
//
//    if (_picPathStringsArray.count == 0) {
//        self.height = 0;
//        self.fixedHeight = @(0);
//        return;
//    }
//
//    CGFloat itemW = [self itemWidthForPicPathArray:_picPathStringsArray];
//    CGFloat itemH = 0;
//    if (_picPathStringsArray.count == 1) {
//        NSData *data = [NSData dataWithContentsOfURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL,_picPathStringsArray.firstObject]]];
//        UIImage *image = [UIImage imageWithData:data]; // 取得图片
////        UIImage *image = [UIImage imageNamed:@"imgBundle.bundle/ic_bl_touxiang"];
//        if (image.size.width) {
//            itemH = image.size.height / image.size.width * itemW;
//        }
//    } else {
//        itemH = itemW;
//    }
//    long perRowItemCount = [self perRowItemCountForPicPathArray:_picPathStringsArray];
//    CGFloat margin = 5;
//
//    [_picPathStringsArray enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        long columnIndex = idx % perRowItemCount;
//        long rowIndex = idx / perRowItemCount;
//        UIImageView *imageView = [_imageViewsArray objectAtIndex:idx];
//        imageView.hidden = NO;
//        [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL,_picPathStringsArray[idx]]] placeholderImage:[UIImage imageNamed:@""]];
//        imageView.frame = CGRectMake(columnIndex * (itemW + margin), rowIndex * (itemH + margin), itemW, itemH);
//    }];
//
//    CGFloat w = perRowItemCount * itemW + (perRowItemCount - 1) * margin;
//    int columnCount = ceilf(_picPathStringsArray.count * 1.0 / perRowItemCount);
//    CGFloat h = columnCount * itemH + (columnCount - 1) * margin;
//    self.width = w;
//    self.height = h;
//
//    self.fixedHeight = @(h);
//    self.fixedWidth = @(w);
//}
//
//#pragma mark - private actions
//
//- (void)tapImageView:(UITapGestureRecognizer *)tap
//{
//    UIView *imageView = tap.view;
//    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
//    browser.currentImageIndex = imageView.tag;
//    browser.sourceImagesContainerView = self;
//    browser.imageCount = self.picPathStringsArray.count;
//    browser.delegate = self;
//    [browser show];
//}
//
//- (CGFloat)itemWidthForPicPathArray:(NSArray *)array
//{
//    if (array.count == 1) {
//        return 120;
//    } else {
//        CGFloat w = [UIScreen mainScreen].bounds.size.width > 320 ? 80 : 70;
//        return w;
//    }
//}
//
//- (NSInteger)perRowItemCountForPicPathArray:(NSArray *)array
//{
//    if (array.count < 3) {
//        return array.count;
//    } else if (array.count <= 4) {
//        return 2;
//    } else {
//        return 3;
//    }
//}
//
//
//#pragma mark - SDPhotoBrowserDelegate
//
//- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
//{
//    NSString *imageName = self.picPathStringsArray[index];
//    NSURL *url = [[NSBundle mainBundle] URLForResource:imageName withExtension:nil];
//    return url;
//}
//
//- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
//{
//    UIImageView *imageView = self.subviews[index];
//    return imageView.image;
//}
//
//
//@end

@interface HLHJFactPhotoContainerView () <SDPhotoBrowserDelegate>

@property (nonatomic, strong) NSArray *imageViewsArray;

@property (nonatomic, strong) UIButton  *playBtn;

@property (nonatomic, assign) NSInteger  type;
@end


@implementation HLHJFactPhotoContainerView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}
- (void)setup
{
    NSMutableArray *temp = [NSMutableArray new];

    for (int i = 0; i < 9; i++) {
        UIImageView *imageView = [UIImageView new];
        imageView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self addSubview:imageView];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode  = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.tag = i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
        [imageView addGestureRecognizer:tap];
        [temp addObject:imageView];
    }
    self.imageViewsArray = [temp copy];
}

- (void)picPathStringsArray:(NSArray *)arr type:(NSInteger)type andVidoImage:(NSString *)img {
    _type = type;
    if (type == 2) {
        if (arr.count == 0) {
            self.height = 0;
            self.fixedHeight = @(0);
            return;
        }
        for (UIImageView *imgView in self.imageViewsArray) {
            imgView.hidden = YES;
        }
        UIImageView *imageView = [self.imageViewsArray objectAtIndex:0];
        imageView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        imageView.hidden = NO;
        imageView.tag = 100000;
        imageView.contentMode  = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL,img]] placeholderImage:[UIImage imageNamed:@""]];
        imageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-70, 200);
        self.fixedHeight = @(200);
        self.fixedWidth = @([UIScreen mainScreen].bounds.size.width-70);

        self.playBtn.hidden = NO;
        [self.playBtn addTarget:self action:@selector(clikAction:) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview:self.playBtn];
        self.playBtn.sd_layout
        .centerXEqualToView(imageView)
        .centerYEqualToView(imageView)
        .widthIs(40)
        .heightIs(40);

    }else {
        for (UIImageView *imgView in self.imageViewsArray) {
            imgView.hidden = NO;
        }
         UIImageView *imageView = [self.imageViewsArray objectAtIndex:0];
         imageView.tag = 0;
        self.playBtn.hidden = YES;
        [self picPathStringsArray:arr];
    }

}

- (void)picPathStringsArray:(NSArray *)picPathStringsArray
{
    _picPathStringsArray = picPathStringsArray;

    for (long i = _picPathStringsArray.count; i < self.imageViewsArray.count; i++) {
        UIImageView *imageView = [self.imageViewsArray objectAtIndex:i];
        imageView.hidden = YES;
    }

    if (_picPathStringsArray.count == 0) {
        self.height = 0;
        self.fixedHeight = @(0);
        return;
    }

        CGFloat itemW = [self itemWidthForPicPathArray:_picPathStringsArray];
         __block  CGFloat  itemH = 0;
        if (_picPathStringsArray.count == 1) {
            itemH = 150;
        } else {
            itemH = itemW;
        }
        long perRowItemCount = [self perRowItemCountForPicPathArray:_picPathStringsArray];
        CGFloat margin = 5;

        [_picPathStringsArray enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            long columnIndex = idx % perRowItemCount;
            long rowIndex = idx / perRowItemCount;
            UIImageView *imageView = [_imageViewsArray objectAtIndex:idx];
            imageView.userInteractionEnabled = YES;
            imageView.hidden = NO;
            [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL,_picPathStringsArray[idx]]] placeholderImage:[UIImage imageNamed:@""]];
            imageView.frame = CGRectMake(columnIndex * (itemW + margin), rowIndex * (itemH + margin), itemW, itemH);
        }];

        CGFloat w = perRowItemCount * itemW + (perRowItemCount - 1) * margin;
        int columnCount = ceilf(_picPathStringsArray.count * 1.0 / perRowItemCount);
        CGFloat h = columnCount * itemH + (columnCount - 1) * margin;
        self.width = w;
        self.height = h;
        self.fixedHeight = @(h);
        self.fixedWidth = @(w);
}

#pragma mark - private actions

- (void)tapImageView:(UITapGestureRecognizer *)tap
{

    if (_type == 2) {
        return ;
    }
    UIView *imageView = tap.view;
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.currentImageIndex = imageView.tag;
    browser.sourceImagesContainerView = self;
    browser.imageCount = self.picPathStringsArray.count;
    browser.delegate = self;
    [browser show];
}

- (CGFloat)itemWidthForPicPathArray:(NSArray *)array
{
    if (array.count == 1) {
        return 120;
    } else {
        CGFloat w = [UIScreen mainScreen].bounds.size.width > 320 ? 100 : 80;
        return w;
    }
}

- (NSInteger)perRowItemCountForPicPathArray:(NSArray *)array
{
    if (array.count < 3) {
        return array.count;
    } else if (array.count <= 4) {
        return 2;
    } else {
        return 3;
    }
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"imgBundle.bundle/ic_bl_bofang"] forState:UIControlStateNormal];
    }
    return _playBtn;
}

#pragma mark - SDPhotoBrowserDelegate
- (void)clikAction:(UIButton *)sender {
    if (_clickPlayActionBlock) {
        UIImageView *imageView = [self.imageViewsArray objectAtIndex:0];
        CGRect rect = imageView.frame;
        _clickPlayActionBlock(sender.selected = !sender.selected,rect);
    }
}
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    if (_type == 2) {
        return nil;
    }
    NSString *imageName = self.picPathStringsArray[index];
    NSURL *url = [[NSBundle mainBundle] URLForResource:imageName withExtension:nil];
    return url;
}

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    UIImageView *imageView = self.subviews[index];
    return imageView.image;
}

@end
