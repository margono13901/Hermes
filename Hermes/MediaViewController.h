//
//  MediaViewController.h
//  Hermes
//
//  Created by Raylen Margono on 3/22/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIGridView.h"
#import <Parse/Parse.h>
#import "Cell.h"
#import "UIGridViewDelegate.h"
@interface MediaViewController : UIViewController<UIGridViewDelegate>
@property(strong,nonatomic)NSArray *userArray;

@property (strong, nonatomic) IBOutlet UIGridView *gridView;

@end
