//
//  userInteractionView.m
//  Hermes
//
//  Created by Raylen Margono on 3/31/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import "userInteractionView.h"

@interface userInteractionView ()
@end

@implementation userInteractionView


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialization];
    [self setUpNotificationCenter];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBarHidden = YES;
}

#pragma refresh


-(void)setUpNotificationCenter{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incomingPost:) name:@"incomingPost" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(segueToFriendSearch:) name:@"segueToFriendSearch" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCurrentUser:) name:@"newUser" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:@"refresh" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUpProfilePhoto:) name:@"changeProfilePhoto" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reopenApp:) name:@"reopenApp" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchKeyWord:) name:@"searchKeyWord" object:nil];
}

-(void)changeCurrentUser:(id)sender{
    self.currentUserOnDisplay = self.friendPane.userArray;
    self.currentUserPhoto.hidden = YES;
    self.currentUserNameField.text = nil;
    [self getCurrentuserPosts];
    [self setUpAnnotations];
    self.locationView.text=@"";
    self.scrollThroughPicturesLabel.text = @"Swipe Through Pictures";
    self.currentAnnotation = nil;
}

-(void)reopenApp:(id)sender{
    [self downloadUnseenPosts];
    [self.friendPane getFriends];
}

-(void)refreshView:(id)sender{
    [self setUpNotificationCounter];
    [self setUpAnnotations];
    [self.friendPane getFriends];
}


-(void)getCurrentUserProfilePhoto:(PFUser *)user{
    [user[@"profilePhoto"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            CGSize scaleSize = CGSizeMake(100, 100);
            UIGraphicsBeginImageContextWithOptions(scaleSize, NO, 0.0);
            [image drawInRect:CGRectMake(0, 0, scaleSize.width, scaleSize.height)];
            UIImage * resized = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            self.currentUserPhoto.image = resized;
            self.currentUserPhoto.layer.cornerRadius = 45;
            self.currentUserPhoto.clipsToBounds = YES;
            self.currentUserPhoto.layer.borderColor = [UIColor whiteColor].CGColor;
            self.currentUserPhoto.layer.borderWidth = 5;
        }else{
            NSLog(@"%@",error);
        }
        
    }];
}

-(void)incomingPost:(id)sender{
    NSString *incomingPostId = self.delegate.incomingPostId;
    NSLog(@"this is the incoming post id %@",incomingPostId);
    PFQuery *query = [PFQuery queryWithClassName:@"mediaPosts"];
    [query includeKey:@"author"];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query getObjectInBackgroundWithId:incomingPostId block:^(PFObject *object, NSError *error) {
        if (!error) {
            PFUser *author = object[@"author"];
            if (![author.objectId isEqual:[PFUser currentUser].objectId]) {
                [self addToUnseenPostCenter:object];
            }
            for (PFUser *user in self.currentUserOnDisplay) {
                if ([author.objectId isEqual:user.objectId]) {
                    [self.currentUserPosts insertObject:object atIndex:0];
                    break;
                }
            }
            [self refreshView:self];
            NSLog(@"recieved post");
        }else{
            NSLog(@"%@",error);
        }
    }];
}

#pragma firstTimeSetups

