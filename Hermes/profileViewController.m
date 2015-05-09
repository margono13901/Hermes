//
//  profileViewController.m
//  Hermes
//
//  Created by Raylen Margono on 3/21/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import "profileViewController.h"

@interface profileViewController ()

@end

@implementation profileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.newsFeed.delegate = self;
    self.newsFeed.dataSource = self;
    [self getActivity];
    
    self.navigationController.navigationItem.title = @"Profile";

    // Do any additional setup after loading the view
    [self.imageView.layer setCornerRadius:30.0f];
    
    // border
    UIColor *color = [projectColor returnColor];
    [self.imageView.layer setBorderColor:color.CGColor];
    [self.imageView.layer setBorderWidth:5.0f];
    
    // drop shadow
    [self.imageView.layer setShadowColor:[UIColor blueColor].CGColor];
    [self.imageView.layer setShadowOpacity:0.8];
    [self.imageView.layer setShadowRadius:3.0];
    [self.imageView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    //clip
    self.imageView.clipsToBounds = YES;
    self.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *changePhoto = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(changeProfile:)];
    [self.imageView addGestureRecognizer:changePhoto];
    
    self.usernameField.text = [PFUser currentUser][@"username"];
    self.usernameField.font = [UIFont fontWithName:@"SackersGothicLightAT" size:14 ];
    
    [[PFUser currentUser][@"profilePhoto"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            // image can now be set on a UIImageView
            self.imageView.image = image;
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [[PFUser currentUser]fetchInBackground];
    self.points.text =[NSString stringWithFormat:@"%@ likes",[PFUser currentUser][@"points"]];
    self.points.font = [UIFont fontWithName:@"SackersGothicLightAT" size:14 ];
    self.usertitle.text = @"Beginner";
    self.usertitle.font = [UIFont fontWithName:@"SackersGothicLightAT" size:14 ];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getActivity{
    PFQuery *likesQuery = [PFQuery queryWithClassName:@"likes"];
    [likesQuery whereKey:@"likeToUser" equalTo:[PFUser currentUser]];
    [likesQuery includeKey:@"mediaPost"];
    [likesQuery includeKey:@"likeFromUser"];
    [likesQuery orderByDescending:@"createdAt"];
    [likesQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error){
        if (!error) {
            NSArray *likes = results;
            PFQuery *goThereQuery = [PFQuery queryWithClassName:@"goThere"];
            [goThereQuery whereKey:@"goToUser" equalTo:[PFUser currentUser]];
            [goThereQuery includeKey:@"mediaPost"];
            [goThereQuery includeKey:@"userGoing"];
            [goThereQuery orderByDescending:@"createdAt"];
            [goThereQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error){
                if (!error) {
                    NSArray *goThere = results;
                    [self sortQuerieswithLikes:likes andgoThere:goThere];
                }
            }];
        }
    }];
}

-(void)sortQuerieswithLikes:(NSArray *)likes andgoThere:(NSArray *)goThere{
    
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        // Perform long running process
        NSMutableArray *results = [[NSMutableArray alloc]init];
        int likesCount = (int)likes.count;
        int goThereCount = (int)goThere.count;
        int likesIndex = 0;
        int goThereIndex = 0;
        
        while (likesIndex<likesCount && goThereIndex<goThereCount) {
            PFObject *like = likes[likesIndex];
            PFObject *goThereObject = goThere[goThereIndex];
            
            if ([like.createdAt compare:goThereObject.createdAt]==NSOrderedDescending) {
                [results addObject:like];
                likesIndex++;
            }else if ([like.createdAt compare:goThereObject.createdAt] == NSOrderedAscending){
                [results addObject:goThereObject];
                goThereIndex++;
            }else{
                [results addObject:like];
                likesIndex++;
                [results addObject:goThereObject];
                goThereIndex++;
            }
        }
        
        if (likesIndex<likesCount) {
            [results addObject:likes[likesIndex++]];
        }
        
        if (goThereIndex<goThereCount) {
            [results addObject:goThere[goThereIndex++]];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            self.news = results;
            [self.newsFeed reloadData];
        });
    });
   
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (void)changeProfile:(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.navigationBar.tintColor = [projectColor returnColor];
    imagePickerController.navigationBar.backgroundColor = [projectColor returnDarkerColor];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];

}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *image = [[UIImage alloc]init];
    image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self cropImage:image];
    [self dismissViewControllerAnimated:NO completion:^{
    }];
}

- (void)cropImage:(UIImage *)image{
    ImageCropViewController *controller = [[ImageCropViewController alloc] initWithImage:image];
    controller.delegate = self;
    [[self navigationController] pushViewController:controller animated:YES];
}

- (void)ImageCropViewController:(ImageCropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage{
    self.imageView.image = croppedImage;
    NSData *data = UIImageJPEGRepresentation([self fixrotation:croppedImage],0.7f);
    PFFile *media = [PFFile fileWithName:@"picture" data:data];
    PFUser *user = [PFUser currentUser];
    user[@"profilePhoto"] = media;
    [user saveInBackground];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeProfilePhoto" object:nil];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)ImageCropViewControllerDidCancel:(ImageCropViewController *)controller{
    [[self navigationController] popViewControllerAnimated:YES];
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.news.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifer = @"Cell";
    newfeedCell *cell = [self.newsFeed dequeueReusableCellWithIdentifier:identifer];
    if (cell == nil)
    {
        cell = [[newfeedCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:identifer];
    }
    PFObject *activity = self.news[indexPath.row];
    PFUser *sender;
    PFObject *photoFile;
    
    if ([activity.parseClassName isEqual:@"likes"]) {
        sender = activity[@"likeFromUser"];
        cell.activityText.text = [NSString stringWithFormat:@"%@\n likes your post!",sender.username];
    }else{
        sender = activity[@"userGoing"];
        cell.activityText.text = [NSString stringWithFormat:@"%@\n is going to your post!",sender.username];
    }
    photoFile = activity[@"mediaPost"];
    
    [sender[@"profilePhoto"]getDataInBackgroundWithBlock:^(NSData *data,NSError *error){
        if(!error){
            cell.userPicture.image = [UIImage imageWithData:data];
        }
    }];
    [photoFile[@"media"]getDataInBackgroundWithBlock:^(NSData *data,NSError *error){
        if(!error){
            cell.photoActivity.image = [UIImage imageWithData:[data zlibInflate]];
        }
    }];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
