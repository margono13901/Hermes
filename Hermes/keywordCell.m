//
//  keywordCell.m
//  Hermes
//
//  Created by Raylen Margono on 5/8/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import "keywordCell.h"

@implementation keywordCell

- (void)awakeFromNib {
    // Initialization code
    self.rankingText.font = [UIFont fontWithName:@"SackersGothicLightAT" size:14 ];
    self.wordText.font = [UIFont fontWithName:@"SackersGothicLightAT" size:14 ];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