-(void)initialization{
    //set up map box
    [[RMConfiguration sharedInstance] setAccessToken:mapAccessToken];
    RMMapboxSource *tileSource = [[RMMapboxSource alloc] initWithMapID:mapID];
    self.mapView.delegate = self;
    [self.mapView setTileSource:tileSource];
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = RMUserTrackingModeFollowWithHeading;
    [self.mapView setHideAttribution:YES];
    self.mapView.frame = self.view.frame;
    self.mapView.zoom = 15;
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = RMUserTrackingModeFollow;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        //display user
        self.currentUserOnDisplay = [[NSMutableArray alloc]init];
        PFRelation *relation = [[PFUser currentUser] relationForKey:@"friends"];
        PFQuery *query = [relation query];
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        [query findObjectsInBackgroundWithBlock:^(NSArray *array,NSError *error){
            self.currentUserOnDisplay =[[NSMutableArray alloc]initWithArray:array];
            //download posts
            [self downloadUnseenPosts];
        }];
        [self setUpProfilePhoto:[PFUser currentUser]];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            self.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            //set up nagivation contorller
            //self.navigationController.navigationBarHidden = YES;
            self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
            self.navigationController.navigationBar.barTintColor = [projectColor returnColor];
            self.navigationController.navigationBarHidden=YES;
            //set up friend pane
            self.friendPane = [[friendCollectionView alloc]initWithFrame:self.view.bounds];
            [self.view addSubview:self.friendPane];
            //set up profile pic interaction
            self.profileView.userInteractionEnabled = YES;
            UITapGestureRecognizer *segue = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(segueToProfile:)];
            [self.profileView addGestureRecognizer:segue];
            self.profileView.layer.cornerRadius = self.profileView.layer.bounds.size.width/2;
            self.profileView.clipsToBounds = YES;
            self.profileView.layer.borderColor = [[UIColor whiteColor]CGColor];
            self.profileView.layer.borderWidth = 2.0f;
            //set up container View
            self.optionContainers.backgroundColor = [[projectColor returnColor]colorWithAlphaComponent:1.0];
            self.bottomOptionContainer.backgroundColor = [UIColor whiteColor];
            self.bottomOptionContainer.layer.borderWidth = 2;
            UISwipeGestureRecognizer * swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(zoomToAnnotation:)];
            swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
            [self.bottomOptionContainer addGestureRecognizer:swipeleft];
            UISwipeGestureRecognizer * swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(zoomToAnnotationBack:)];
            swiperight.direction=UISwipeGestureRecognizerDirectionRight;
            [self.bottomOptionContainer addGestureRecognizer:swiperight];
            UIColor *color = [projectColor returnColor];
            self.bottomOptionContainer.layer.borderColor = color.CGColor;
            //scrolll through label setup
            self.scrollThroughPicturesLabel.font = [UIFont fontWithName:@"SackersGothicLightAT" size:10 ];
            //nameView
            self.currentUserNameField.font = [UIFont fontWithName:@"SackersGothicLightAT" size:10];
            self.currentUserNameField.textColor = [projectColor returnColor];
            //self.currentUserNameField.text = self.currentUserOnDisplay.username;
            //set up location view
            self.locationView.font =[UIFont fontWithName:@"SackersGothicLightAT" size:10 ];
            self.scrollThroughPicturesLabel.userInteractionEnabled= NO;
            //set up uber button
            UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayUber:)];
            [self.scrollThroughPicturesLabel addGestureRecognizer:gestureRecognizer];
            
        });
    });
}

-(void)setUpProfilePhoto:(id)sender{
    [[PFUser currentUser][@"profilePhoto"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if(data) self.profileView.image = [UIImage imageWithData:data];
        else [self setUpProfilePhoto:self];
    }];
}

-(void)downloadUnseenPosts{
    NSDate *yesterday = [[NSDate date] dateByAddingTimeInterval:60*60*24*-1];
    PFRelation *relation= [[PFUser currentUser]relationForKey:@"unseenPosts"];
    PFQuery *query = [relation query];
    [query includeKey:@"author"];
    [query whereKey:@"createdAt" greaterThan:yesterday];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.delegate.unseenPostCenter = [NSMutableDictionary dictionary];
        for (PFObject *posts in objects) {
            [posts[@"media"] getDataInBackground];
            [self addToUnseenPostCenter:posts];
        }
        [self setUpNotificationCounter];
        [self getCurrentuserPosts];
    }];
}

-(void)setUpNotificationCounter{
    int counter= 0;
    NSArray *keys = [self.delegate.unseenPostCenter allKeys];
    for (NSString *key in keys) {
        NSMutableArray *unSeenPosts = [self.delegate.unseenPostCenter objectForKey:key];
        counter += (int)unSeenPosts.count;
    }
    if (counter>0) {
        self.notifications.hidden = NO;
        self.notifications.text = [NSString stringWithFormat:@"%i",counter];
        [self.notifications startGlowing];
    }else{
        self.notifications.hidden = YES;
        [self.notifications stopGlowing];
    }
}

