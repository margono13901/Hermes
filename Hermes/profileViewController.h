//
//  profileViewController.h
//  Hermes
//
//  Created by Raylen Margono on 3/21/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "projectColor.h"
@interface profileViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)changeProfile:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *likes;
@property (strong, nonatomic) IBOutlet UITextField *uber;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;

@end
