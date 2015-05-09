//
//  AppDelegate.m
//  Hermes
//
//  Created by Raylen Margono on 3/20/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Parse setApplicationId:parseApplicationId
                  clientKey:parseClientId];

    //setup Push
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
   
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:                    userNotificationTypes
                                            
                                                                             categories:nil];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    self.uberkit = [[UberKit alloc]initWithClientID:uberClientId ClientSecret:uberSecret RedirectURL:redirectURI ApplicationName:@"Hermes"];
    
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    [NSTimer scheduledTimerWithTimeInterval: 60.0*5
                                                  target: self
                                                selector:@selector(removeOldPosts:)
                                                userInfo: nil repeats:YES];
    
    [self setUp];
    [self setUpLocation];
    return YES;
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    self.deviceToken = deviceToken;
    if ([PFUser currentUser]) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation setDeviceTokenFromData:self.deviceToken];
        currentInstallation.channels = @[ @"global" ];
        [currentInstallation setObject: [PFUser currentUser] forKey: @"owner"];
        [currentInstallation saveInBackground];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if ( application.applicationState == UIApplicationStateActive ){
        // app was already in the foreground
        if ([PFUser currentUser]) {
            NSDictionary *payload = [userInfo objectForKey:@"custom"];
            NSString *senderId = [payload objectForKey:@"senderId"];
            BOOL isUser = [senderId isEqual:[PFUser currentUser].objectId];
            NSString *type = [payload objectForKey:@"type"];
            NSLog(@"payload contents: %@" , payload);
            
            if ([type isEqualToString:@"post"]) {
                [self recievePost:payload isUser:isUser];
            }
            else if([type isEqualToString:@"friendRequest"]){
                [self recieveFriendRequest:payload];
            }else if([type isEqualToString:@"friendAccept"]){
                [self acceptFriendRequest:payload];
            }
            else if([type isEqualToString:@"goThere"]){
                [self recieveGoThere:payload];
            }else if([type isEqualToString:@"like"]){
                [self recieveLike:payload];
            }
            
        }

    }else{
        NSLog(@"hello");
    
    }
    
    
}

-(void)recieveGoThere:(NSDictionary *)payload{
    PFQuery *query = [PFQuery queryWithClassName:@"mediaPosts"];
    [query getObjectInBackgroundWithId:[payload objectForKey:@"post"] block:^(PFObject *object, NSError *error){
        if (object) {
            PFGeoPoint *g1 = object[@"location"];
            CLLocation *l1 = [[CLLocation alloc]initWithLatitude:[g1 latitude] longitude:[g1 longitude]];
            CLLocation *currentLocation = self.location;
            if ([l1 distanceFromLocation:currentLocation]<50) {
                [self displayBanner:[NSString stringWithFormat:@"%@ is joining you!",[payload objectForKey:@"senderUsername"]]];
                NSLog(@"going near user");
            }else{
                [self displayBanner:[NSString stringWithFormat:@"%@ is going to your post!",[payload objectForKey:@"senderUsername"]]];
                NSLog(@"going away from user");
            }
        }else{
            [self displayBanner:[NSString stringWithFormat:@"%@ is going to your post!",[payload objectForKey:@"senderUsername"]]];
            NSLog(@"%@",error);

        }
        
    }];
}

-(void)recieveLike:(NSDictionary *)payload{
    [self displayBanner:[NSString stringWithFormat:@"%@ likes one of your posts!",[payload objectForKey:@"senderUsername"]]];
}