-(void)addToUnseenPostCenter:(PFObject *)post{
    NSString *author = ((PFUser *)post[@"author"]).objectId;
    NSMutableArray *unseenPosts;
    if ([self.delegate.unseenPostCenter objectForKey:author]){
         unseenPosts = [self.delegate.unseenPostCenter objectForKey:author];
    }else{
        unseenPosts = [[NSMutableArray alloc]init];
    }
    [unseenPosts addObject:post];
    [self.delegate.unseenPostCenter setObject:unseenPosts forKey:author];
}

-(void)getCurrentuserPosts{
    PFQuery *query = [PFQuery queryWithClassName:@"mediaPosts"];
    [query whereKey:@"author" containedIn:self.currentUserOnDisplay];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"author"];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    NSDate *oneDayAgo = [[NSDate date]dateByAddingTimeInterval:-60*60*24];
    [query whereKey:@"createdAt" greaterThan:oneDayAgo];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(objects.count==0){
            self.scrollThroughPicturesLabel.text = @"No Photos";
        }
        self.currentUserPosts = [[NSMutableArray alloc]initWithArray:objects];
        [self setUpAnnotations];
    }];
}

-(void)setUpAnnotations{
    [self.mapView removeAllAnnotations];
    self.annotationLink = [[annotationsLinkedList alloc]init];
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(backgroundQueue, ^(void){
        
        NSMutableArray *temp = [[NSMutableArray alloc]initWithArray:self.currentUserPosts];
        for (int i = 0 ; i < temp.count; i++) {
            int newPosts = 0;
            NSQueue *postQueue = [[NSQueue alloc]init];
            PFObject *post = [temp objectAtIndex:i];
            [postQueue enqueue:post];
            if ([self postIsUnseen:post]) newPosts++;
            
            int iterations = i+1;
            while (iterations < temp.count) {
                PFObject *comparedPost = [temp objectAtIndex:iterations];
                if ([userInteractionViewUtils distanceIsClose:post to:comparedPost]) {
                    [postQueue enqueue:comparedPost];
                    [temp removeObject:comparedPost];
                    if ([self postIsUnseen:comparedPost]) newPosts++;
                }else{
                    iterations++;
                }
            }
            CLLocation *location = [[CLLocation alloc]initWithLatitude:[post[@"location"] latitude] longitude:[post[@"location"] longitude]];
            
            NSString *displayText = [NSString stringWithFormat:@"%i New Posts",newPosts];
            
            RMAnnotation *annotation = [RMAnnotation annotationWithMapView:self.mapView coordinate:[location coordinate] andTitle:displayText];
            annotation.userInfo = postQueue;
            annotation.subtitle = [userInteractionViewUtils returnDateOfLatestAnnotation:annotation];

            [self addAnnotationToLink:annotation];

            dispatch_async(dispatch_get_main_queue(), ^(void)
                           {
                               [self.mapView addAnnotation:annotation];
                               [self zoomToFirstAnnotation];
                           });
        }
    });
}

-(void)addAnnotationToLink:(RMAnnotation *)annotatoin{
    if (!annotatoin.isUserLocationAnnotation) {
        [self.annotationLink addToLink:annotatoin];
    }
}

-(BOOL)postIsUnseen:(PFObject *)post{
    for (PFUser *user in self.currentUserOnDisplay) {
        NSMutableArray *unSeenPosts = [self.delegate.unseenPostCenter objectForKey:user.objectId];
        for (PFObject *objects in unSeenPosts) {
            if ([objects.objectId isEqual:post.objectId]) {
                return YES;
            }
        }
    }
    return NO;
}


