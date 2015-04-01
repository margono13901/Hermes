//
//  userPostView.h
//  Hermes
//
//  Created by Raylen Margono on 3/31/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSStack.h"
#import <Parse/Parse.h>

@interface userPostView : UIImageView

@property(strong,nonatomic)UILabel *previewText;
@property(strong,nonatomic)NSStack *previewStack;
@property(strong,nonatomic)NSDictionary *friendUnseenPosts;
-(id)initWithFrame:(CGRect)frame withStack:(NSStack *)stack;


@end
