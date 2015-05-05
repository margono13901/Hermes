//
//  mediaButton.h
//  Hermes
//
//  Created by Raylen Margono on 3/31/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSQueue.h"
#import "UIView+Glow.h"
#import <Parse/Parse.h>

@interface mediaButton : UIView
@property(strong,nonatomic) NSQueue *queue;
-(id)initWithQueue:(NSQueue *)queue;
-(id)initUberButton:(NSQueue *)queue;

@end
