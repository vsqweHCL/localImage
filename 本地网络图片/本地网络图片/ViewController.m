//
//  ViewController.m
//  本地网络图片
//
//  Created by xuzhiyong on 2020/3/2.
//  Copyright © 2020 xxx. All rights reserved.
//

#import "ViewController.h"
#import "TZImagePickerController.h"

#import "LAAttacheV.h"
#import "UIView+MJExtension.h"

#import "LAHttpModel.h"
#import "LAImageModel.h"
#import "MBProgressHUD.h"

@interface ViewController ()
<
LAAttacheVDelegate,
TZImagePickerControllerDelegate
>
@property (weak, nonatomic) IBOutlet UIView *imgCntV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgCntVH;

@property (nonatomic, strong) LAHttpModel *model;
@property (nonatomic, strong) NSMutableArray *imgM;


/** 假设后台url图片数组 */
@property (nonatomic, strong) NSArray *dataImgLists;
@end

#define Screen_Width [UIScreen mainScreen].bounds.size.width

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self requestData];
}

- (void)requestData {
    // 假装请求后台数据
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        LAHttpModel *model = [[LAHttpModel alloc] init];
        model.type = 0;
        model.imagesList = @[self.dataImgLists[0]]; // 默认随便取一张url图片
        model.oldImagesList = [NSMutableArray array];
        [model.oldImagesList addObjectsFromArray:model.imagesList];
        model.userImagesList = nil;
        self.model = model;
        
        // 刷新UI
        [self refreshUI];
    });
}

- (void)refreshUI {
    // 加号按钮
    LAImageModel *addModel = [[LAImageModel alloc] init];
    addModel.image = @"add";
    addModel.editor = NO;
    addModel.add = YES;
    LAAttacheV *addV = [[LAAttacheV alloc] init];
    addV.model = addModel;
    addV.delegate = self;
    [self.imgCntV removeAllSubviews];
    [self.imgM removeAllObjects];
    [self.model.totalM removeAllObjects];
    
    if (self.model.oldImagesList.count != 0) {
        [self.model.totalM addObject:self.model.oldImagesList]; // 后台
    }
    if (self.model.userImagesList.count != 0) {
        [self.model.totalM addObject:self.model.userImagesList]; // 本地
    }
    
    
    NSInteger userCount = self.model.userImagesList.count;
    NSInteger oldCount = self.model.oldImagesList.count;
    NSInteger totalCount = userCount + oldCount;
    // 添加本地图片
    for (NSInteger i = 0; i < userCount; i++) {
        LAImageModel *imgModel = [[LAImageModel alloc] init];
        imgModel.image = self.model.userImagesList[i];
        imgModel.editor = self.model.type != LAHttpModelTypeAuditing;
        imgModel.add = NO;
        imgModel.index = i;
        LAAttacheV *imageV = [[LAAttacheV alloc] init];
        [self.imgCntV addSubview:imageV];
        [self.imgM addObject:imageV];
        // 赋值
        imageV.model = imgModel;
        imageV.delegate = self;
    }
    // 添加后台图片
    for (NSInteger i = 0; i < oldCount; i++) {
        LAImageModel *imgModel = [[LAImageModel alloc] init];
        imgModel.image = self.model.oldImagesList[i];
        imgModel.editor = self.model.type != LAHttpModelTypeAuditing;
        imgModel.add = NO;
        imgModel.index = i + userCount;
        LAAttacheV *imageV = [[LAAttacheV alloc] init];
        [self.imgCntV addSubview:imageV];
        [self.imgM addObject:imageV];
        // 赋值
        imageV.model = imgModel;
        imageV.delegate = self;
    }
    
    if (self.model.type == LAHttpModelTypeDefault||
        self.model.type == LAHttpModelTypeUnPass) { // 准备上传或者不通过的时候
        if (totalCount < 9) {
            [self.imgCntV addSubview:addV];
            [self.imgM addObject:addV];
        }
    }
    
    // 布局计算
    CGFloat imageVMargin = 12;
    for (NSInteger i = 0; i < self.imgM.count; i++) {
        LAAttacheV *imageV = self.imgM[i];
        imageV.mj_h = 78;
        imageV.mj_w = 78;
        if (i == 0) {
            imageV.mj_x = 0;
            imageV.mj_y = 0;
        }
        else {
            LAAttacheV *lastImageV = self.imgM[i - 1];
            CGFloat leftWidth = CGRectGetMaxX(lastImageV.frame) + imageVMargin;
            CGFloat rightWidth = Screen_Width - 15 - 8 - leftWidth;
            if (rightWidth >= imageV.mj_w) { // 显示在当前行
                imageV.mj_y = lastImageV.mj_y;
                imageV.mj_x = leftWidth;
            }
            else { // 显示在下一行
                imageV.mj_x = 0;
                imageV.mj_y = CGRectGetMaxY(lastImageV.frame) + imageVMargin;
            }
        }
        self.imgCntVH.constant = CGRectGetMaxY(imageV.frame);
    }
    
}



