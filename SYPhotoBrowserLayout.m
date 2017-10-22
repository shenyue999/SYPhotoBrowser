//
//  SYPhotoBrowserLayout.m
//  SYPhotoVew
//
//  Created by SY on 17/9/17.
//  Copyright © 2017年 shenyue. All rights reserved.
//

#import "SYPhotoBrowserLayout.h"



@implementation SYPhotoBrowserLayout

-(instancetype)init{
    if (self = [super init]) {
        self.minPage = 0;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}
/// 调整scroll停下来的位置
-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
    // 页码
    CGFloat page = roundf(proposedContentOffset.x / self.pageWidth);
    
    // 处理轻微滑动
    if (velocity.x > 0.2 ){
        page += 1;
    } else if( velocity.x < -0.2 ){
        page -= 1;
    }
    // 一次滑动不允许超过一页
    if (page > self.lastPage + 1 ){
        page = self.lastPage + 1;
    } else if (page < self.lastPage - 1 ){
        page = self.lastPage - 1;
    }
    if (page > self.maxPage ){
        page = self.maxPage;
    } else if( page < self.minPage ){
        page = self.minPage;
    }
    self.lastPage = page;
    return CGPointMake(page * self.pageWidth, 0);
}
-(CGFloat)pageWidth{
    if (_pageWidth ==0) {
        _pageWidth = self.itemSize.width + self.minimumLineSpacing;
       return _pageWidth;
    }else{
        return _pageWidth;
    }
    
}
-(CGFloat)lastPage{
    if (_lastPage == 0) {
        CGFloat offsetX = self.collectionView.contentOffset.x;
        if (offsetX < 0.0) {
            return 0;
        }
        _lastPage = roundf(offsetX / self.pageWidth);
        return _lastPage;
    }else{
        return _lastPage;
    }
    
}
-(CGFloat)maxPage{
    if (_maxPage == 0 ) {
        CGFloat contentWidth = self.collectionView.contentSize.width;
        if (contentWidth < 0.0) {
            return 0;
        }
        _maxPage = roundf(contentWidth / self.pageWidth - 1);
        return _maxPage;
    }else{
        return _maxPage;
    }
   


}
@end
