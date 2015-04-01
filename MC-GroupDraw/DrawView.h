//
//  DrawView.h
//  MC-GroupDraw
//
//  Created by Steven Senger on 11/11/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Curve;

@interface DrawView : UIView
@property (strong,nonatomic) NSMutableArray * curveList;
@property (strong,nonatomic) Curve * currentCurve;
@end
