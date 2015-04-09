//
//  mediaButton.m
//  Hermes
//
//  Created by Raylen Margono on 3/31/15.
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

-(id)initWithQueue:(NSQueue *)queue{
    self = [super initWithFrame:CGRectMake(0, 0, 26, 26)];
    
    
    if (self){
        self.queue = queue;
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"glasses"]];
        imageView.frame = self.frame;
        [self addSubview:imageView];

    }
    return self;
}

@end
