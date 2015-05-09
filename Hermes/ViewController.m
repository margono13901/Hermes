//
//  ViewController.m
//  Hermes
//
//  Created by Raylen Margono on 3/20/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [projectColor returnColor];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    [self.password resignFirstResponder];
    [self.username resignFirstResponder];
    
}


- (IBAction)login:(id)sender {
    [PFUser logInWithUsernameInBackground:self.username.text password:self.password.text block:
     ^(PFUser *user, NSError *error) {
         if (user) {
             UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
             UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"mapView"];
             UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:viewController];
             [self presentViewController:nav animated:YES completion:^{
                 NSLog(@"success");
             }];
             
         }else{
             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Ooops!" message:[NSString stringWithFormat:@"%@",error.userInfo[@"error"]]  delegate:self cancelButtonTitle:@"Ok!" otherButtonTitles:nil];
             [alert show];
         }
     }];
    
}

@end
