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

typedef void(^zoomCompletion)(BOOL);

@implementation userInteractionView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpNotificationCenter];
    [self initialization];    
}

-(void)viewDidAppear:(BOOL)animated{
    self.mapView.zoom = 15;
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = RMUserTrackingModeFollow;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma refresh


-(void)setUpNotificationCenter{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incomingPost:) name:@"incomingPost" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(segueToFriendSearch:) name:@"segueToFriendSearch" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCurrentUser:) name:@"newUser" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:@"refresh" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUpProfilePhoto:) name:@"changeProfilePhoto" object:nil];
}

-(void)changeCurrentUser:(id)sender{
    self.currentUserOnDisplay = self.friendPane.user;
    self.currentUserNameField.text = self.friendPane.user.username;
    [self getCurrentUserProfilePhoto];
    [self getCurrentuserPosts];
    [self setUpAnnotations];
    self.locationView.text=@"";
    self.scrollThroughPicturesLabel.text = @"Scroll Through Pictures";
    self.currentAnnotation = nil;
}

-(void)refreshView:(id)sender{
    [self setUpNotificationCounter];
    [self setUpAnnotations];
    [self.friendPane getFriends];
    [self.friendPane.collectionView reloadData];
}


-(void)getCurrentUserProfilePhoto{
    [self.currentUserOnDisplay[@"profilePhoto"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *image = [UIImage imageWithData:data];
        CGSize sacleSize = CGSizeMake(50, 50);
        UIGraphicsBeginImageContextWithOptions(sacleSize, NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, sacleSize.width, sacleSize.height)];
        UIImage * resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.currentUserProfilePhoto = resizedImage;
        
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

    }];
}

