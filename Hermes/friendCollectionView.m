//
//  friendCollectionView.m
//  Hermes
//
//  Created by Raylen Margono on 3/29/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import "friendCollectionView.h"

@implementation friendCollectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [self initialization];
        self.frame = CGRectMake(0, -800, self.bounds.size.width, self.bounds.size.height);
    }
    
    return self;
}

-(void)initialization{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    CGRect aRect = CGRectMake(0, 100, screenHeight-10, screenWidth);
    //setup collectionview
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    //add blurredView
    self.blurMask = [[UIImageView alloc]initWithFrame:self.frame];
    //set up friendlabels
    UITextField *friendText = [[UITextField alloc]initWithFrame:CGRectMake(self.frame.size.width/2-42, 20, 100, 100)];
    friendText.text = @"Friends";
    friendText.textAlignment = NSTextAlignmentCenter;
    [friendText setFont:[UIFont boldSystemFontOfSize:25]];
    [friendText setEnabled:NO];
    friendText.backgroundColor = [UIColor clearColor];
    [friendText setTextColor:[UIColor blackColor]];
    //set up friend button
    self.friendButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width-80, 45, 50, 50)];
    [self.friendButton setTitle:@"+" forState:UIControlStateNormal];
    [self.friendButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.friendButton.titleLabel setFont:[UIFont boldSystemFontOfSize:25]];
    [self.friendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.friendButton addTarget:self action:@selector(segueToFriendSearch:) forControlEvents:UIControlEventTouchUpInside];

    //setup collectionview
    _collectionView=[[UICollectionView alloc] initWithFrame:aRect collectionViewLayout:layout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [_collectionView setBackgroundColor:[UIColor clearColor] ];
    [self addSubview:self.blurMask];
    [self addSubview:self.collectionView];
    [self addSubview:friendText];
    [self addSubview:self.friendButton];
    [self getFriends];

}

-(void)getFriends{
    //query all of users friends
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"friends"];
    PFQuery *query = [relation query];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        NSMutableArray *temp = [[NSMutableArray alloc]init];
//        //iterate through all friends
//        //see if friends have user as part of their friend list
//        for (PFUser *user in objects) {
//            PFRelation *relation = [user relationForKey:@"friends"];
//            PFQuery *query = [relation query];
//            [query getObjectInBackgroundWithId:[PFUser currentUser].objectId block:^(PFObject *object, NSError *error) {
//                //if found then add friend to array
//                if (object) {
//                    [temp addObject:user];
//                    [self.collectionView reloadData];
//                }
//            }];
//        }
        self.users = [[NSMutableArray alloc]initWithArray:objects];
        [self.collectionView reloadData];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.users.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    CollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    PFUser *user = [self.users objectAtIndex:indexPath.row];
    [user[@"profilePhoto"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            // image can now be set on a UIImageView
            cell.imageView.image = image;
            NSMutableArray *array = [self.delegate.unseenPostCenter objectForKey:user.objectId];
            if (array.count>0) {
                cell.newPostField.hidden= NO;
                NSMutableArray *temp = [self.delegate.unseenPostCenter objectForKey:user.objectId];
                cell.newPostField.text = [NSString stringWithFormat:@"%lu",(unsigned long)temp.count];
            }
            
        }
    }];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(100, 100);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.frame = CGRectMake(0, -800, self.bounds.size.width, self.bounds.size.height);
    }completion:^(BOOL finished) {
        PFUser *user = self.users[indexPath.row];
        self.user = user;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newUser" object:nil];
    }];
   

}

-(PFUser *)returnSelectedUser:(PFUser *)user{
    return self.user;
}

-(void)reloadData{
    [self.collectionView reloadData];
}

-(void)segueToFriendSearch:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"segueToFriendSearch" object:nil];
}

-(void)moveToView:(id)sender{
    
    self.blurMask.image = (UIImage *)sender;
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    }completion:^(BOOL finished) {
        NSLog(@"Animation is complete");
    }];
}


@end