#pragma mark - LAAttacheVDelegate
- (void)attacheV:(LAAttacheV *)attacheV didClickImageV:(LAImageModel *)imgModel {
    if (imgModel.add) {
        NSInteger count = self.model.userImagesList.count + self.model.oldImagesList.count;
        [self choosePicture:9-count];
        return;
    }
    // 预览
    NSInteger index = imgModel.index;
    if (index >= self.model.userImagesList.count) { // 证明是后台数据
        index -= self.model.userImagesList.count;
        NSLog(@"点击预览的是后台数据 = %ld",index);
    } else { // 证明是本地数据
        NSLog(@"点击预览的是本地数据 = %ld",index);
    }
}
- (void)attacheV:(LAAttacheV *)attacheV didClickCloseV:(LAImageModel *)imgModel {
    NSInteger index = imgModel.index;
    if (index >= self.model.userImagesList.count) { // 证明是后台数据
        index -= self.model.userImagesList.count;
        NSLog(@"删除的是后台数据 = %ld",index);
        [self.model.oldImagesList removeObjectAtIndex:index];
    } else { // 证明是本地数据
        NSLog(@"删除的是本地数据 = %ld",index);
        [self.model.userImagesList removeObjectAtIndex:index];
    }
    
    [self refreshUI];
}
- (void)choosePicture:(NSInteger)maxCount {
    if (maxCount <= 0) {
        NSLog(@"最大可选个数不能小于0");
        return;
    }
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:maxCount columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    imagePickerVc.allowCameraLocation = NO; // 不获取照片的地理位置
    imagePickerVc.allowTakePicture = YES; // 在内部显示拍照按钮
    imagePickerVc.allowTakeVideo = NO;   // 在内部显示拍视频按
    imagePickerVc.iconThemeColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];
    imagePickerVc.showPhotoCannotSelectLayer = YES;
    imagePickerVc.cannotSelectLayerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    [imagePickerVc setPhotoPickerPageUIConfigBlock:^(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine) {
        [doneButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }];
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.allowPickingMultipleVideo = NO; // 是否可以多选视频
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = YES;
    
    imagePickerVc.statusBarStyle = UIStatusBarStyleLightContent;
    // 设置是否显示图片序号
    imagePickerVc.showSelectedIndex = YES;
    // iOS13-presentViewController还原之前的效果
    imagePickerVc.modalPresentationStyle = 0;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - TZImagePickerControllerDelegate

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    NSMutableDictionary *imgDicM = [NSMutableDictionary dictionary];
        
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [self showMessage:@"导入图片中..." toView:nil];
    for (NSInteger i = 0; i < assets.count; i++) {
        PHAsset *asset = assets[i];
        dispatch_group_enter(group);
        dispatch_async(queue, ^{
            [[TZImageManager manager] getPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                if (photo) {
                    if (!isDegraded) { // 高清的
                        dispatch_group_leave(group);
                        LAImageModel *model = [[LAImageModel alloc] init];
                        model.image = photo;
                        [imgDicM setObject:model forKey:@(i).stringValue];
                    }
                }
            }];
        });
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 等前面的异步操作都执行完毕后，回到主线程.
        [self hideHUDForView:nil];
        NSMutableArray *imgIndexM = [NSMutableArray array];
        [imgDicM enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL * _Nonnull stop) {
            [imgIndexM addObject:@(key.integerValue)];
        }];
        // 排序
        NSArray *imgSortResults = [imgIndexM sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        // 重新整合有序的数据
        NSMutableArray *tempM = [NSMutableArray array];
        for (NSNumber *resultIndex in imgSortResults) {
            LAImageModel *model = [imgDicM valueForKey:[resultIndex stringValue]];
            [tempM addObject:model.image];
        }
        // 存到用户选择的图片数组中
        for (id photo in self.model.userImagesList) {
            [tempM addObject:photo];
        }
        self.model.userImagesList = tempM;
        
        [self refreshUI];
    });
    
}


