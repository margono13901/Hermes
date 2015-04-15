//
//  registrationView.m
//  Hermes
//
//  Created by Raylen Margono on 4/2/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import "registrationView.h"

@interface registrationView ()

@end

@implementation registrationView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpPicture];
    [self setUpButton];
    [self reassignResponders];
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self reassignResponders];
}
-(void)reassignResponders{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGFloat y = textField.frame.origin.y;
    if (y >= 350) //not 380
    {
        CGRect frame = self.view.frame;
        frame.origin.y = 310 - textField.frame.origin.y;
        [UIView animateWithDuration:0.3 animations:^{self.view.frame = frame;}];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect returnframe =self.view.frame;
    returnframe.origin.y = 0;
    [UIView animateWithDuration:0.3 animations:^{self.view.frame = returnframe;}];
}

-(void)setUpPicture{
    self.profilePickView.userInteractionEnabled = YES;
    UITapGestureRecognizer *segue = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(openPictureCollection:)];
    [self.profilePickView addGestureRecognizer:segue];
    self.profilePickView.layer.cornerRadius = 40;
    self.profilePickView.clipsToBounds = YES;
    UIColor *color = [projectColor returnColor];
    self.profilePickView.layer.borderColor = color.CGColor;
    self.profilePickView.layer.borderWidth = 2.0f;
}

-(void)setUpButton{
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(registerForUser:)];
    self.navigationItem.rightBarButtonItem = anotherButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)registerForUser:(id)sender{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Registering";
    hud.detailsLabelText = @"Uploading Your Information";
    if (hasProfilePicture&&self.usernameField.text.length>5&&self.passwordField.text.length>5) {
        PFUser *user = [PFUser user];
        user.username = self.usernameField.text;
        user.password = self.passwordField.text;
    
        NSData *data = UIImagePNGRepresentation([self fixrotation:self.profilePickView.image]);
        PFFile *media = [PFFile fileWithName:@"picture" data:data];
        user[@"profilePhoto"] = media;
        user[@"points"] = @0;
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!error){
                AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];;
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation setDeviceTokenFromData:delegate.deviceToken];
                currentInstallation.channels = @[ @"global" ];
                [currentInstallation setObject: [PFUser currentUser] forKey: @"owner"];
                [currentInstallation saveInBackground];
                PFRelation *relation = [[PFUser currentUser]relationForKey:@"friends"];
                [relation addObject:[PFUser currentUser]];
                [[PFUser currentUser]saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                    UIAlertView *uberConnect = [[UIAlertView alloc]initWithTitle:@"Connect account with Uber?" message:@"Connect Your Account To Drive To Events On The Map!" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
                    uberConnect.tag = 1;
                    [hud hide:YES];
                    [uberConnect show];

                }];
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops" message:[NSString stringWithFormat:@"%@",error.userInfo[@"error"]] delegate:self cancelButtonTitle:@"Ok!" otherButtonTitles: nil];
                [alert show];
                [hud hide:YES];

            }
        }];
    }else{
        [hud hide:YES];
        UIAlertView *alert;
        if (hasProfilePicture) {
            alert =[[UIAlertView alloc]initWithTitle:@"Ooops" message:@"Username and Password has to be longer than 5 characters!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        }else{
             alert =[[UIAlertView alloc]initWithTitle:@"Choose photo" message:@"Choose a photo!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        }
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1) {
        if (buttonIndex ==0) {
            NSString *url = [NSString stringWithFormat:@"https://login.uber.com/oauth/authorize?response_type=code&client_id=%@",uberClientId];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            
            NSLog(@"user registers for uber");
        }
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"mapView"];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:viewController];
        [self presentViewController:nav animated:YES completion:^{
            NSLog(@"success");
        }];
    }
}

- (IBAction)openPictureCollection:(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *image = [[UIImage alloc]init];
    image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:^{
        hasProfilePicture = YES;
        self.profilePickView.image = image;
    }];
}

- (UIImage *)fixrotation:(UIImage *)image{
    
    
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.navigationController.navigationBar.hidden = NO;
}

- (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    double ratio;
    double delta;
    CGPoint offset;
    
    //make a new square size, that is the resized imaged width
    CGSize sz = CGSizeMake(newSize.width, newSize.width);
    
    //figure out if the picture is landscape or portrait, then
    //calculate scale factor and offset
    if (image.size.width > image.size.height) {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / image.size.height;
        delta = (ratio*image.size.height - ratio*image.size.width);
        offset = CGPointMake(0, delta/2);
    }
    
    //make the final clipping rect based on the calculated values
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * image.size.width) + delta,
                                 (ratio * image.size.height) + delta);
    
    
    //start a new context, with scale factor 0.0 so retina displays get
    //high quality image
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


@end
