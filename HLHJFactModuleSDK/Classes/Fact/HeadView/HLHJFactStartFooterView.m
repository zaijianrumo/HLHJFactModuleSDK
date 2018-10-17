//
//  HLHJFactStartFooterView.m
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/15.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "HLHJFactStartFooterView.h"
#import "UIView+SDAutoLayout.h"
#import "HLHJCustomCameraViewController.h"

#import "HLHJCollectionViewCell.h"
#import "HLHJCollectionViewFlowLayout.h"
#import "TZImageManager.h"
#import "TZVideoPlayerController.h"
#import "TZPhotoPreviewController.h"
#import "TZGifPhotoPreviewController.h"
#import "TZLocationManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "TZImagePickerController.h"

#define kViewWidth      [[UIScreen mainScreen] bounds].size.width
//app名字
#define kInfoDict [NSBundle mainBundle].localizedInfoDictionary ?: [NSBundle mainBundle].infoDictionary

#define kAPPName  [kInfoDict valueForKey:@"CFBundleDisplayName"] ?: [kInfoDict valueForKey:@"CFBundleName"]

@interface HLHJFactStartFooterView()<TZImagePickerControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSMutableArray *_selectedPhotos;
    NSMutableArray *_selectedVideos;
    NSMutableArray *_selectedAssets;
    id           _videoUrlDate;
    BOOL _isSelectOriginalPhoto;
    
    CGFloat _itemWH;
    CGFloat _margin;
}

@property (nonatomic, strong) UIImagePickerController *imagePickerVc;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (strong, nonatomic) HLHJCollectionViewFlowLayout *layout;
@end


@implementation HLHJFactStartFooterView

#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        if (iOS7Later) {
            _imagePickerVc.navigationBar.barTintColor = [UIColor redColor];
        }
        _imagePickerVc.navigationBar.tintColor = [UIColor whiteColor];
        UIBarButtonItem *tzBarItem, *BarItem;
        if (iOS9Later) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[TZImagePickerController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
        
    }
    return _imagePickerVc;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _selectedPhotos = [NSMutableArray array];
        _selectedAssets = [NSMutableArray array];
        _selectedVideos = [NSMutableArray array];

        self.backgroundColor = [UIColor whiteColor];
        
        [self setup];
    }
    return self;
}

