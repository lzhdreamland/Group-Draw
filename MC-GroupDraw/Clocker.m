//
//  Clocker.m
//  MC-GroupDraw
//
//  Created by ZihaoLin on 12/5/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

#import "Clocker.h"

@interface Clocker() {
  float angle;
}

@end

@implementation Clocker


- (void)awakeFromNib{
  //self.initTime = 30;
  angle = 1.0;
  self.length = 5.0;
  self.speed = 0.8;
  self.clockwise = YES;
  self.time = [NSString stringWithFormat:@"%d",self.initTime];
}

- (void)update{
  angle = (self.clockwise) ? (angle + self.speed) : (angle - self.speed);
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
  CGRect bds = self.bounds;
  [[UIColor clearColor] set];
  [[UIBezierPath bezierPathWithRect: bds] fill];
  
  [[UIBezierPath bezierPathWithRect: CGRectInset(rect,2,2)] fill];
  NSString *displayTime = [NSString stringWithFormat:@"%d",self.initTime];
  NSString *name = @"Timer";
  [displayTime drawAtPoint: CGPointMake(rect.size.width/2-10,rect.size.height/2-12) withAttributes: @{NSFontAttributeName: [UIFont fontWithName:@"Noteworthy-Bold" size:15]}];
  [name drawAtPoint:CGPointMake(rect.origin.x+rect.size.width/2.0 - 17, rect.origin.y+2) withAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Noteworthy-Bold" size:15]}];
  
  UIBezierPath * rectPath = [UIBezierPath bezierPathWithRoundedRect: self.bounds byRoundingCorners: UIRectCornerAllCorners cornerRadii: CGSizeMake(20,20)];
  [[UIColor colorWithRed: 0.555 green: 0.97 blue: 0.88 alpha: 0.5] set];
  [rectPath fill];
  [[UIColor grayColor] set];
  [rectPath stroke];
  
  UIBezierPath * arcPath = [UIBezierPath bezierPath];
  [arcPath addArcWithCenter: CGPointMake(self.bounds.size.width/2.0,self.bounds.size.height/2.0) radius: 20
                 startAngle: angle - self.length endAngle: angle clockwise: YES];
  [[UIColor whiteColor] set];
  arcPath.lineWidth = 10;
  arcPath.lineCapStyle = kCGLineCapRound;
  [arcPath stroke];
}


@end
