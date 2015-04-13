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
        self.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];;
        [self initialization];
    }
    return self;
}

-(void)initialization{
    self.previewText = [[UILabel alloc]initWithFrame:CGRectMake(280, 30, 40, 50)];
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
    [self addSubview:self.previewText];
    [self addSubview:backButton];
    [self cycleThroughPost:self];
}

//work on this
-(void)cycleThroughPost:(id)sender{
    if ([self.previewQueue isEmpty]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh" object:nil];
        [self exitView:self];
    }else{
        self.previewText.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.previewQueue.storage.count];

        PFObject *post = [self.previewQueue dequeue];
        [self setUpImage:post];
        PFUser *author = post[@"author"];
        NSMutableArray *authorUnseenPosts = [self.delegate.unseenPostCenter objectForKey:author.objectId];
        for (int i = 0 ; i<authorUnseenPosts.count; i++) {
            PFObject *unseenPost = [authorUnseenPosts objectAtIndex:i];
            [self removeUnSeenPost:unseenPost withCompareTo:post :authorUnseenPosts];
        }
        
        [self.delegate.unseenPostCenter setValue:authorUnseenPosts forKey:author.objectId];
    }
}

-(void)exitView:(id)sender{
    [self removeFromSuperview];

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