- (void)setup {
    
    UIView *grayView  =[UIView new];
    grayView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self addSubview:grayView];
    grayView.sd_layout
    .leftEqualToView(self)
    .rightEqualToView(self)
    .topEqualToView(self)
    .heightIs(10);
    
    UIButton *ceame =[UIButton buttonWithType:UIButtonTypeCustom];
    [ceame setBackgroundImage:[UIImage imageNamed:@"imgBundle.bundle/ic_bl_zhaopian"] forState:UIControlStateNormal];
    [ceame addTarget:self action:@selector(chooseImage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:ceame];
    
     ceame.sd_layout
    .topSpaceToView(grayView, 10)
    .leftSpaceToView(self, 10)
    .widthIs(23)
    .heightIs(21);
    
    
    // 如不需要长按排序效果，将LxGridViewFlowLayout类改成UICollectionViewFlowLayout即可
    _layout = [[HLHJCollectionViewFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
    [self addSubview:_collectionView];
    _collectionView.sd_layout
    .leftEqualToView(self)
    .rightEqualToView(self)
    .topSpaceToView(ceame, 0)
    .heightIs(200);
    
    _margin = 10;
    _itemWH = (kViewWidth - _margin *5)/4;
    _layout.itemSize = CGSizeMake(_itemWH, _itemWH);
    _layout.minimumInteritemSpacing = _margin;
    _layout.minimumLineSpacing = _margin;
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.contentInset = UIEdgeInsetsMake(4, 4, 4, 4);
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [_collectionView registerClass:[HLHJCollectionViewCell class] forCellWithReuseIdentifier:@"HLHJCollectionViewCell"];
    
 
    UIButton *sureBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [sureBtn setTitle:@"提交" forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sureBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    sureBtn.backgroundColor =  [TMEngineConfig instance].themeColor;
    [sureBtn addTarget:self action:@selector(uploadAction:) forControlEvents:UIControlEventTouchUpInside];
    sureBtn.layer.cornerRadius = 20;
    sureBtn.layer.masksToBounds = YES;
    [self addSubview:sureBtn];
    
     sureBtn.sd_layout
    .centerXEqualToView(self)
    .topSpaceToView(_collectionView, 5)
    .widthIs(250)
    .heightIs(40);
    
}

#pragma mark UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _selectedPhotos.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HLHJCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HLHJCollectionViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
    cell.videoImageView.hidden = YES;
    cell.imageView.image = _selectedPhotos[indexPath.row];
    cell.asset = _selectedAssets[indexPath.row];
    cell.deleteBtn.hidden = NO;

    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClik:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // preview photos or video / 预览照片或者视频
//            TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithSelectedAssets:_selectedAssets selectedPhotos:_selectedPhotos index:indexPath.row];
//            imagePickerVc.maxImagesCount = 9;
//            imagePickerVc.allowPickingGif = NO;
//            imagePickerVc.allowPickingOriginalPhoto = YES;
//            imagePickerVc.allowPickingMultipleVideo = YES;
////            imagePickerVc.showSelectedIndex = NO;
//            imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
//            [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
//                self->_selectedPhotos = [NSMutableArray arrayWithArray:photos];
//                self->_selectedAssets = [NSMutableArray arrayWithArray:assets];
//                self->_isSelectOriginalPhoto = isSelectOriginalPhoto;
//                [self->_collectionView reloadData];
//                self->_collectionView.contentSize = CGSizeMake(0, ((self->_selectedPhotos.count + 2) / 3 ) * (self->_margin + self->_itemWH));
//            }];
//            [[self getPresentedViewController] presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([picker isKindOfClass:[UIImagePickerController class]]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}
#pragma mark - TZImagePickerControllerDelegate
/// 用户点击了取消
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    // NSLog(@"cancel");
}
// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    
    
    if (_videoUrlDate) {
        [_selectedPhotos removeAllObjects];
        [_selectedAssets removeAllObjects];
        _videoUrlDate = nil;
    }
    
    [_selectedPhotos addObjectsFromArray:photos];
    [_selectedAssets addObjectsFromArray:assets];
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
    [_collectionView reloadData];
    
}
// 如果用户选择了一个视频，下面的handle会被执行
// 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    _selectedPhotos = [NSMutableArray arrayWithArray:@[coverImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];

    [[TZImageManager manager] getVideoOutputPathWithAsset:asset presetName:AVAssetExportPreset640x480 success:^(NSString *outputPath) {
//        NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
     _videoUrlDate = [NSData dataWithContentsOfFile:outputPath];
        // Export completed, send video here, send by outputPath or NSData
        // 导出完成，在这里写上传代码，通过路径或者通过NSData上传
    } failure:^(NSString *errorMessage, NSError *error) {
//        NSLog(@"视频导出失败:%@,error:%@",errorMessage, error);
    }];
    [_collectionView reloadData];
}
#pragma mark - Click Event
///删除
- (void)deleteBtnClik:(UIButton *)sender {
    [_selectedPhotos removeObjectAtIndex:sender.tag];
    [_selectedAssets removeObjectAtIndex:sender.tag];
    
    [_collectionView performBatchUpdates:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
        [self->_collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        [self->_collectionView reloadData];
    }];
}
///上传
-(void)uploadAction:(UIButton *)sender{

    if (_uploadBlock) {
        _uploadBlock(_selectedPhotos,(_videoUrlDate) ? 2 : 1,_videoUrlDate);
    }
}
///拍照
- (void)chooseImage {

    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请选择" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"拍照/视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takePhoto];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"相册图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
 
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
        imagePickerVc.allowPickingVideo = NO;
        [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            
        }];
        [[self getPresentedViewController] presentViewController:imagePickerVc animated:YES completion:nil];
        
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"相册视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
        imagePickerVc.allowPickingImage = NO;
        [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        }];
        [[self getPresentedViewController] presentViewController:imagePickerVc animated:YES completion:nil];
        
    }];
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVC addAction:action1];
    [alertVC addAction:action2];
    [alertVC addAction:action3];
    [alertVC addAction:action4];
    [[self getPresentedViewController] presentViewController:alertVC animated:YES completion:nil];
  
}

