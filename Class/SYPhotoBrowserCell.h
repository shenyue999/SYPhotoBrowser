//
//  SYPhotoBrowserCell.h
//  SYPhotoVew
//
//  Created by SY on 17/9/17.
//  Copyright © 2017年 shenyue. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYPhotoBrowserCell;
@protocol SYPhotoBrowserCellDelegate <NSObject>
 /// 单击时回调
-(void)photoBrowserCellDidSingleTap:(SYPhotoBrowserCell *)PhotoBrowserCell;
/// 拖动时回调。scale:缩放比率
-(void)photoBrowserCell:(SYPhotoBrowserCell *)PhotoBrowserCell didPanScale:(CGFloat)scale;
/// 长按时回调
-(void)photoBrowserCell:(SYPhotoBrowserCell *)PhotoBrowserCell didLongPressWith:(UIImage *)image;
/// 视频播放按钮点击
-(void)videoClickPhotoBrowserCell:(SYPhotoBrowserCell *)PhotoBrowserCell; 
@end

@interface SYPhotoBrowserCell : UICollectionViewCell
 /// 代理
@property(nonatomic,weak) id<SYPhotoBrowserCellDelegate> PhotoBrowserCellDelegate;
/// 显示图像
@property(nonatomic,weak) UIImageView *imageView;
//是否是视频
@property(nonatomic,assign) BOOL isImage;
/// 原图url
@property(nonatomic,strong) NSURL *rawUrl;
/// 捏合手势放大图片时的最大允许比例(2.0)
@property(nonatomic,assign) CGFloat imageMaximumZoomScale;
/// 双击放大图片时的目标比例(2.0)
@property(nonatomic,assign) CGFloat imageZoomScaleForDoubleTap;
-(void)setImage:(UIImage *)image highQualityUrl:(NSURL *)highQualityUrl rawUrl:(NSURL *)rawUrl;
@end