#pragma mark - Private Method

- (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].delegate window];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    hud.label.numberOfLines = 0;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
//    hud.dimBackground = YES;
//    dispatch_async(dispatch_get_main_queue(), ^{
//    });
    return hud;
}

- (void)hideHUDForView:(UIView *)view
{
    if (view == nil) view = [[UIApplication sharedApplication].delegate window];
    [MBProgressHUD hideHUDForView:view animated:YES];
}

#pragma mark - Action

- (IBAction)submitAction:(id)sender {
    NSInteger userCount = self.model.userImagesList.count; // 用户手选本地的图片
    NSInteger oldCount = self.model.oldImagesList.count; // 后台已有的网络图片
    NSInteger totalCount = userCount + oldCount;
    if (totalCount == 0) {
        NSLog(@"请上传图片");
        return;
    }
    if (userCount != 0) { // 用户选了本地图片，先上传给阿里云转http图片，在拼接给后台
        [self showMessage:@"上传中..." toView:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hideHUDForView:nil];
            // 制造假数据
            NSMutableArray *tempM = [NSMutableArray array];
            for (NSInteger i = 0; i < userCount; i++) {
                // 用户选多少张，就取多少张url图片
                [tempM addObject:self.dataImgLists[i]];
            }
            // 再添加上之前后台返回的url图片数据
            [tempM addObjectsFromArray:self.model.oldImagesList];
            [self postHttpWithImageList:tempM];
        });
    } else { // 用户没有选择本地图片，直接用后台返回的图片url给后台
        [self postHttpWithImageList:self.model.oldImagesList];
    }
    
}
- (IBAction)clearAction:(id)sender {
    [self requestData];
}

- (void)postHttpWithImageList:(NSArray *)imageList {
    self.model.type = LAHttpModelTypeAuditing;
    self.model.imagesList = imageList;
    self.model.oldImagesList = [NSMutableArray array];
    [self.model.oldImagesList addObjectsFromArray:self.model.imagesList];
    self.model.userImagesList = nil;
    
    [self refreshUI];
    
    // 延迟1秒修改成不通过状态
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"延迟1秒修改成不通过状态");
        self.model.type = LAHttpModelTypeUnPass;
        [self refreshUI];
    });
}
#pragma mark - Property

- (NSMutableArray *)imgM {
    if (_imgM == nil) {
        _imgM = [NSMutableArray array];
    }
    return _imgM;
}
- (NSArray *)dataImgLists {
    if (_dataImgLists == nil) {
        _dataImgLists = @[@"http://tiebapic.baidu.com/forum/w%3D580%3B/sign=e401a7a821d12f2ece05ae687ff9d462/b2de9c82d158ccbff36c73450ed8bc3eb03541f9.jpg",
        @"http://tiebapic.baidu.com/forum/w%3D580%3B/sign=b4660d8b46da81cb4ee683c5625dd116/b64543a98226cffc071f5acdae014a90f603ea9c.jpg",
        @"http://tiebapic.baidu.com/forum/w%3D580%3B/sign=fd7e9e441bf3d7ca0cf63f7ec224bf09/9213b07eca806538698b7d6980dda144ad348263.jpg",
        @"https://imgsa.baidu.com/forum/w%3D580%3B/sign=868ab06c9d13b07ebdbd50003cec9023/91ef76c6a7efce1be06eff87a151f3deb48f6531.jpg",
        @"https://imgsa.baidu.com/forum/w%3D580%3B/sign=f9d1e1eda06eddc426e7b4f309e0b7fd/b219ebc4b74543a9750335c413178a82b901149a.jpg",
        @"http://tiebapic.baidu.com/forum/w%3D580%3B/sign=07cf4f69d8fc1e17fdbf8c397aabf703/63d9f2d3572c11dfed8a475c742762d0f703c272.jpg",
        @"http://tiebapic.baidu.com/forum/w%3D580%3B/sign=7756b06c1ef79052ef1f47363cc8d6ca/11385343fbf2b211c4e14631dd8065380dd78e86.jpg",
        @"http://tiebapic.baidu.com/forum/w%3D580%3B/sign=ba08dbfc182442a7ae0efdade178ac4b/8718367adab44aed0a2a5f9ba41c8701a18bfb6d.jpg",
        @"http://tiebapic.baidu.com/forum/w%3D580%3B/sign=f9082c569118367aad897fd51e488ad4/503d269759ee3d6d1ca266b454166d224f4ade6d.jpg"];
    }
    return _dataImgLists;
}
@end