-(RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation{
    if ([annotation isUserLocationAnnotation]) return nil;
    RMMapLayer *mapLayer;
    NSArray *stringArray = [annotation.title componentsSeparatedByString:@" "];
    NSInteger unSeenPosts = [stringArray[0] integerValue];
    if (unSeenPosts>0) {
        mapLayer = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"location"]];
    }else{
        mapLayer = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"locationseen"]];

    }
    mapLayer.bounds = CGRectMake(0, 0, 50, 50);
    mapLayer.canShowCallout = YES;
    
    mediaButton *button = [[mediaButton alloc]initWithQueue:annotation.userInfo];
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(displayMediaStack:)];
    [button addGestureRecognizer:singleFingerTap];
    mapLayer.rightCalloutAccessoryView = button;

    
    mediaButton *uberButton =[[mediaButton alloc]initUberButton:annotation.userInfo];
    UITapGestureRecognizer *st =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                        action:@selector(displayUber:)];
    [uberButton addGestureRecognizer:st];
    mapLayer.leftCalloutAccessoryView = uberButton;

    return mapLayer;
}

-(void)displayMediaStack:(UITapGestureRecognizer *)sender{
    mediaButton *button = (mediaButton *)sender.view;
    userPostView *media = [[userPostView alloc]initWithFrame:self.view.frame withQueue:button.queue];
    [self.view addSubview:media];
}

-(void)segueToFriendSearch:(id)sender{
    [self performSegueWithIdentifier:@"searchFriendsSegue" sender:self];
}

-(void)segueToProfile:(id)sender{
    [self performSegueWithIdentifier:@"profile" sender:self];
}

- (IBAction)camera:(id)sender {
    [self performSegueWithIdentifier:@"camera" sender:self];
}

- (IBAction)findFriends:(id)sender{
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        // Perform long running process
        UIImage *blurImage = [[userInteractionViewUtils getImageView:self.view] stackBlur:50];
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            [self.friendPane moveToView:blurImage];
        });
    });
}

- (void)zoomToAnnotation:(id)sender{
    if (self.annotationLink.storage.count>0) {
        RMAnnotation *annotation = [self.annotationLink scrollThroughAnnotatotation];
        [self selectAnnotation:annotation zoom:YES];
    }
}

- (void)zoomToAnnotationBack:(id)sender {
    if (self.annotationLink.storage.count>0) {
        RMAnnotation *annotation = [self.annotationLink scrollBackThroughAnnotatotation];
        [self selectAnnotation:annotation zoom:YES];
    }
}

- (void)zoomToFirstAnnotation{
    if (self.annotationLink.storage.count>0) {
        RMAnnotation *annotation = [self.annotationLink.storage objectAtIndex:0];
        [annotationsLinkedList changeToFirstPlacement];
        [self selectAnnotation:annotation zoom:YES];
    }
}

-(void)tapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    [self selectAnnotation:annotation zoom:NO];
}

-(void)selectAnnotation:(RMAnnotation *)annotation zoom:(BOOL)zoom{
    self.currentUserPhoto.hidden = NO;
    NSQueue *queue = annotation.userInfo;
    PFObject *object = queue.peek;
    PFUser *author = object[@"author"];
    [self getCurrentUserProfilePhoto:author];
    self.currentUserNameField.text = ((PFUser *)object[@"author"]).username;
    if (zoom) {
        [self didZoomWithAnnotation:annotation];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.mapView selectAnnotation:annotation animated:YES];
        });
    }
    self.currentAnnotation = annotation;
    
    CLLocationCoordinate2D coordinate = [annotation coordinate];
    double lat = coordinate.latitude;
    double lon = coordinate.longitude;
    CLLocation *postLocation = [[CLLocation alloc]initWithLatitude:lat longitude:lon];
    double distance = [postLocation distanceFromLocation:self.mapView.userLocation.location];
    self.scrollThroughPicturesLabel.text = [self distanceString:distance];
    [userInteractionViewUtils getGeoCodingInformationWithLat:coordinate.latitude withLon:coordinate.longitude withLocationView:self.locationView];
     [userInteractionViewUtils getPlaceName:coordinate.latitude withLon:coordinate.longitude withUserView:self.currentUserNameField];
}

