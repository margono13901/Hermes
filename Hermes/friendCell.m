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
    if ([title isEqual:@"Unfriend"]) {
        [self unFriend];
    }
    else if([title isEqual:@"Friend"]){
        [self friend];
    }else{
        [self acceptFriendRequest];
    }
    [[PFUser currentUser] saveInBackground];
}

-(void)friend{
    PFObject *friendRequest = [PFObject objectWithClassName:@"friendRequests"];
    friendRequest[@"sender"] = [PFUser currentUser];
    friendRequest[@"recipient"] = self.user;
    //friendRequest[@"status"] = @"pending";
    [friendRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.friendAddButton setTitle:@"Unfriend" forState:UIControlStateNormal];
    }];
}

-(void)unFriend{
    PFObject *deleteFriend = [PFObject objectWithClassName:@"deleteFriend"];
    deleteFriend[@"sender"] = [PFUser currentUser];
    deleteFriend[@"recipient"] = self.user;
    [deleteFriend saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.friendAddButton setTitle:@"Friend" forState:UIControlStateNormal];

    }];
   // [self removeFriendRequest];
}

-(void)acceptFriendRequest{

    PFObject *acceptFriend = [PFObject objectWithClassName:@"acceptFriend"];
    acceptFriend[@"sender"] = [PFUser currentUser];
    acceptFriend[@"recipient"] = self.user;
    [acceptFriend saveInBackground];
}
@end
