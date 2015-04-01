//
//  DrawView.m
//  MC-GroupDraw
//
//  Created by Steven Senger on 11/11/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

#import "DrawView.h"
#import "Curve.h"

@implementation DrawView

- (void)drawRect:(CGRect)rect {
  [[UIColor whiteColor] set];
  UIRectFill(rect);
  
  [self.currentCurve draw];
  
  [self.curveList makeObjectsPerformSelector: @selector(draw)];
}

@end
