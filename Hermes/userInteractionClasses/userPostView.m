//
//  userPostView.m
//  Hermes
//
//  Created by Raylen Margono on 3/31/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import "userPostView.h"

@implementation userPostView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame withQueue:(NSQueue *)queue{
    self = [super initWithFrame:frame];
    self.previewQueue = queue;
    if (self) {
        self.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [self initialization];
    }
    
    return self;
}

-(void)initialization{
    self.previewText = [[UILabel alloc]initWithFrame:CGRectMake(self.layer.bounds.size.width-50, 30, 40, 50)];
    self.previewText.textAlignment = NSTextAlignmentCenter;
    self.previewText.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5f];
    [self.previewText.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.previewText.layer setBorderWidth:2.0f];
    self.previewText.textColor = [UIColor whiteColor];
    self.previewText.layer.cornerRadius = 10;
    self.previewText.clipsToBounds = YES;
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(cycleThroughPost:)];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    [self addGestureRecognizer:singleFingerTap];
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 30, 50, 50)];
    [backButton setTitle:@"X" forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton addTarget:self action:@selector(exitView:) forControlEvents:UIControlEventTouchUpInside];
    backButton.titleLabel.font = [UIFont systemFontOfSize:23.0f];
    self.likeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
    self.likeButton.center = CGPointMake(self.center.x, self.frame.size.height-80);
    self.likeButton.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6f];
    self.likeButton.layer.cornerRadius = 30;
    self.likeButton.clipsToBounds = YES;
    [self.likeButton addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.likeButton];
    self.currentUserPhoto = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 70, 70)];
    self.currentUserPhoto.center = CGPointMake(self.center.x, 55);
    self.currentUserPhoto.clipsToBounds= YES;
    self.currentUserPhoto.layer.cornerRadius = 35;
    self.currentUserPhoto.layer.borderColor = [UIColor whiteColor].CGColor;
    self.currentUserPhoto.layer.borderWidth = 5;
    [self addSubview:self.currentUserPhoto];
    [self addSubview:self.previewText];
    [self addSubview:backButton];
    [self cycleThroughPost:self];
}

-(void)cycleThroughPost:(id)sender{
    if ([self.previewQueue isEmpty]){
        [self exitView:self];
    }else{
        
        if (![(PFUser *)((PFObject *)self.previewQueue.peek[@"author"]).objectId isEqual:[PFUser currentUser].objectId]) {
            self.likeButton.hidden = NO;
            [self setUpLike:[self.previewQueue peek]];
        }else{
            self.likeButton.hidden = YES;
        }
        self.currentPost = [self.previewQueue dequeue];
        [self setUpImage:self.currentPost];
        self.previewText.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.previewQueue.storage.count+1];
        PFUser *author = self.currentPost[@"author"];
        [author[@"profilePhoto"]getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            self.currentUserPhoto.image = [[UIImage alloc]initWithData:data];
        }];
        
        NSMutableArray *authorUnseenPosts = [self.delegate.unseenPostCenter objectForKey:author.objectId];
        for (int i = 0 ; i<authorUnseenPosts.count; i++) {
            PFObject *unseenPost = [authorUnseenPosts objectAtIndex:i];
            [self removeUnSeenPost:unseenPost withCompareTo:self.currentPost :authorUnseenPosts];
        }
        
        [self.delegate.unseenPostCenter setValue:authorUnseenPosts forKey:author.objectId];
    }
}

-(void)exitView:(id)sender{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh" object:nil];
    [self removeFromSuperview];
}

-(void)likeAction:(id)sender{
     if (![self.likeButton.currentTitle isEqual:@"liked"]) {
        PFRelation *relation = [[PFUser currentUser]relationForKey:@"likedPosts"];
        [relation addObject:self.currentPost];
        [[PFUser currentUser]saveInBackgroundWithBlock:^(BOOL success, NSError *error){
            if (success) {
                PFRelation *usersLiked = [self.currentPost relationForKey:@"usersLiked"];
                [usersLiked addObject:[PFUser currentUser]];
                [self.currentPost saveInBackground];
                [self.likeButton setImage:[UIImage imageNamed:@"likeFilled"] forState:UIControlStateNormal];
                [self.likeButton setTitle:@"liked" forState:UIControlStateNormal];
                PFObject *like = [PFObject objectWithClassName:@"likes"];
                like[@"mediaPost"] = self.currentPost;
                like[@"likeToUser"] = self.currentPost[@"author"];
                like[@"likeFromUser"] = [PFUser currentUser];
                [like saveInBackground];
            }
        }];
    }
}

-(void)setUpImage:(PFObject *)post{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.labelText = @"Loading";
    PFFile *mediaFile = post[@"media"];
    [mediaFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (data) {
            self.image = [UIImage imageWithData:[data zlibInflate]];
        }else{
            NSLog(@"%@",error);
        }
    }];
    [hud hide:NO];
}

-(void)setUpLike:(PFObject *)post{
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"likedPosts"];
    PFQuery *query = [relation query];
    [query whereKey:@"objectId" equalTo:post.objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        if (!error) {
            if (object) {
                [self.likeButton setImage:[UIImage imageNamed:@"likeFilled"] forState:UIControlStateNormal];
                [self.likeButton setTitle:@"liked" forState:UIControlStateNormal];
            }else{
                [self.likeButton setImage:[UIImage imageNamed:@"likeEmpty"] forState:UIControlStateNormal];
                [self.likeButton setTitle:@"empty" forState:UIControlStateNormal];
            }
        }else{
            NSLog(@"%@",error);
        }
    }];
}

-(void)removeUnSeenPost:(PFObject *)unseenpost withCompareTo:(PFObject *)post :(NSMutableArray *)authorUnseenPosts{
    if ([unseenpost.objectId isEqual:post.objectId]) {
        [authorUnseenPosts removeObject:unseenpost];
        PFRelation *relation = [[PFUser currentUser]relationForKey:@"unseenPosts"];
        [relation removeObject:unseenpost];
        [[PFUser currentUser]saveInBackground];
    }
}

@end
