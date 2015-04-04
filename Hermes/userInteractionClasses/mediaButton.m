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
    self = [super initWithFrame:CGRectMake(0, 0, 40, 20)];
    
    if (self){
        self.queue = queue;
        UILabel *label = [[UILabel alloc]initWithFrame:self.frame];
        label.text = @"View";
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor redColor];
        label.textColor = [UIColor whiteColor];
        label.layer.cornerRadius = 30;
        [self addSubview:label];

    }
    return self;
}
@end
