//
//  ViewController.h
//  Hermes
//
//  Created by Raylen Margono on 3/20/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "registrationView.h"
#import <UberKit/UberKit.h>
@interface ViewController : UIViewController<UberKitDelegate>
@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *password;
- (IBAction)login:(id)sender;

@end

