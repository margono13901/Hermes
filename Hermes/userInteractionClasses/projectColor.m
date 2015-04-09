//
//  projectColor.m
//  Hermes
//
//  Created by Raylen Margono on 4/2/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import "projectColor.h"

@implementation projectColor
+(id)returnColor{
    float red = 29.0f/255.0f;
    float green = 202.0f/255.0f;
    float blue = 255.0f/255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f ];
}
+(id)returnDarkerColor{
    float red = 92.0f/255.0f;
    float green = 222.0f/255.0f;
    float blue = 237.0f/255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f ];

}
@end
