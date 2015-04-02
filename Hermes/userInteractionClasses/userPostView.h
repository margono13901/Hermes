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
#import "AppDelegate.h"

@interface userPostView : UIImageView

@property(strong,nonatomic)UILabel *previewText;
@property(strong,nonatomic)NSStack *previewStack;
-(id)initWithFrame:(CGRect)frame withStack:(NSStack *)stack;
@property(strong,nonatomic)AppDelegate *delegate;

@end
