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
    friendRequest[@"status"] = @"pending";
    [friendRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.friendAddButton setTitle:@"Unfriend" forState:UIControlStateNormal];
    }];
}

-(void)unFriend{
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"friends"];
    PFQuery *query = [relation query];
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFUser *user in objects) {
            if ([user.objectId isEqual:self.user.objectId]) {
                [self removeFriend];
                return;
            }
        }
        [self removeFriendRequest];
    }];
}

-(void)removeFriend{
    [PFCloud callFunction:@"removeFriend" withParameters:@{
                                                           @"user": self.user
                                                           }];
    [self.friendAddButton setTitle:@"Friend" forState:UIControlStateNormal];

}

-(void)removeFriendRequest{
    [self.friendAddButton setTitle:@"Friend" forState:UIControlStateNormal];
    PFQuery *query = [PFQuery queryWithClassName:@"friendPending"];
    [query whereKey:@"sender" equalTo:[PFUser currentUser]];
    [query whereKey:@"recipient" equalTo:self.user];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *object = objects[0];
        object[@"status"] = @"deny";
        [object saveInBackground];
    }];
}

-(void)acceptFriendRequest{
    PFQuery *query = [PFQuery queryWithClassName:@"friendPending"];
    [query whereKey:@"sender" equalTo:self.user];
    [query whereKey:@"recipient" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *object = objects[0];
        object[@"status"] = @"accept";
        [object saveInBackground];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTable" object:nil];
    }];
    [PFCloud callFunction:@"friendAccept" withParameters:@{
                                                       @"user": self.user
                                                       }];
}
@end
