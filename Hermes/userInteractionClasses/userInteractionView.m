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
    [self setUpNotificationCenter];
    [self initialization];
}

-(void)viewDidAppear:(BOOL)animated{
    self.mapView.zoom = 15;
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
    [self getCurrentuserPosts];
    [self setUpAnnotations];
}


-(void)refreshView:(id)sender{
    [self setUpNotificationCounter];
    [self setUpAnnotations];
    [self.friendPane.collectionView reloadData];
}

-(void)incomingPost:(id)sender{
    NSString *incomingPostId = self.delegate.incomingPostId;
    PFQuery *query = [PFQuery queryWithClassName:@"mediaPosts"];
    [query getObjectInBackgroundWithId:incomingPostId block:^(PFObject *object, NSError *error) {
        [self addToUnseenPostCenter:object];
        [self.currentUserPosts addObject:object];
        [self refreshView:self];
    }];
}

#pragma firstTimeSetups

-(void)initialization{
    self.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];;
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor purpleColor];
    self.optionContainers.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.8f];
    self.friendPane = [[friendCollectionView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.friendPane];
    [[RMConfiguration sharedInstance] setAccessToken:mapAccessToken];
    RMMapboxSource *tileSource = [[RMMapboxSource alloc] initWithMapID:mapID];
    self.mapView.delegate = self;
    [self.mapView setTileSource:tileSource];
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = RMUserTrackingModeFollow;
    [
     self setUpProfilePhoto:self];
    self.currentUserOnDisplay = [PFUser currentUser];
    [self downloadUnseenPosts:YES];
}

-(void)setUpProfilePhoto:(id)sender{
    [[PFUser currentUser][@"profilePhoto"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        self.profileView.image = [UIImage imageWithData:data];
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
    }else{
        self.notifications.hidden = YES;
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
    [query orderByAscending:@"createdAt"];
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
            NSStack *postStack = [[NSStack alloc]init];
            PFObject *post = [temp objectAtIndex:i];
            [postStack push:post];
            if ([self postIsUnseen:post]) newPosts++;
            
            int iterations = i+1;
            while (iterations < temp.count) {
                PFObject *comparedPost = [temp objectAtIndex:iterations];
                if ([self distanceIsClose:post to:comparedPost]) {
                    [postStack push:comparedPost];
                    [temp removeObject:comparedPost];
                    if ([self postIsUnseen:comparedPost]) newPosts++;
                }else{
                    iterations++;
                }
            }
            CLLocation *location = [[CLLocation alloc]initWithLatitude:[post[@"location"] latitude] longitude:[post[@"location"] longitude]];
            
            RMAnnotation *annotation = [RMAnnotation annotationWithMapView:self.mapView coordinate:[location coordinate] andTitle:[NSString stringWithFormat:@"%i new posts",newPosts]];
            
            annotation.userInfo = postStack;
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
    mapLayer.bounds = CGRectMake(0, 0, 50, 50);
    mapLayer.canShowCallout = YES;
    mediaButton *button = [[mediaButton alloc]initWithStack:annotation.userInfo];
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(displayMediaStack:)];
    [button addGestureRecognizer:singleFingerTap];
    mapLayer.rightCalloutAccessoryView = button;
    
    return mapLayer;
}

-(void)displayMediaStack:(UITapGestureRecognizer *)sender{
    mediaButton *button = (mediaButton *)sender.view;
    userPostView *media = [[userPostView alloc]initWithFrame:self.view.frame withStack:button.stack];
    [self.view addSubview:media];
}

-(void)segueToFriendSearch:(id)sender{
    [self performSegueWithIdentifier:@"searchFriendsSegue" sender:self];
}

- (IBAction)camera:(id)sender {
    [self performSegueWithIdentifier:@"camera" sender:self];
}

- (IBAction)findFriends:(id)sender{
    UIImage *blurImage = [self blurWithCoreImage:[self getImageView]];
    [self.friendPane moveToView:blurImage];
}

- (IBAction)zoomToAnnotation:(id)sender{
    
    RMAnnotation *annotation = [self.annotationLink returnAnnotatotation];
    
    CLLocationCoordinate2D coordinate = [annotation coordinate];

    //Find the southwest and northeast point
    double northEastLatitude = coordinate.latitude;
    double northEastLongitude = coordinate.longitude;
    double southWestLatitude = coordinate.latitude;
    double southWestLongitude = coordinate.longitude;
    
    [self.mapView zoomWithLatitudeLongitudeBoundsSouthWest:CLLocationCoordinate2DMake(southWestLatitude, southWestLongitude)
                                         northEast:CLLocationCoordinate2DMake(northEastLatitude, northEastLongitude)
                                          animated:YES];
    [self.mapView selectAnnotation:annotation animated:YES];

}
- (UIImage *)getImageView{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * myImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return myImage;
}

- (UIImage *)blurWithCoreImage:(UIImage *)sourceImage
{
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];
    
    // Apply Affine-Clamp filter to stretch the image so that it does not
    // look shrunken when gaussian blur is applied
    CGAffineTransform transform = CGAffineTransformIdentity;
    CIFilter *clampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    [clampFilter setValue:inputImage forKey:@"inputImage"];
    [clampFilter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    // Apply gaussian blur filter with radius of 30
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
    [gaussianBlurFilter setValue:clampFilter.outputImage forKey: @"inputImage"];
    [gaussianBlurFilter setValue:@30 forKey:@"inputRadius"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:gaussianBlurFilter.outputImage fromRect:[inputImage extent]];
    
    // Set up output context.
    UIGraphicsBeginImageContext(self.view.frame.size);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    
    // Invert image coordinates
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.view.frame.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, self.view.frame, cgImage);
    
    // Apply white tint
    CGContextSaveGState(outputContext);
    CGContextSetFillColorWithColor(outputContext, [UIColor colorWithWhite:1 alpha:0.2].CGColor);
    CGContextFillRect(outputContext, self.view.frame);
    CGContextRestoreGState(outputContext);
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

@end
