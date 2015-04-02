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

-(id)initWithFrame:(CGRect)frame withStack:(NSStack *)stack{
    self = [super initWithFrame:frame];
    self.previewStack = stack;
    if (self) {
        self.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];;
        [self initialization];
    }
    return self;
}

-(void)initialization{
    self.previewText = [[UILabel alloc]initWithFrame:CGRectMake(230, 30, 50, 50)];
    self.previewText.textAlignment = NSTextAlignmentCenter;
    self.previewText.textColor = [[UIColor blackColor]colorWithAlphaComponent:0.8f];
    [self.previewText.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.previewText.layer setBorderWidth:5.0f];
    self.previewText.textColor = [UIColor whiteColor];
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(cycleThroughPost:)];
    [self addGestureRecognizer:singleFingerTap];
    [self addSubview:self.previewText];
    [self cycleThroughPost:self];
}

//work on this
-(void)cycleThroughPost:(id)sender{
    if ([self.previewStack isEmpty]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh" object:nil];
        [self removeFromSuperview];
    }else{
        self.previewText.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.previewStack.storage.count];

        PFObject *post = [self.previewStack pop];
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

-(void)setUpImage:(PFObject *)post{
    [post[@"media"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *image = [UIImage imageWithData:data];
        self.image = image;
    }];
}

-(void)removeUnSeenPost:(PFObject *)unseenpost withCompareTo:(PFObject *)post :(NSMutableArray *)authorUnseenPosts{
    if ([unseenpost.objectId isEqual:post.objectId]) {
        [authorUnseenPosts removeObject:unseenpost];
        PFRelation *relation = [[PFUser currentUser]relationForKey:@"unseenPosts"];
        [relation removeObject:unseenpost];
        [self decrementBadge];
        [[PFUser currentUser]saveInBackground];
    }
}

-(void)decrementBadge{
        NSInteger numberOfBadges = [UIApplication sharedApplication].applicationIconBadgeNumber;
        numberOfBadges -=1;
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:numberOfBadges];
}

@end