-(void)recievePost:(NSDictionary *)payload isUser:(BOOL)user{
    
    NSString *objectID = [payload objectForKey:@"postId"];
    self.incomingPostId = objectID;
    NSLog(@"this is hte post id %@",objectID);
    if (!user) {
        NSString *sender = [payload objectForKey:@"sender"];
        [self displayBanner:[NSString stringWithFormat:@"New Post By %@",sender]];
    }else{
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        if (currentInstallation.badge != 0) {
            currentInstallation.badge -=1;
            [currentInstallation saveEventually];
        }
        [self displayBanner:[NSString stringWithFormat:@"Post Uploaded"]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"incomingPost" object:nil];

}

-(void)recieveFriendRequest:(NSDictionary *)payload{
    NSString *sender = [payload objectForKey:@"sender"];
    [self displayBanner:[NSString stringWithFormat:@"Friend request by %@",sender]];
}

-(void)acceptFriendRequest:(NSDictionary *)payload{
    NSString *sender = [payload objectForKey:@"sender"];
    [self displayBanner:[NSString stringWithFormat:@"%@ is now your friend!",sender]];
}

-(void)displayBanner:(NSString *)text{
    UIView *alertview = [[UIView alloc] initWithFrame:CGRectMake(0, -100, CGRectGetWidth(self.window.bounds), 50)];
    
    //Create a label to display the message and add it to the alertView
    UILabel *theMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(alertview.bounds), CGRectGetHeight(alertview.bounds))];
    theMessage.text = text;
    theMessage.textAlignment= NSTextAlignmentCenter;
    theMessage.backgroundColor = [UIColor purpleColor];
    theMessage.textColor = [UIColor whiteColor];
    [alertview addSubview:theMessage];
    
    //Add the alertView to your view
    [self.window addSubview:alertview];
    
    //Animate it in
    [self showBanner:alertview];
}

-(void)showBanner:(UIView *)alertview{
    CGRect newFrm = alertview.frame;
    newFrm.origin.y = 0;
    [UIView animateWithDuration:1.0f animations:^{
        alertview.frame = newFrm;
    } completion:^(BOOL finished) {
        [self hideBanner:alertview];
    }];

}

-(void)hideBanner:(UIView *)alertview{
    CGRect endFrm = alertview.frame;
    endFrm.origin.y = -100;
    [UIView animateWithDuration:1.0f
                          delay:3.0f
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         alertview.frame = endFrm;
                     }
                     completion:^(BOOL finished){
                     }];

}

-(void)setUpLocation{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation * newLocation = [locations lastObject];
    self.location = newLocation;
}



-(void)setUp{
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.center = CGPointMake(self.window.center.x,400);
        
        [self.window addSubview:spinner];
        [self.window bringSubviewToFront:spinner];
        [spinner startAnimating];
        
        // parsing code code
       
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController;
    if (![PFUser currentUser]) {
        viewController = [storyboard instantiateViewControllerWithIdentifier:@"loginView"];
    }else{
        viewController = [storyboard instantiateViewControllerWithIdentifier:@"mapView"];
    }
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:viewController];
    self.window.rootViewController = nav;
}

-(void)removeOldPosts:(id)sender{
    NSDate *yesterday = [[NSDate date] dateByAddingTimeInterval:60*60*24*-1];
    NSArray *keys =[self.unseenPostCenter allKeys];
    for (NSString *key in keys) {
        NSMutableArray *posts = [self.unseenPostCenter objectForKey:key];
        for (PFObject *post in posts) {
            NSDate *postDate = post[@"createdAt"];
            if ([postDate compare:yesterday]==NSOrderedAscending) {
                [posts removeObject:postDate];
            }
        }
        [self.unseenPostCenter setObject:posts forKey:key];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh" object:nil];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSLog(@"Calling Application Bundle ID: %@", sourceApplication);
    NSLog(@"URL scheme:%@", [url scheme]);
    NSLog(@"URL query: %@", [url query]);
    [self uberKitSetUp:url];
    return YES;
}

-(void)uberKitSetUp:(NSURL *)url{
    NSString* verifier = nil;
    NSArray* urlParams = [[url query] componentsSeparatedByString:@"&"];
    for (NSString* param in urlParams) {
        NSArray* keyValue = [param componentsSeparatedByString:@"="];
        NSString* key = [keyValue objectAtIndex:0];
        if ([key isEqualToString:@"code"]) {
            verifier = [keyValue objectAtIndex:1];
            NSLog(@"%@",verifier);
            [self.uberkit setUpAccessTokenWithCode:verifier];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:self.uberkit.authDictionary forKey:@"uberInformation"];
            [defaults synchronize];
        }
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
   [[NSNotificationCenter defaultCenter] postNotificationName:@"reopenApp" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
