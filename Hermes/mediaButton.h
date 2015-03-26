//
//  mediaButton.h
//  Hermes
//
//  Created by Raylen Margono on 3/21/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface mediaButton : UIButton

@property(nonatomic,strong) PFFile *media;

@end
