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
    [self addGestureRecognizer:singleFingerTap];
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 30, 50, 50)];
    [backButton setTitle:@"X" forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton addTarget:self action:@selector(exitView:) forControlEvents:UIControlEventTouchUpInside];
    backButton.titleLabel.font = [UIFont systemFontOfSize:23.0f];
    
    self.likeButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width/2-14, self.frame.size.height-80, 60, 60)];
    self.likeButton.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6f];
    self.likeButton.layer.cornerRadius = 30;
    self.likeButton.clipsToBounds = YES;
    [self.likeButton addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
    if (![(PFUser *)((PFObject *)self.previewQueue.peek[@"author"]).objectId isEqual:[PFUser currentUser].objectId]) {
        [self addSubview:self.likeButton];
        [self setUpLike:[self.previewQueue peek]];
    }
    [self addSubview:self.previewText];
    [self addSubview:backButton];
    [self cycleThroughPost:self];
}

//work on this
-(void)cycleThroughPost:(id)sender{
    if ([self.previewQueue isEmpty]){
        [self exitView:self];
    }else{
        self.previewText.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.previewQueue.storage.count];

        self.currentPost = [self.previewQueue dequeue];
        [self setUpImage:self.currentPost];
        PFUser *author = self.currentPost[@"author"];
        NSMutableArray *authorUnseenPosts = [self.delegate.unseenPostCenter objectForKey:author.objectId];
        for (int i = 0 ; i<authorUnseenPosts.count; i++) {
            PFObject *unseenPost = [authorUnseenPosts objectAtIndex:i];
            [self removeUnSeenPost:unseenPost withCompareTo:self.currentPost :authorUnseenPosts];
        }
        
        [self.delegate.unseenPostCenter setValue:authorUnseenPosts forKey:author.objectId];
    }
}

-(void)exitView:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh" object:nil];
    [self removeFromSuperview];
}

-(void)likeAction:(id)sender{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![[defaults objectForKey:@"firstTimeLike"]isEqual:@NO]) {
        [defaults setObject:@NO forKey:@"firstTimeLike"];
        [defaults synchronize];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Join Your Friend!" message:@"Pressing this button will tell your friends that your coming to their location and increase their leadership points!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
    
    else if (![self.likeButton.currentTitle isEqual:@"liked"]) {
        PFRelation *relation = [[PFUser currentUser]relationForKey:@"likedPosts"];
        [relation addObject:self.currentPost];
        [[PFUser currentUser]saveInBackgroundWithBlock:^(BOOL success, NSError *error){
            if (success) {
                [self.likeButton setImage:[UIImage imageNamed:@"likeFilled"] forState:UIControlStateNormal];
                [self.likeButton setTitle:@"liked" forState:UIControlStateNormal];
                PFObject *goThere = [PFObject objectWithClassName:@"goThere"];
                goThere[@"mediaPost"] = self.currentPost;
                goThere[@"goToUser"] = self.currentPost[@"author"];
                goThere[@"userGoing"] = [PFUser currentUser];
                [goThere saveInBackground];
            }
        }];
    }
}

-(void)setUpImage:(PFObject *)post{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.labelText = @"Loading";
    [post[@"media"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *image = [UIImage imageWithData:data];
        self.image = image;
        [hud hide:NO];
    }];
}

-(void)setUpLike:(PFObject *)post{
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"likedPosts"];
    PFQuery *query = [relation query];
    [query whereKey:@"objectId" equalTo:post.objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        if (object) {
            [self.likeButton setImage:[UIImage imageNamed:@"likeFilled"] forState:UIControlStateNormal];
            [self.likeButton setTitle:@"liked" forState:UIControlStateNormal];
        }else{
            [self.likeButton setImage:[UIImage imageNamed:@"likeEmpty"] forState:UIControlStateNormal];
            [self.likeButton setTitle:@"empty" forState:UIControlStateNormal];
        }
    }];
}

-(void)removeUnSeenPost:(PFObject *)unseenpost withCompareTo:(PFObject *)post :(NSMutableArray *)authorUnseenPosts{
    if ([unseenpost.objectId isEqual:post.objectId]) {
        [self decrementBadge];
        [authorUnseenPosts removeObject:unseenpost];
        PFRelation *relation = [[PFUser currentUser]relationForKey:@"unseenPosts"];
        [relation removeObject:unseenpost];
        [[PFUser currentUser]saveInBackground];
    }
}

-(void)decrementBadge{
        NSInteger numberOfBadges = [UIApplication sharedApplication].applicationIconBadgeNumber;
        numberOfBadges -=1;
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:numberOfBadges];
}

@end
