//
//  CustomTableViewCell.m
//  MC-GroupDraw
//
//  Created by ZihaoLin on 12/12/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell
@synthesize nameLabel = _nameLabel;
@synthesize marksLabel = _marksLabel;
@synthesize winLabel = _winLabel;
@synthesize loseLabel = _loseLabel;
@synthesize ratesLabel = _ratesLabel;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
