//
//  mediaButton.h
//  Hermes
//
//  Created by Raylen Margono on 3/31/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSStack.h"

@interface mediaButton : UIView
@property(strong,nonatomic) NSStack *stack;
-(id)initWithStack:(NSStack *)stack;
@end
