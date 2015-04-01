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
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    [self setUp];
    [self setUpLocation];
    return YES;
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    if([PFUser currentUser]){
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation setDeviceTokenFromData:deviceToken];
        currentInstallation.channels = @[ @"global" ];
        [currentInstallation setObject: [PFUser currentUser] forKey: @"owner"];
        [currentInstallation saveInBackground];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if ([PFUser currentUser]) {
        NSDictionary *payload = [userInfo objectForKey:@"custom"];
        NSString *senderId = [payload objectForKey:@"senderId"];
        
        if (![senderId isEqual:[PFUser currentUser].objectId]) {
            NSString *type = [payload objectForKey:@"type"];
            if ([type isEqualToString:@"post"]) {
                [self recievePost:payload];
            }
        }


    }
}

-(void)increamentBadge{
    NSInteger numberOfBadges = [UIApplication sharedApplication].applicationIconBadgeNumber;
    numberOfBadges +=1;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:numberOfBadges];
}

-(void)recievePost:(NSDictionary *)payload{
    [self increamentBadge];
    NSString *sender = [payload objectForKey:@"sender"];
    [self displayBanner:[NSString stringWithFormat:@"New Post By %@",sender]];
    PFObject *temp = [payload objectForKey:@"post"];
    NSString *objectID = [temp objectForKey:@"objectId"];
    self.incomingPost = objectID;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"incomingPost" object:nil];
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
    
    //Create the ending frame or where you want it to end up on screen, in this case 0 y origin
    CGRect newFrm = alertview.frame;
    newFrm.origin.y = 0;
    
    //Animate it in
    
    [UIView animateWithDuration:1.0f animations:^{
        alertview.frame = newFrm;
    } completion:^(BOOL finished) {
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
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