- (UIViewController *)getPresentedViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    if (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

/**
 pai'z
 */
- (void)takePhoto{

    
    HLHJCustomCameraViewController *camera = [[HLHJCustomCameraViewController alloc]init];
    camera.allowTakePhoto = YES;
    camera.allowRecordVideo = YES;
    camera.sessionPreset = HLHJCaptureSessionPreset1280x720;
    camera.videoType =HLHJExportVideoTypeMp4;
    camera.circleProgressColor = [UIColor blueColor];
    camera.maxRecordDuration = 15;
    
    camera.doneBlock = ^(UIImage *image, NSURL *videoUrl) {
        if (image){
            [HLHJFactStartFooterView saveImageToAblum:image completion:^(BOOL suc, PHAsset *asset) {
                if (asset) {
                    if (_videoUrlDate) {
                        [_selectedPhotos removeAllObjects];
                        [_selectedAssets removeAllObjects];
                         _videoUrlDate = nil;
                    }
                    [_selectedPhotos addObjectsFromArray:@[image]];
                    [_selectedAssets addObjectsFromArray:@[asset]];
                   
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_collectionView reloadData];
                    });
                }
            }];
        }else if (videoUrl){

            [HLHJFactStartFooterView saveVideoToAblum:videoUrl completion:^(BOOL suc, PHAsset *asset) {
                if (asset) {
                    
                    UIImage *image =   [self firstFrameWithVideoURL:videoUrl size:CGSizeMake(100, 100)];
                    _selectedPhotos = [NSMutableArray arrayWithArray:@[image]];
                    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
                    _videoUrlDate = [NSData dataWithContentsOfURL:videoUrl];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_collectionView reloadData];
                    });
                }
            }];
        }
    };
    [[self getPresentedViewController] presentViewController:camera animated:YES completion:nil];
}
#pragma mark ---- 获取图片第一帧
- (UIImage *)firstFrameWithVideoURL:(NSURL *)url size:(CGSize)size
{
    // 获取视频第一帧
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(size.width, size.height);
    NSError *error = nil;
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(0, 10) actualTime:NULL error:&error];
    {
        return [UIImage imageWithCGImage:img];
    }
    return nil;
}

/**
 * @brief 保存图片到系统相册
 */
