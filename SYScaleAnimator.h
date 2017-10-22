//
//  SYScaleAnimator.h
//  SYPhotoVew
//
//  Created by SY on 17/9/17.
//  Copyright © 2017年 shenyue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface SYScaleAnimator : NSObject <UIViewControllerAnimatedTransitioning>
/// 动画开始位置的视图
@property(nonatomic,strong) UIView *startView;
/// 动画结束位置的视图
@property(nonatomic,strong) UIView *endView;
/// 用于转场时的缩放视图
@property(nonatomic,strong) UIView *scaleView;
-(instancetype)initWithStartView:(UIView *)startView endView:(UIView *)endView scaleView:(UIView *)scaleView;
@end
