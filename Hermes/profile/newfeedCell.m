//
//  newfeedCell.m
//  Hermes
//
//  Created by Raylen Margono on 4/30/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import "newfeedCell.h"

@implementation newfeedCell

- (void)awakeFromNib {
    // Initialization code
    self.activityText.font = [UIFont fontWithName:@"SackersGothicLightAT" size:12];
    self.userPicture.layer.cornerRadius = 25;
    self.userPicture.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