+ (void)saveImageToAblum:(UIImage *)image completion:(void (^)(BOOL suc, PHAsset *asset))completion {
    
    
    if(@available(iOS 11.0, *)){
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusNotDetermined || status == PHAuthorizationStatusAuthorized) {
               
                __block PHObjectPlaceholder *placeholderAsset=nil;
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    PHAssetChangeRequest *newAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                    placeholderAsset = newAssetRequest.placeholderForCreatedAsset;
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    if (!success) {
                        if (completion) completion(NO, nil);
                        return;
                    }
                    PHAsset *asset = [self getAssetFromlocalIdentifier:placeholderAsset.localIdentifier];
                    PHAssetCollection *desCollection = [self getDestinationCollection];
                    if (!desCollection) completion(NO, nil);
                    
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:desCollection] addAssets:@[asset]];
                    } completionHandler:^(BOOL success, NSError * _Nullable error) {
                        if (completion) completion(success, asset);
                    }];
                }];
                
            }else {
                    [[HLHJFactStartFooterView alloc ]showAlert];
            }
            
        }];
         
    }else {
    
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied) {

        [[HLHJFactStartFooterView alloc ]showAlert];
    } else if (status == PHAuthorizationStatusRestricted) {

        [[HLHJFactStartFooterView alloc ]showAlert];
    } else {
        __block PHObjectPlaceholder *placeholderAsset=nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *newAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            placeholderAsset = newAssetRequest.placeholderForCreatedAsset;
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (!success) {
                if (completion) completion(NO, nil);
                return;
            }
            PHAsset *asset = [self getAssetFromlocalIdentifier:placeholderAsset.localIdentifier];
            PHAssetCollection *desCollection = [self getDestinationCollection];
            if (!desCollection) completion(NO, nil);
            
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:desCollection] addAssets:@[asset]];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (completion) completion(success, asset);
            }];
        }];
    }
        
    }
    
}
/**
 * @brief 保存视频到系统相册
 */
+ (void)saveVideoToAblum:(NSURL *)url completion:(void (^)(BOOL suc, PHAsset *asset))completion {
    
    
    if(@available(iOS 11.0, *)){
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusNotDetermined || status == PHAuthorizationStatusAuthorized) {
            
            __block PHObjectPlaceholder *placeholderAsset=nil;
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetChangeRequest *newAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
                placeholderAsset = newAssetRequest.placeholderForCreatedAsset;
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (!success) {
                    if (completion) completion(NO, nil);
                    return;
                }
                PHAsset *asset = [self getAssetFromlocalIdentifier:placeholderAsset.localIdentifier];
                PHAssetCollection *desCollection = [self getDestinationCollection];
                if (!desCollection) completion(NO, nil);
                
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:desCollection] addAssets:@[asset]];
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    if (completion) completion(success, asset);
                }];
            }];
        }else{
            
            [[HLHJFactStartFooterView alloc ]showAlert];
        } }];
        
    }else {


        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusDenied) {
            [[HLHJFactStartFooterView alloc ]showAlert];
        } else if (status == PHAuthorizationStatusRestricted) {
            [[HLHJFactStartFooterView alloc ]showAlert];

        } else {
            __block PHObjectPlaceholder *placeholderAsset=nil;
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetChangeRequest *newAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
                placeholderAsset = newAssetRequest.placeholderForCreatedAsset;
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (!success) {
                    if (completion) completion(NO, nil);
                    return;
                }
                PHAsset *asset = [self getAssetFromlocalIdentifier:placeholderAsset.localIdentifier];
                PHAssetCollection *desCollection = [self getDestinationCollection];
                if (!desCollection) completion(NO, nil);
                
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:desCollection] addAssets:@[asset]];
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    if (completion) completion(success, asset);
                }];
            }];
        }
        
    }
    
}
+ (PHAsset *)getAssetFromlocalIdentifier:(NSString *)localIdentifier{
    if(localIdentifier == nil){
        return nil;
    }
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
    if(result.count){
        return result[0];
    }
    return nil;
}
//获取自定义相册
+ (PHAssetCollection *)getDestinationCollection
{
    //找是否已经创建自定义相册
    PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collectionResult) {
        if ([collection.localizedTitle isEqualToString:kAPPName]) {
            return collection;
        }
    }
    //新建自定义相册
    __block NSString *collectionId = nil;
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:kAPPName].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    if (error) {
        return nil;
    }
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].lastObject;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}
- (void)showAlert {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"此应用没有权限访问您的相机或照片,您可以在隐私-设置中启用访问" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication]canOpenURL:url]) {
                [[UIApplication sharedApplication]openURL:url];
            }
        });
    }];
    [alertVC addAction:action1];
    [alertVC addAction:action2];
    [[self getPresentedViewController] presentViewController:alertVC animated:YES completion:nil];
    
}


@end
