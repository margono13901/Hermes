//
//  friendCell.h
//  Hermes
//
//  Created by Raylen Margono on 3/26/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface friendCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *friendPicturePreview;
@property (strong, nonatomic) IBOutlet UITextField *friendUsername;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
- (IBAction)friendAdd:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *friendAddButton;
@property(strong,nonatomic) PFUser *user;

@end
