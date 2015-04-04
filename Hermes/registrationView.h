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

static bool hasProfilePicture = NO;

@interface registrationView : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *profilePickView;

@property(strong,nonatomic) NSString *username;
@property(strong,nonatomic) NSString *password;

@end
