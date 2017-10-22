//
//  PhotoBrowserDefaultPageControlDelegate.h
//  SYPhotoVew
//
//  Created by SY on 17/9/17.
//  Copyright © 2017年 shenyue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYPhotoBrowser.h"
@interface PhotoBrowserDefaultPageControlDelegate : NSObject <PhotoBrowserPageControlDelegate>
@property(nonatomic,assign) NSInteger numberOfPages;
-(instancetype)initWithnumberOfPages:(NSInteger)numberOfPages;
@end
