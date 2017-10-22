//
//  SYPhotoBrowser.m
//  SYPhotoVew
//
//  Created by SY on 17/9/17.
//  Copyright © 2017年 shenyue. All rights reserved.
//

#import "SYPhotoBrowser.h"
#import "SYScaleAnmatorCoordinator.h"
#import "SYScaleAnimator.h"
#import "SYPhotoBrowserLayout.h"
#import "SYPhotoBrowserCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@import AVKit;

@interface SYPhotoBrowser ()<UIViewControllerTransitioningDelegate,UICollectionViewDataSource,UICollectionViewDelegate,SYPhotoBrowserCellDelegate>
/// 当前显示的图片序号，从0开始
@property(nonatomic,assign) CGFloat currentIndex;
/// 当前正在显示视图的前一个页面关联视图
@property(nonatomic,weak) UIView *relatedView;
/// 转场协调器
@property(nonatomic,weak) SYScaleAnmatorCoordinator *animatorCoordinator;
/// presentation转场动画
@property(nonatomic,strong) SYScaleAnimator *presentationAnimator;
/// 本VC的presentingViewController
@property(nonatomic,weak) UIViewController *presentingVC;
/// 容器
@property(nonatomic,strong) UICollectionView *collectionView;
/// 容器layout
@property(nonatomic,strong) SYPhotoBrowserLayout *flowLayout;
/// PageControl
@property(nonatomic,strong) UIView *pageControl;
  /// 标记第一次viewDidAppeared
@property(nonatomic,assign) BOOL onceViewDidAppeared;
/// 保存原windowLevel
@property(nonatomic,assign) UIWindowLevel originWindowLevel;
 /// 是否已初始化视图
@property(nonatomic,assign) BOOL didInitializedLayout;

@property(nonatomic,weak) AVPlayerViewController *playerViewController;
@end

