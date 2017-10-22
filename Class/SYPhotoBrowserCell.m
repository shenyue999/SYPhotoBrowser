//
//  SYPhotoBrowserCell.m
//  SYPhotoVew
//
//  Created by SY on 17/9/17.
//  Copyright © 2017年 shenyue. All rights reserved.
//

#import "SYPhotoBrowserCell.h"
#import "SYPhotoBrowserProgressView.h"
@interface SYPhotoBrowserCell ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
/// 内嵌容器。本类不能继承UIScrollView。
/// 因为实测UIScrollView遵循了UIGestureRecognizerDelegate协议，而本类也需要遵循此协议，
/// 若继承UIScrollView则会覆盖UIScrollView的协议实现，故只内嵌而不继承。
@property(nonatomic,weak) UIScrollView *scrollView;
/// 加载进度指示器
@property(nonatomic,weak) SYPhotoBrowserProgressView *progressView;
/// 查看原图按钮
@property(nonatomic,strong) UIButton *rawImageButton;
 /// 计算contentSize应处于的中心位置
@property(nonatomic,assign) CGPoint centerOfContentSize;
/// 取图片适屏size
@property(nonatomic,assign) CGSize fitSize;
/// 取图片适屏frame
@property(nonatomic,assign) CGRect fitFrame;
 /// 记录pan手势开始时imageView的位置
@property(nonatomic,assign) CGRect beganFrame;
 /// 记录pan手势开始时，手势位置
@property(nonatomic,assign) CGPoint beganTouch;

@property(nonatomic,weak) UIButton *videoImageButton;
@end

@implementation SYPhotoBrowserCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIScrollView *scrollView= [UIScrollView new];
        self.scrollView  = scrollView;
        self.imageZoomScaleForDoubleTap = 2.0f;
        self.imageMaximumZoomScale = 2.0;
        [self.contentView addSubview:self.scrollView];
        self.scrollView.delegate = self;
        self.scrollView.maximumZoomScale = self.imageMaximumZoomScale;
        self.scrollView.showsVerticalScrollIndicator = false;
        self.scrollView.showsHorizontalScrollIndicator = false;
        UIImageView *imageView= [UIImageView new];
        self.imageView =  imageView;
        self.imageView.userInteractionEnabled  = YES;
        [self.scrollView addSubview:self.imageView];
        self.imageView.clipsToBounds = true;
        SYPhotoBrowserProgressView *progressView = [SYPhotoBrowserProgressView new];
        self.progressView =  progressView;
        [self.contentView addSubview:self.progressView];
        self.progressView.hidden = true;
        self.beganFrame = CGRectZero;
        self.beganTouch = CGPointZero;
        // 长按手势
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
        [self.contentView addGestureRecognizer:longPress];

        
        // 双击手势
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self.contentView addGestureRecognizer:doubleTap];
     
        
        // 单击手势
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap)];
        [self.contentView addGestureRecognizer:singleTap];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        // 拖动手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
        pan.delegate = self;
        [self.contentView addGestureRecognizer:pan];

        
        UIButton *videoImageButton = [UIButton buttonWithType: UIButtonTypeCustom];
        _videoImageButton = videoImageButton;
        [videoImageButton setImage:[UIImage imageNamed:@"video_icon_play"] forState:UIControlStateNormal];
        [videoImageButton addTarget:self action:@selector(palyClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.imageView addSubview:videoImageButton];
        videoImageButton.hidden = YES;

    }
    return self;
}
-(void)palyClick:(UIButton *)videoImageButton{
    if ([self.PhotoBrowserCellDelegate respondsToSelector:@selector(videoClickPhotoBrowserCell:)]) {
        [self.PhotoBrowserCellDelegate videoClickPhotoBrowserCell:self];
    }
}
/// 布局
-(void)doLayout{
    self.scrollView.frame = self.contentView.bounds;
    [self.scrollView setZoomScale:1.0f animated:NO];
    self.imageView.frame = self.fitFrame;
      [self.scrollView setZoomScale:1.0f animated:NO];
    self.progressView.center = CGPointMake(CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds));
    // 查看原图按钮
    if (!self.rawImageButton.isHidden) {
        [self.contentView addSubview:self.rawImageButton];
        [self.rawImageButton sizeToFit];
        CGRect frame = self.rawImageButton.bounds;
        frame.size.width += 14;
        self.rawImageButton.bounds = frame;
        self.rawImageButton.center =  CGPointMake(CGRectGetMidX(self.contentView.bounds),  self.contentView.bounds.size.height - 20 - self.rawImageButton.bounds.size.height);
        self.rawImageButton.hidden = NO;
    }
    
    self.videoImageButton.frame = CGRectMake((CGRectGetWidth(self.imageView.bounds) - 90)*0.5, (CGRectGetHeight(self.imageView.bounds) - 90)*0.5, 90, 90);
}
/// 响应单击
-(void)onSingleTap{
    if (self.PhotoBrowserCellDelegate && [self.PhotoBrowserCellDelegate respondsToSelector:@selector(photoBrowserCellDidSingleTap:)]) {
        [self.PhotoBrowserCellDelegate photoBrowserCellDidSingleTap:self];
    }
}
 /// 响应双击
