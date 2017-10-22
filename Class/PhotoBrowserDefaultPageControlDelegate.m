//
//  PhotoBrowserDefaultPageControlDelegate.m
//  SYPhotoVew
//
//  Created by SY on 17/9/17.
//  Copyright © 2017年 shenyue. All rights reserved.
//

#import "PhotoBrowserDefaultPageControlDelegate.h"

@implementation PhotoBrowserDefaultPageControlDelegate
-(instancetype)initWithnumberOfPages:(NSInteger)numberOfPages{
    if (self = [super init]) {
        self.numberOfPages = numberOfPages;
    }
    return self;
}
-(UIView *)pageControlOfPhotoBrowser:(SYPhotoBrowser *)PhotoBrowser{
    UIPageControl *pageControl = [UIPageControl new];
    pageControl.numberOfPages = self.numberOfPages;
    return pageControl;
}
-(void)photoBrowserPageControl:(UIView *)pageControl didMoveTo:(UIView *)superView{
    
}
-(void)photoBrowserPageControl:(UIView *)pageControl needLayoutIn:(UIView *)superView{
    [pageControl sizeToFit];
    
    pageControl.center = CGPointMake(CGRectGetMidX(superView.bounds), CGRectGetMaxY(superView.bounds) - 20);

}
-(void)photoBrowserPageControl:(UIView *)pageControl didChangedCurrentPage:(NSInteger)currentPage{
    if (![pageControl isKindOfClass:[UIPageControl class]]) return;
    
    ((UIPageControl *)pageControl).currentPage = currentPage;
}
@end
