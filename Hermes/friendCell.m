//
//  friendCell.m
//  Hermes
//
//  Created by Raylen Margono on 3/26/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import "friendCell.h"

@implementation friendCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (IBAction)friendAdd:(id)sender {
    NSString *title = self.friendAddButton.titleLabel.text;
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"friends"];

    if ([title isEqual:@"Unfriend"]) {
        [relation removeObject:self.user];
        [self.friendAddButton setTitle:@"Friend" forState:UIControlStateNormal];
    }else{
        [relation addObject:self.user];
        [self.friendAddButton setTitle:@"Unfriend" forState:UIControlStateNormal];
    }
    [[PFUser currentUser] saveInBackground];
    
}
@end