-(NSString *)distanceString:(double)distance{
    if(distance<1){
        return @"Here";
    }
    else if (distance<1000) {
        return [NSString stringWithFormat: @"%i meters away",(int)distance];
    }else{
        return [NSString stringWithFormat: @"%i km away",(int)distance/1000];
    }
}

- (void)displayUber:(UITapGestureRecognizer*)sender{
    GPUberViewController *uber = [[GPUberViewController alloc] initWithServerToken:uberClientServerToken];
    // optional
    mediaButton *button = (mediaButton *)sender.view;
    PFObject *post = [button.queue peek];
    PFGeoPoint *g1 = post[@"location"];
    CLLocation *l1 = [[CLLocation alloc]initWithLatitude:[g1 latitude] longitude:[g1 longitude]];
    if (self.annotationLink.storage.count>0) {
        uber.startLocation = self.mapView.userLocation.location.coordinate;
        uber.endLocation = [l1 coordinate];
        [uber showInViewController:self];
    }
    NSMutableArray *temp = [[NSMutableArray alloc]init];
    for (int i = 0 ; i < button.queue.storage.count; i++) {
        PFObject *post =[button.queue.storage objectAtIndex:0];
        if (![temp containsObject:((PFUser *)post[@"author"]).objectId] && ![((PFUser *)post[@"author"]).objectId isEqual:[PFUser currentUser].objectId]) {
            [temp addObject:post];
        }
    }
    for (PFObject *post in temp) {
        [self sendGoThere:post];
    }
}

-(void)sendGoThere:(PFObject *)post{
    PFObject *goThere = [PFObject objectWithClassName:@"goThere"];
    goThere[@"goToUser"] = post[@"author"];
    goThere[@"userGoing"] = [PFUser currentUser];
    goThere[@"mediaPost"] = post;
    [goThere saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSDictionary *data = @{
                                   @"alert" : [NSString stringWithFormat:@"%@ is going to one of your posts!",[PFUser currentUser].username],
                                   @"custom" : @{@"type":@"goThere",
                                                 @"sender":[PFUser currentUser].username,
                                                 @"senderId":[PFUser currentUser].objectId,
                                                 @"postId":post.objectId
                                                 }
                                   };
            PFQuery *pushQuery = [PFInstallation query];
            
            // if you would like to send a notification to one user
            [pushQuery whereKey: @"owner" equalTo: post[@"author"]];
            PFPush *push = [PFPush new];
            [push setQuery: pushQuery];
            [push setData:data];
            [push setQuery:pushQuery];
            [push sendPushInBackground];
        }else{
            NSLog(@"%@",error.description);
        }
    }];
}

-(void)didZoomWithAnnotation:(RMAnnotation *)annotation{
    //do stuff
    [self.mapView setZoom:15 atCoordinate:annotation.coordinate animated:YES];

}

- (void)searchKeyWord:(NSNotification *)sender {
    NSString *result = sender.object;
    [self searchForKeyWordPosts:result];
}

-(void)searchForKeyWordPosts:(NSString *)search{
    PFGeoPoint *userLocation = [PFGeoPoint geoPointWithLocation:self.mapView.userLocation.location];
    PFQuery *query = [PFQuery queryWithClassName:@"mediaPosts"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"author"];
    [query whereKey:@"message" matchesRegex:search modifiers:@"i"];
    [query whereKey:@"location" nearGeoPoint:userLocation withinMiles:20];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    NSDate *oneDayAgo = [[NSDate date]dateByAddingTimeInterval:-60*60*24];
    [query whereKey:@"createdAt" greaterThan:oneDayAgo];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(objects.count==0){
            self.scrollThroughPicturesLabel.text = @"No Photos";
        }
        self.currentUserPosts = [[NSMutableArray alloc]initWithArray:objects];
        [self setUpAnnotations];
    }];
}



@end
