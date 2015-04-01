//
//  friendCollectionView.h
//  Hermes
//
//  Created by Raylen Margono on 3/29/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "CollectionViewCell.h"
#import "userInteractionView.h"

@interface friendCollectionView : UIView<UICollectionViewDataSource,UICollectionViewDelegate>
@property(strong,nonatomic)UICollectionView *collectionView;
@property(strong,nonatomic)UIImage *background;
@property(strong,nonatomic)NSMutableArray *users;
@property(strong,nonatomic)UIButton *friendButton;
@property(strong,nonatomic)NSMutableDictionary *friendUnseenPosts;
-(void)setUpFriendUnseenPost:(NSMutableDictionary *)dictionary;
@property(strong,nonatomic)PFUser *user;
@property(strong,nonatomic)UIImageView *blurMask;
-(void)reloadData;
@end
