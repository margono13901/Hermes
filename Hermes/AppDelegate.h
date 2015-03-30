//
//  AppDelegate.h
//  Hermes
//
//  Created by Raylen Margono on 3/20/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "keys.h"
#import <Parse/Parse.h>
@class userInteractionView;

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) CLLocationManager *locationManager;
@property(strong,nonatomic) CLLocation *location;
@property(strong,nonatomic) NSMutableDictionary *friendUnseenPosts;
@property(strong,nonatomic) NSNumber *notifications;
@property(strong,nonatomic) userInteractionView *userInteractionView;
@property(strong,nonatomic) NSString *incomingPost;
@end

