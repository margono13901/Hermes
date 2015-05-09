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
#import "newfeedCell.h"
#import "ImageCropView.h"
#import "userPostView.h"
#import "NSData+Compression.h"

@interface profileViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource,ImageCropViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITextField *points;
@property (strong, nonatomic) IBOutlet UITextField *usertitle;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITableView *newsFeed;
@property (strong,nonatomic) NSArray *news;
@end