@implementation SYPhotoBrowser
-(instancetype)initWithShowByViewController:(UIViewController *)presentingVC photoBrowserDelegate:(id<PhotoBrowserDelegate>)delegate{
    if (self = [super init]) {
        self.presentingVC = presentingVC;
        self.photoBrowserDelegate = delegate;
        self.flowLayout = [SYPhotoBrowserLayout new];
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        self.photoSpacing = 30;
        self.imageScaleMode =  UIViewContentModeScaleAspectFill;
        self.imageMaximumZoomScale = 2.0f;
        self.imageZoomScaleForDoubleTap = 2.0f;
    }
    return self;
    

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialLayout];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // 页面出来后，再显示pageControl
    if (!self.pageControlDelegate) return;
    if(!self.onceViewDidAppeared && self.pageControl){
        self.onceViewDidAppeared = true;
        [self.view addSubview:self.pageControl];
        if ([self.pageControlDelegate respondsToSelector:@selector(photoBrowserPageControl:needLayoutIn:)]) {
            [self.pageControlDelegate photoBrowserPageControl:self.pageControl needLayoutIn:self.view];
        }
    }
}
#pragma mark -UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.photoBrowserDelegate && [self.photoBrowserDelegate respondsToSelector:@selector(numberOfPhotos:)]) {
        return [self.photoBrowserDelegate numberOfPhotos:self];
    }
    return 0;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SYPhotoBrowserCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SYPhotoBrowserCell class]) forIndexPath:indexPath];
    cell.imageView.contentMode = self.imageScaleMode;
    cell.PhotoBrowserCellDelegate = self;
    if (!self.photoBrowserDelegate) {
        [cell setImage:nil highQualityUrl:nil rawUrl:nil];
    }else{
        // 缩略图
        UIImage *thumbnailImage = nil;
        if ([self.photoBrowserDelegate respondsToSelector:@selector(photoBrowser:thumbnailImageForIndex:)]) {
            thumbnailImage = [self.photoBrowserDelegate photoBrowser:self thumbnailImageForIndex:indexPath.item];
        }
        // 高清图url
        NSURL *highQualityUrl = nil;
        if ([self.photoBrowserDelegate respondsToSelector:@selector(photoBrowser:highQualityUrlForIndex:)]) {
            highQualityUrl = [self.photoBrowserDelegate photoBrowser:self highQualityUrlForIndex:indexPath.item];
        }
       // 原图url
        NSURL *rawUrl = nil;
        if ([self.photoBrowserDelegate respondsToSelector:@selector(photoBrowser:rawUrlForIndex:)]) {
            rawUrl = [self.photoBrowserDelegate photoBrowser:self rawUrlForIndex:indexPath.item];
        }
         [cell setImage:thumbnailImage highQualityUrl:highQualityUrl rawUrl:rawUrl];
    }
    BOOL isImage = YES;
    if ([self.photoBrowserDelegate respondsToSelector:@selector(numberOfPhotos:ViewTypeIndex:)]) {
        isImage = [self.photoBrowserDelegate numberOfPhotos:self ViewTypeIndex:indexPath.item];
    }
    cell.isImage = isImage;
    cell.imageMaximumZoomScale = self.imageMaximumZoomScale;
    cell.imageZoomScaleForDoubleTap = self.imageZoomScaleForDoubleTap;
    cell.tag = indexPath.item;
    return cell;
}
/// 减速完成后，计算当前页
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat width = scrollView.bounds.size.width + self.photoSpacing;
    self.currentIndex = (int)(offsetX / width);
}
#pragma mark -UIViewControllerTransitioningDelegate
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    // 视图布局
    [self initialLayout];
    // 立即加载collectionView
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    [self.collectionView layoutIfNeeded];
    SYPhotoBrowserCell *cell = (SYPhotoBrowserCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cell.imageView.image];
    imageView.contentMode = self.imageScaleMode;
    imageView.clipsToBounds = true;
    // 创建animator
    SYScaleAnimator *animator = [[SYScaleAnimator alloc] initWithStartView:self.relatedView endView:cell.imageView scaleView:imageView];
    self.presentationAnimator = animator;
    return animator;

}
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    if(!self.collectionView.visibleCells.count){
        return nil;
    }
    SYPhotoBrowserCell *cell = self.collectionView.visibleCells.firstObject;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cell.imageView.image];
    imageView.contentMode = self.imageScaleMode;
    imageView.clipsToBounds = true;
    return [[SYScaleAnimator alloc] initWithStartView:cell.imageView endView:self.relatedView scaleView:imageView];
}
-(UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController  *)presenting sourceViewController:(UIViewController *)source{
    SYScaleAnmatorCoordinator *coordinator = [[SYScaleAnmatorCoordinator alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    coordinator.currentHiddenView = self.relatedView;
    self.animatorCoordinator = coordinator;
    return coordinator;
}
#pragma mark -PhotoBrowserCellDelegate
-(void)photoBrowserCellDidSingleTap:(SYPhotoBrowserCell *)PhotoBrowserCell{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)photoBrowserCell:(SYPhotoBrowserCell *)PhotoBrowserCell didPanScale:(CGFloat)scale{
    // 实测用scale的平方，效果比线性好些
    CGFloat alpha = scale * scale;
    self.animatorCoordinator.maskView.alpha = alpha;
    self.pageControl.alpha = alpha;
}
-(void)photoBrowserCell:(SYPhotoBrowserCell *)PhotoBrowserCell didLongPressWith:(UIImage *)image{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:PhotoBrowserCell];
    if(indexPath){
        if (self.photoBrowserDelegate && [self.photoBrowserDelegate respondsToSelector:@selector(photoBrowser:didLongPressForIndex:image:)] ) {
            [self.photoBrowserDelegate photoBrowser:self didLongPressForIndex:indexPath.item image:image];
        }
    }
}
-(void)videoClickPhotoBrowserCell:(SYPhotoBrowserCell *)PhotoBrowserCell{
    NSURL *url = nil;
    if ([self.photoBrowserDelegate respondsToSelector:@selector(numberOfPhotos:videoURLIndex:completion:)]) {
        __weak typeof(self) weakSelf = self;
        url = [self.photoBrowserDelegate numberOfPhotos:self videoURLIndex:PhotoBrowserCell.tag completion:^(NSURL *url){
            [weakSelf palyURL:url];
        }];
    }
     [self palyURL:url];
}
-(void)palyURL:(NSURL *)url{
     if (!url) return;
    AVPlayer *player = [AVPlayer playerWithURL:url];
    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc]init];
    playerVC.player = player;
    [self presentViewController:playerVC animated:NO completion:nil];
    [playerVC.player play];
}
/// 禁止旋转
-(BOOL)shouldAutorotate{
    return NO;
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}
-(void)initialLayout{
    if (self.didInitializedLayout) return;
    self.didInitializedLayout = YES;
    // flowLayout
    self.flowLayout.minimumLineSpacing = self.photoSpacing;
    self.flowLayout.itemSize = self.view.bounds.size;
    // collectionView
    self.collectionView.frame = self.view.bounds;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[SYPhotoBrowserCell class] forCellWithReuseIdentifier:NSStringFromClass([SYPhotoBrowserCell class])];

    [self.view addSubview:self.collectionView];
}
-(void)showIndex:(NSInteger)index{
    self.currentIndex = index;
    self.transitioningDelegate = self;
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.modalPresentationCapturesStatusBarAppearance = YES;
    [self.presentingVC presentViewController:self animated:YES completion:nil];
}
+(void)showByViewController:(UIViewController *)presentingVC photoBrowserDelegate:(id<PhotoBrowserDelegate>)delegate index:(NSInteger)index{
    SYPhotoBrowser *vc = [[SYPhotoBrowser alloc] initWithShowByViewController:presentingVC photoBrowserDelegate:delegate];
    [vc showIndex:index];
}
-(UIView *)pageControl{
    if(_pageControl == nil){
        if (self.pageControlDelegate && [self.pageControlDelegate respondsToSelector:@selector(pageControlOfPhotoBrowser:)]) {
            _pageControl = [self.pageControlDelegate pageControlOfPhotoBrowser:self];
        }
    }
    return _pageControl;
}
-(UIView *)relatedView{
    if (self.photoBrowserDelegate && [self.photoBrowserDelegate respondsToSelector:@selector(photoBrowser:thumbnailViewForIndex:)]) {
        return [self.photoBrowserDelegate photoBrowser:self thumbnailViewForIndex:self.currentIndex];
    }
    return nil;
}
-(void)setCurrentIndex:(CGFloat)currentIndex{
    _currentIndex = currentIndex;
    [self.animatorCoordinator updateCurrentHiddenView:self.relatedView];
    
    if (self.pageControlDelegate && [self.pageControlDelegate respondsToSelector:@selector(photoBrowserPageControl:didChangedCurrentPage:)]) {
        [self.pageControlDelegate photoBrowserPageControl:self.pageControl didChangedCurrentPage:currentIndex];
    }
}
@end
