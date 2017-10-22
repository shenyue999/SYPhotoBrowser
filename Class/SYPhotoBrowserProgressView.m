//
//  PhotoBrowserProgressView.m
//  SYPhotoVew
//
//  Created by SY on 17/9/17.
//  Copyright © 2017年 shenyue. All rights reserved.
//

#import "SYPhotoBrowserProgressView.h"

@interface SYPhotoBrowserProgressView ()
/// 外边界
@property(nonatomic,strong) CAShapeLayer *circleLayer;
/// 扇形区
@property(nonatomic,strong) CAShapeLayer *fanshapedLayer;
@end

@implementation SYPhotoBrowserProgressView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        if (CGRectEqualToRect(frame, CGRectZero)) {
            self.frame = CGRectMake(0, 0, 50, 50);
        }
        [self setupUI];
        self.progress = 0;
    }
    return self;
}
-(void)setupUI{
    self.backgroundColor = [UIColor clearColor];
    CGColorRef strokeColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;

    
    self.circleLayer = [CAShapeLayer new];
    self.circleLayer.strokeColor = strokeColor;
    self.circleLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleLayer.path = [self makeCirclePath].CGPath;
    [self.layer addSublayer:self.circleLayer];
    
    self.fanshapedLayer = [CAShapeLayer new];
    self.fanshapedLayer.fillColor = strokeColor;
    [self.layer addSublayer:self.fanshapedLayer];

}
-(UIBezierPath *)makeProgressPath:(CGFloat)progress{
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = CGRectGetMidY(self.bounds) - 2.5;
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:center];
    [path addLineToPoint:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))];
    [path addArcWithCenter:center radius:radius startAngle:-M_PI_2 endAngle:-M_PI_2 + M_PI*2*progress clockwise:YES];
   
    [path closePath];
    path.lineWidth = 1;
    return path;
}
-(UIBezierPath *)makeCirclePath{
    CGPoint arcCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:arcCenter radius:25 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    path.lineWidth = 2;
    return path;
}
-(void)setProgress:(CGFloat)progress{
    _progress = progress;
    self.fanshapedLayer.path =[self makeProgressPath:progress].CGPath;
    
}

@end
