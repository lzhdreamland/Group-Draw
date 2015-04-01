//
//  PathSampleView.m
//  MC-GroupDraw
//
//  Created by Steven Senger on 11/11/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

#import "PathSampleView.h"

@implementation PathSampleView
UIBezierPath * path;

- (void) createPath
{
  path = [UIBezierPath bezierPath];

  CGRect rect = CGRectInset(self.bounds, 10, 10);
  CGPoint strt = CGPointMake(rect.origin.x, rect.origin.y);
  CGPoint end = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
  CGPoint c1 = CGPointMake(rect.origin.x + 1.5 * rect.size.width, rect.origin.y);
  CGPoint c2 = CGPointMake(rect.origin.x - 0.5 * rect.size.width, rect.origin.y + rect.size.height);
  
  [path moveToPoint: strt];
  [path addCurveToPoint: end controlPoint1: c1 controlPoint2: c2];
}

- (void)drawRect:(CGRect)rect
{
  if (!path) [self createPath];
  
  [((UIColor *)self.settings[@"strokeColor"]) set];
  path.lineWidth = ((NSNumber *)self.settings[@"strokeWidth"]).doubleValue;
  [path stroke];
}


@end
