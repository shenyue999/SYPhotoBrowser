//
//  SYScaleAnmatorCoordinator.h
//  SYPhotoVew
//
//  Created by SY on 17/9/17.
//  Copyright © 2017年 shenyue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYScaleAnmatorCoordinator : UIPresentationController
/// 蒙板
@property(nonatomic,weak) UIView *currentHiddenView;
/// 更新动画结束后需要隐藏的view
@property(nonatomic,strong) UIView *maskView;
/// 更新动画结束后需要隐藏的view
-(void)updateCurrentHiddenView:(UIView *)view;

@end
