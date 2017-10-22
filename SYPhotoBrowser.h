//
//  SYPhotoBrowser.h
//  SYPhotoVew
//
//  Created by SY on 17/9/17.
//  Copyright © 2017年 shenyue. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYPhotoBrowser;
@protocol PhotoBrowserDelegate <NSObject>
/// 实现本方法以返回图片数量
-(NSInteger)numberOfPhotos:(SYPhotoBrowser *)PhotoBrowser;
/// 实现本方法以返回默认图片，缩略图或占位图
-(UIImage *)photoBrowser:(SYPhotoBrowser *)PhotoBrowser thumbnailImageForIndex:(NSInteger)index;
/// 实现本方法以返回默认图所在view，在转场动画完成后将会修改这个view的hidden属性
/// 比如你可返回ImageView，或整个Cell
-(UIView *)photoBrowser:(SYPhotoBrowser *)PhotoBrowser thumbnailViewForIndex:(NSInteger)index;
@optional
/// 实现本方法以返回高质量图片的url。可选
-(NSURL *)photoBrowser:(SYPhotoBrowser *)PhotoBrowser highQualityUrlForIndex:(NSInteger)index;
/// 实现本方法以返回原图url。可选
-(NSURL *)photoBrowser:(SYPhotoBrowser *)PhotoBrowser rawUrlForIndex:(NSInteger)index;
/// 长按时回调。可选
-(void)photoBrowser:(SYPhotoBrowser *)PhotoBrowser didLongPressForIndex:(NSInteger)index image:(UIImage *)image;
//类型//
-(BOOL)numberOfPhotos:(SYPhotoBrowser *)PhotoBrowser ViewTypeIndex:(NSInteger)index;

-(NSURL *)numberOfPhotos:(SYPhotoBrowser *)PhotoBrowser videoURLIndex:(NSInteger)index completion:(void(^)(NSURL *url))completionBlock;

@end
@protocol PhotoBrowserPageControlDelegate <NSObject>
/// 取PageControl，只会取一次
-(UIView *)pageControlOfPhotoBrowser:(SYPhotoBrowser *)PhotoBrowser;
/// 添加到父视图上时调用
-(void)photoBrowserPageControl:(UIView *)pageControl didMoveTo:(UIView *)superView;
/// 让pageControl布局时调用
-(void)photoBrowserPageControl:(UIView *)pageControl needLayoutIn:(UIView *)superView;
/// 页码变更时调用
-(void)photoBrowserPageControl:(UIView *)pageControl didChangedCurrentPage:(NSInteger)currentPage;
@end

@interface SYPhotoBrowser : UIViewController
/// 实现了PhotoBrowserDelegate协议的对象
@property(nonatomic,weak) id<PhotoBrowserDelegate> photoBrowserDelegate;
 /// 实现了PhotoBrowserPageControlDelegate协议的对象
@property(nonatomic,weak) id<PhotoBrowserPageControlDelegate> pageControlDelegate;
 /// 左右两张图之间的间隙 (默认30)
@property(nonatomic,assign) CGFloat photoSpacing;
 /// 图片缩放模式(默认UIViewContentModeScaleAspectFill)
@property(nonatomic,assign) UIViewContentMode imageScaleMode;
 /// 捏合手势放大图片时的最大允许比例(2.0)
@property(nonatomic,assign) CGFloat imageMaximumZoomScale;
/// 双击放大图片时的目标比例(2.0)
@property(nonatomic,assign) CGFloat imageZoomScaleForDoubleTap;
//初始化，传入用于present出本VC的VC，以及实现了PhotoBrowserDelegate协议的对象
-(instancetype)initWithShowByViewController:(UIViewController *)presentingVC photoBrowserDelegate:(id<PhotoBrowserDelegate>)delegate;
/// 展示，传入图片序号，从0开始
-(void)showIndex:(NSInteger)index;
/// 便利的展示方法，合并init和show两个步骤
+(void)showByViewController:(UIViewController *)presentingVC photoBrowserDelegate:(id<PhotoBrowserDelegate>)delegate index:(NSInteger)index;
@end
