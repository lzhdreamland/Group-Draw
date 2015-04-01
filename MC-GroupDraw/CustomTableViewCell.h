//
//  CustomTableViewCell.h
//  MC-GroupDraw
//
//  Created by ZihaoLin on 12/12/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell
@property (weak,nonatomic) IBOutlet UILabel *nameLabel;
@property (weak,nonatomic) IBOutlet UILabel *marksLabel;
@property (weak,nonatomic) IBOutlet UILabel *winLabel;
@property (weak,nonatomic) IBOutlet UILabel *ratesLabel;
@property (weak,nonatomic) IBOutlet UILabel *loseLabel;
@end
