//
//  registrationView.h
//  Hermes
//
//  Created by Raylen Margono on 4/2/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "projectColor.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <CoreGraphics/CoreGraphics.h>

static bool hasProfilePicture = NO;

@interface registrationView : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIAlertViewDelegate,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *profilePickView;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@end
