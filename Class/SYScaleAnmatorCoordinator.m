//
//  SYScaleAnmatorCoordinator.m
//  SYPhotoVew
//
//  Created by SY on 17/9/17.
//  Copyright © 2017年 shenyue. All rights reserved.
//

#import "SYScaleAnmatorCoordinator.h"

@implementation SYScaleAnmatorCoordinator



-(void)updateCurrentHiddenView:(UIView *)view{
    self.currentHiddenView.hidden = NO;
    self.currentHiddenView = view;
    view.hidden = YES;
}
-(void)presentationTransitionWillBegin{
    [super presentationTransitionWillBegin];
    if (!self.containerView) return;
    
    [self.containerView addSubview:self.maskView];
    self.maskView.frame = self.containerView.bounds;
    self.maskView.alpha = 0;
    self.currentHiddenView.hidden = true;
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.maskView.alpha = 1;
    } completion:nil];
}
-(void)dismissalTransitionWillBegin{
    [super dismissalTransitionWillBegin];
    self.currentHiddenView.hidden = true;
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.maskView.alpha = 0;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.currentHiddenView.hidden = false;
    }];
}
-(UIView *)maskView{
    if (!_maskView) {
        _maskView = [UIView new];
        _maskView.backgroundColor = [UIColor blackColor];
    }
    return _maskView;
}
@end