-(void)incomingPost:(id)sender{
    NSString *incomingPostId = self.delegate.incomingPostId;
    PFQuery *query = [PFQuery queryWithClassName:@"mediaPosts"];
    [query getObjectInBackgroundWithId:incomingPostId block:^(PFObject *object, NSError *error) {
        PFUser *author = object[@"author"];
        if (![author.objectId isEqual:[PFUser currentUser].objectId]) {
            [self addToUnseenPostCenter:object];
        }
        if ([author.objectId isEqual:self.currentUserOnDisplay.objectId]) {
            [self.currentUserPosts insertObject:object atIndex:0];
            [self refreshView:self];
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
    self.mapView.userTrackingMode = RMUserTrackingModeFollow;
    [self.mapView setHideAttribution:YES];
    self.mapView.frame = self.view.frame;
    self.currentUserOnDisplay = [PFUser currentUser];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        //display user
        [self setUpProfilePhoto:self];
        [self getCurrentUserProfilePhoto];
        //download posts
        [self downloadUnseenPosts:YES];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            self.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            //set up nagivation contorller
            self.navigationController.navigationBarHidden = YES;
            self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
            self.navigationController.navigationBar.barTintColor = [projectColor returnColor];
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
            self.optionContainers.backgroundColor = [[projectColor returnColor]colorWithAlphaComponent:1.0f];
            self.bottomOptionContainer.backgroundColor = [UIColor whiteColor];
            self.bottomOptionContainer.layer.borderWidth = 2;
            UIColor *color = [projectColor returnColor];
            self.bottomOptionContainer.layer.borderColor = color.CGColor;
            //scrolll through label setup
            self.scrollThroughPicturesLabel.font = [UIFont fontWithName:@"SackersGothicLightAT" size:10 ];
            //nameView
            self.currentUserNameField.font = [UIFont fontWithName:@"SackersGothicLightAT" size:14 ];
            self.currentUserNameField.text = self.currentUserOnDisplay.username;
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

-(void)downloadUnseenPosts:(BOOL)firstSetUp{
    PFRelation *relation= [[PFUser currentUser]relationForKey:@"unseenPosts"];
    [[relation query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.delegate.unseenPostCenter = [NSMutableDictionary dictionary];
        for (PFObject *posts in objects) {
            [self addToUnseenPostCenter:posts];
        }
        if (firstSetUp) {
            [self setUpNotificationCounter];
            [self getCurrentuserPosts];
        }
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
    PFRelation *relation = [self.currentUserOnDisplay relationForKey:@"mediaPosts"];
    PFQuery *query = [relation query];
    [query orderByDescending:@"createdAt"];
    NSDate *oneDayAgo = [[NSDate date]dateByAddingTimeInterval:-60*60*24];
    [query whereKey:@"createdAt" greaterThan:oneDayAgo];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
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
                if ([self distanceIsClose:post to:comparedPost]) {
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
            [self addAnnotationToLink:annotation];

            dispatch_async(dispatch_get_main_queue(), ^(void)
                           {
                               [self.mapView addAnnotation:annotation];
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
    NSMutableArray *unSeenPosts = [self.delegate.unseenPostCenter objectForKey:self.currentUserOnDisplay.objectId];
    for (PFObject *objects in unSeenPosts) {
        if ([objects.objectId isEqual:post.objectId]) {
            return YES;
        }
    }
    return NO;
}

-(BOOL)distanceIsClose:(PFObject *)post1 to:(PFObject *)post2{
    PFGeoPoint *g1 = post1[@"location"];
    PFGeoPoint *g2 = post2[@"location"];
    CLLocation *l1 = [[CLLocation alloc]initWithLatitude:[g1 latitude] longitude:[g1 longitude]];
    CLLocation *l2 = [[CLLocation alloc]initWithLatitude:[g2 latitude] longitude:[g2 longitude]];
    if ([l1 distanceFromLocation:l2]<50) {
        return true;
    }
    return false;
}

-(RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation{
    if ([annotation isUserLocationAnnotation]) return nil;
    
    RMMapLayer *mapLayer = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"singlePic"]];
    mapLayer.bounds = CGRectMake(0, 0, 60, 60);
    mapLayer.canShowCallout = YES;
    mediaButton *button = [[mediaButton alloc]initWithQueue:annotation.userInfo];
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(displayMediaStack:)];
    [button addGestureRecognizer:singleFingerTap];
    mapLayer.rightCalloutAccessoryView = button;
    mapLayer.leftCalloutAccessoryView = [[UIImageView alloc]
                                       initWithImage:
                                       self.currentUserProfilePhoto];
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
        UIImage *blurImage = [[self getImageView] stackBlur:50];
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            [self.friendPane moveToView:blurImage];
        });
    });
}

- (IBAction)zoomToAnnotation:(id)sender{
    if (self.annotationLink.storage.count>0) {
        RMAnnotation *annotation = [self.annotationLink scrollThroughAnnotatotation];
        [self selectAnnotation:annotation];
    }
}

- (IBAction)zoomToAnnotationBack:(id)sender {
    if (self.annotationLink.storage.count>0) {
        RMAnnotation *annotation = [self.annotationLink scrollBackThroughAnnotatotation];
        [self selectAnnotation:annotation];
    }
}

-(void)selectAnnotation:(RMAnnotation *)annotation{
    [self didZoomWithAnnotation:annotation withComp:^(BOOL finished) {
        if (finished) {
            self.currentAnnotation = annotation;
            [self.mapView selectAnnotation:annotation animated:YES];
            
            CLLocationCoordinate2D coordinate = [annotation coordinate];
            double lat = coordinate.latitude;
            double lon = coordinate.longitude;
            CLLocation *postLocation = [[CLLocation alloc]initWithLatitude:lat longitude:lon];
            double distance = [postLocation distanceFromLocation:self.mapView.userLocation.location];
            self.scrollThroughPicturesLabel.text = [self distanceString:distance];
        }
    }];
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

- (IBAction)displayUber:(id)sender {
    GPUberViewController *uber = [[GPUberViewController alloc] initWithServerToken:uberClientServerToken];
    // optional
    if (self.currentAnnotation&&self.annotationLink.storage.count>0&&self.locationView.text.length>0) {
        uber.startLocation = self.mapView.userLocation.location.coordinate;
        uber.endLocation = [self.currentAnnotation coordinate];
        [uber showInViewController:self];
    }
}

-(void)didZoomWithAnnotation:(RMAnnotation *)annotation withComp:(zoomCompletion)compblock{
    //do stuff
    CLLocationCoordinate2D coordinate = [annotation coordinate];
    [self getGeoCodingInformationWithLat:coordinate.latitude withLon:coordinate.longitude];
    //Find the southwest and northeast point
    double northEastLatitude = coordinate.latitude;
    double northEastLongitude = coordinate.longitude;
    double southWestLatitude = coordinate.latitude;
    double southWestLongitude = coordinate.longitude;
    
    
    
    [self.mapView zoomWithLatitudeLongitudeBoundsSouthWest:CLLocationCoordinate2DMake(southWestLatitude, southWestLongitude)
                                                 northEast:CLLocationCoordinate2DMake(northEastLatitude, northEastLongitude)
                                                  animated:NO];
    compblock(YES);
}

-(void)getGeoCodingInformationWithLat:(double)lat withLon:(double)lon{
    NSString *index= @"mapbox.places";
    NSString *url = [NSString stringWithFormat:@"http://api.tiles.mapbox.com/v4/geocode/%@/%f,%f.json?access_token=%@",index,lon,lat,mapAccessToken];
    AFSecurityPolicy *policy = [[AFSecurityPolicy alloc] init];
    [policy setAllowInvalidCertificates:YES];
    
    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    [operationManager setSecurityPolicy:policy];
    operationManager.requestSerializer = [AFJSONRequestSerializer serializer];
    operationManager.responseSerializer = [AFJSONResponseSerializer serializer];
    operationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.geo+json"];
    
    [operationManager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *json  = responseObject;
        NSArray *jsonData = [json objectForKey:@"features"];
        NSDictionary *allData = jsonData[0];
        NSString *location = [allData objectForKey:@"place_name"];
        NSArray* stringArray = [location  componentsSeparatedByString:@","];
        NSMutableString *text = [[NSMutableString alloc]init];
        for (int i = 0 ; i < stringArray.count-1; i++) {
            [text appendString:stringArray[i]];
            [text appendString:@" "];
        }
        self.locationView.text = [NSString stringWithFormat:@"%@",text];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (UIImage *)getImageView{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * myImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return myImage;
}
@end
