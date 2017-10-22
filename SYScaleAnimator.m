//
//  SYScaleAnimator.m
//  SYPhotoVew
//
//  Created by SY on 17/9/17.
//  Copyright © 2017年 shenyue. All rights reserved.
//

#import "SYScaleAnimator.h"

@implementation SYScaleAnimator
-(instancetype)initWithStartView:(UIView *)startView endView:(UIView *)endView scaleView:(UIView *)scaleView{
    if (self = [super init]) {
        self.startView = startView;
        self.endView = endView;
        self.scaleView = scaleView;
    }
    return self;
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.25f;
}
-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    if (!fromVC) return;
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if (!toVC) return;
    
    BOOL presentation = toVC.presentingViewController == fromVC;
    UIView *presentedView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    // dismissal转场，需要把presentedView隐藏，只显示scaleView
    if (!presentation || presentedView) {
        presentedView.hidden = YES;
    }
    // 转场容器
    UIView *containerView = transitionContext.containerView;
    if(!self.startView && !self.scaleView)return;
    CGRect startFrame = [self.startView convertRect:self.startView.bounds toView:containerView];

    // 暂不求endFrame
    CGRect endFrame = startFrame;
    CGFloat endAlpha = 0.0f;
    
    if (self.endView) {
        // 当前正在显示视图的前一个页面关联视图已经存在，此时分两种情况
        // 1、该视图显示在屏幕内，作scale动画
        // 2、该视图不显示在屏幕内，作fade动画
    
        CGRect relativeFrame = [self.endView convertRect:self.endView.bounds toView:nil];
        CGRect keyWindowBounds =  [UIScreen mainScreen].bounds;
        
        if (CGRectIntersectsRect(keyWindowBounds, relativeFrame)) {
            // 在屏幕内，求endFrame，让其缩放
            endAlpha = 1.0;
            endFrame = [self.endView convertRect:self.endView.bounds toView:containerView];
        }
    }
   
    
    self.scaleView.frame = startFrame;
    [containerView addSubview:self.scaleView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        self.scaleView.alpha = endAlpha;
        self.scaleView.frame = endFrame;
    } completion:^(BOOL finished) {
        // presentation转场，需要把目标视图添加到视图栈
        UIView *presentedView = [transitionContext viewForKey:UITransitionContextToViewKey];
        if (presentation || presentedView) {
            [containerView addSubview:presentedView];
        }
        [self.scaleView removeFromSuperview];
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];


}
@end