-(void)onDoubleTap:(UITapGestureRecognizer *)dbTap{
    // 如果当前没有任何缩放，则放大到目标比例
    // 否则重置到原比例
    if (self.scrollView.zoomScale == 1.0f) {
        // 以点击的位置为中心，放大
        CGPoint  pointInView = [dbTap locationInView:self.imageView];
        CGFloat w = self.scrollView.bounds.size.width / self.imageZoomScaleForDoubleTap;
        CGFloat h = self.scrollView.bounds.size.height / self.imageZoomScaleForDoubleTap;
        CGFloat x = pointInView.x - (w / 2.0);
        CGFloat y = pointInView.y - (h / 2.0);
        [self.scrollView zoomToRect:CGRectMake(x, y, w, h) animated:YES];

    }else{
        [self.scrollView setZoomScale:1.0f animated:YES];
    }
}
 /// 响应拖动
-(void)onPan:(UIPanGestureRecognizer *)pan{
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{
            self.beganFrame = self.imageView.frame;
            self.beganTouch = [pan locationInView:self.scrollView];
        }
            break;
        case UIGestureRecognizerStateChanged:{
            // 拖动偏移量
            CGPoint translation = [pan translationInView:self.scrollView];
            CGPoint currentTouch = [pan locationInView:self.scrollView];
            // 由下拉的偏移值决定缩放比例，越往下偏移，缩得越小。scale值区间[0.3, 1.0]
            CGFloat scale = MIN(1.0, MAX(0.3, 1 - translation.y / self.bounds.size.height));
            
            CGFloat width = self.beganFrame.size.width * scale;
            CGFloat height = self.beganFrame.size.height * scale;
            
            // 计算x和y。保持手指在图片上的相对位置不变。
            // 即如果手势开始时，手指在图片X轴三分之一处，那么在移动图片时，保持手指始终位于图片X轴的三分之一处
            CGFloat xRate = (self.beganTouch.x - self.beganFrame.origin.x) / self.beganFrame.size.width;
            CGFloat currentTouchDeltaX = xRate * width;
            CGFloat x = currentTouch.x - currentTouchDeltaX;
            
            CGFloat yRate = (self.beganTouch.y - self.beganFrame.origin.y) / self.beganFrame.size.height;
            CGFloat currentTouchDeltaY = yRate * height;
            CGFloat y = currentTouch.y - currentTouchDeltaY;
            
            self.imageView.frame = CGRectMake(x, y, width, height);
            self.videoImageButton.frame = CGRectMake((width - 90)*0.5, (height - 90)*0.5, 90, 90);
            // 通知代理，发生了缩放。代理可依scale值改变背景蒙板alpha值
            if (self.PhotoBrowserCellDelegate && [self.PhotoBrowserCellDelegate respondsToSelector:@selector(photoBrowserCell:didPanScale:)]) {
                [self.PhotoBrowserCellDelegate photoBrowserCell:self didPanScale:scale];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:{
            if ([pan velocityInView:self].y > 0) {
                // dismiss
                [self onSingleTap];
            } else {
                // 取消dismiss
               [self endPan];
            }
        }
            break;
        default:{
            [self endPan];
        }
            break;
    }
}
-(void)onLongPress:(UILongPressGestureRecognizer *)press{
    UIImage *image = self.imageView.image;
    if (press.state == UIGestureRecognizerStateBegan && image) {
        if (self.PhotoBrowserCellDelegate && [self.PhotoBrowserCellDelegate respondsToSelector:@selector(photoBrowserCell:didLongPressWith:)]) {
            [self.PhotoBrowserCellDelegate photoBrowserCell:self didLongPressWith:image];
        }
    }
    
}
/// 响应查看原图按钮
-(void)onRawImageButtonTap{
    [self loadImagewithPlaceholder:self.imageView.image url:self.rawUrl];

    self.rawImageButton.hidden = true;

}
#pragma mark -UIScrollViewDelegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}
-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    self.imageView.center = self.centerOfContentSize;
}
#pragma mark -UIGestureRecognizerDelegate
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    // 只响应pan手势
    if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] ) {
        return YES;
    }
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
    CGPoint velocity = [pan velocityInView:self];
    // 向上滑动时，不响应手势
    if (velocity.y < 0) {
        return false;
    }
    // 横向滑动时，不响应pan手势
    if (abs((int)velocity.x) > (int)(velocity.y)) {
        return false;
    }
    // 向下滑动，如果图片顶部超出可视区域，不响应手势
    if (self.scrollView.contentOffset.y > 0 ){
        return false;
    }
    return true;
}
-(void)endPan{
    if (self.PhotoBrowserCellDelegate && [self.PhotoBrowserCellDelegate respondsToSelector:@selector(photoBrowserCell:didPanScale:)]) {
        [self.PhotoBrowserCellDelegate photoBrowserCell:self didPanScale:1.0f];
    }
    // 如果图片当前显示的size小于原size，则重置为原size
    CGSize size = self.fitSize;
    BOOL needResetSize = self.imageView.bounds.size.width < size.width || self.imageView.bounds.size.height < size.height;
   [UIView animateWithDuration:0.25 animations:^{
       self.imageView.center = self.centerOfContentSize;
       if (needResetSize){
           self.imageView.bounds = CGRectMake(self.imageView.bounds.origin.x, self.imageView.bounds.origin.y, size.width, size.height);
       }
   }];
}
/// 设置图片。image为placeholder图片，url为网络图片
-(void)setImage:(UIImage *)image highQualityUrl:(NSURL *)highQualityUrl rawUrl:(NSURL *)rawUrl{
    // 查看原图按钮
    self.rawImageButton.hidden = rawUrl == nil;
    self.rawUrl = rawUrl;
    
    // 取placeholder图像，默认使用传入的缩略图
    UIImage *placeholder = image;
    // 若已有原图缓存，优先使用原图
    // 次之使用高清图
    NSURL *url = highQualityUrl;
    UIImage *cacheImage = [self imageFor:rawUrl];
    if (cacheImage) {
        placeholder = cacheImage;
        url = rawUrl;
        self.rawImageButton.hidden = YES;
    }else if([self imageFor:highQualityUrl]){
        placeholder = [self imageFor:highQualityUrl];
    }
   
    // 处理只配置了原图而不配置高清图的情况。此时使用原图代替高清图作为下载url
    if (url == nil) {
        url = rawUrl;
    }
    if (url == nil) {
        self.imageView.image = image;
        [self doLayout];
        return;
    }
    [self loadImagewithPlaceholder:placeholder url:url];
    [self doLayout];
}
-(void)loadImagewithPlaceholder:(UIImage *)placeholder url:(NSURL *)url{
    self.progressView.hidden = false;
    __weak typeof(self) weakSelf = self;
    [self.imageView sd_setImageWithURL:url placeholderImage:placeholder options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        if (expectedSize > 0) {
            weakSelf.progressView.progress = (receivedSize / expectedSize) * 1.0f;
        }
    } completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
        weakSelf.progressView.hidden = YES;
        [weakSelf doLayout];
    }];

}
/// 根据url从缓存取图像
-(UIImage *)imageFor:(NSURL *)url{
    if (url == nil) return nil;
    UIImage *cacheImage =[[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:url.absoluteString];
    if (!cacheImage) {
        cacheImage =[[SDImageCache sharedImageCache] imageFromDiskCacheForKey:url.absoluteString];
    }
    return cacheImage;
}
-(void)setImageMaximumZoomScale:(CGFloat)imageMaximumZoomScale{
    _imageMaximumZoomScale = imageMaximumZoomScale;
    self.scrollView.maximumZoomScale = imageMaximumZoomScale;
}
-(UIButton *)rawImageButton{
    if (!_rawImageButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        _rawImageButton = button;
        [button setTitle:@"查看原图" forState:UIControlStateNormal];
        [button setTitle:@"查看原图" forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        button.layer.borderColor = [UIColor lightGrayColor].CGColor;
        button.layer.borderWidth = 1;
        button.layer.cornerRadius = 4;
        button.layer.masksToBounds = YES;
        [button addTarget:self action:@selector(onRawImageButtonTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rawImageButton;
}
-(CGPoint)centerOfContentSize{
    CGFloat deltaWidth = self.bounds.size.width - self.scrollView.contentSize.width;
    CGFloat offsetX = deltaWidth > 0 ? deltaWidth * 0.5 : 0;
    CGFloat deltaHeight = self.bounds.size.height - self.scrollView.contentSize.height;
    CGFloat offsetY = deltaHeight > 0 ? deltaHeight * 0.5 : 0;
    return CGPointMake(self.scrollView.contentSize.width* 0.5 + offsetX, self.scrollView.contentSize.height * 0.5 + offsetY);
}
-(CGSize)fitSize{
    UIImage *image = self.imageView.image;
    if (!image) {
        return CGSizeZero;
    }
    CGFloat width = self.scrollView.bounds.size.width;
    CGFloat scale = image.size.height / image.size.width;
    return CGSizeMake(width, width*scale);
}
-(CGRect)fitFrame{
    CGSize size = self.fitSize;
    CGFloat y = (self.scrollView.bounds.size.height - size.height) > 0 ? (self.scrollView.bounds.size.height - size.height) * 0.5 : 0;
    return CGRectMake(0, y, size.width, size.height);
}
-(void)setIsImage:(BOOL)isImage{
    _isImage = isImage;
    self.videoImageButton.hidden = isImage;
}



@end
