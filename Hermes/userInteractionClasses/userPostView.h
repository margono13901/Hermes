//
//  userPostView.h
//  Hermes
//
//  Created by Raylen Margono on 3/31/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSQueue.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "MBProgressHUD.h"

@interface userPostView : UIImageView

@property(strong,nonatomic)UILabel *previewText;
@property(strong,nonatomic)NSQueue *previewQueue;
@property(strong,nonatomic)AppDelegate *delegate;
@property(strong,nonatomic)UIButton *likeButton;
@property(strong,nonatomic)PFObject *currentPost;
-(id)initWithFrame:(CGRect)frame withQueue:(NSQueue *)queue;

@end
