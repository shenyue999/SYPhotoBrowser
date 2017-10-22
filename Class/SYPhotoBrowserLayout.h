//
//  SYPhotoBrowserLayout.h
//  SYPhotoVew
//
//  Created by SY on 17/9/17.
//  Copyright © 2017年 shenyue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYPhotoBrowserLayout : UICollectionViewFlowLayout
 /// 一页宽度，算上空隙
@property(nonatomic,assign) CGFloat pageWidth;
/// 上次页码
@property(nonatomic,assign) CGFloat lastPage;
/// 最小页码
@property(nonatomic,assign) CGFloat minPage;
/// 最大页码
@property(nonatomic,assign) CGFloat maxPage;
@end
