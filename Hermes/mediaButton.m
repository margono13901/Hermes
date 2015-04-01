//
//  mediaButton.m
//  Hermes
//
//  Created by Raylen Margono on 3/21/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import "mediaButton.h"

@implementation mediaButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)buttonWithType:(UIButtonType)buttonType :(NSStack *)stack{
    mediaButton *button = [super buttonWithType:buttonType];
    [button selfInit];
    return button;
}

-(void)selfInit{
    [self setTitle:@"!" forState:UIControlStateNormal];
}


@end
