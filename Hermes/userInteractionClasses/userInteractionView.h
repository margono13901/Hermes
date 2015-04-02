//
//  userInteractionView.h
//  Hermes
//
//  Created by Raylen Margono on 3/31/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <Mapbox-iOS-SDK/Mapbox.h>
#import "keys.h"
#import "NSStack.h"
#import "mediaButton.h"
#import "userPostView.h"
#import "AppDelegate.h"
#import "friendCollectionView.h"
#import "annotationsLinkedList.h"
@class friendCollectionView;
@interface userInteractionView : UIViewController<RMMapViewDelegate>

#pragma view interface
@property (strong, nonatomic) IBOutlet UITextField *notifications;
@property (strong, nonatomic) IBOutlet UIImageView *profileView;
@property (strong, nonatomic) IBOutlet UIView *optionContainers;
@property (strong, nonatomic) IBOutlet RMMapView *mapView;
- (IBAction)camera:(id)sender;
- (IBAction)findFriends:(id)sender;
- (IBAction)zoomToAnnotation:(id)sender;

#pragma interface interaction data
@property(strong,nonatomic) PFUser *currentUserOnDisplay;
@property(strong,nonatomic) AppDelegate *delegate;
@property(strong,nonatomic) NSMutableArray *currentUserPosts;
@property(strong,nonatomic) friendCollectionView *friendPane;
@property(strong,nonatomic) annotationsLinkedList *annotationLink;

@end
