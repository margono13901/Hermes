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
    // Do any additional setup after loading the view, typically from a nib.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [projectColor returnColor];
}

-(void)dismissKeyboard {
    [self.passwordField resignFirstResponder];
    [self.usernameField resignFirstResponder];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    [PFUser logInWithUsernameInBackground:self.usernameField.text password:self.passwordField.text block:
     ^(PFUser *user, NSError *error) {
         if (!error) {
             UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
             UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"mapView"];
             UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:viewController];
             [self presentViewController:nav animated:YES completion:^{
                 NSLog(@"success");
             }];

         }else{
             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Ooops!" message:[NSString stringWithFormat:@"Oops: %@",error.localizedDescription]  delegate:self cancelButtonTitle:@"Ok!" otherButtonTitles:nil];
             [alert show];
         }
     }];
}
- (IBAction)signup:(id)sender {
    [self performSegueWithIdentifier:@"userLoginSegue" sender:self];
}

@end
