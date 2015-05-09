//
//  UberViewController.m
//  ModalUITest
//
//  Created by George Polak on 2/9/15.
//  Copyright (c) 2015 George Polak. All rights reserved.
//

#import "GPUberViewController.h"
#import <MapKit/MapKit.h>
#import "GPUberViewElement.h"
#import "GPUberPrice.h"
#import "GPUberNetworking.h"
#import "NSDictionary+URLEncoding.h"
#import "GPUberUtils.h"
#import "UIColor+GPUberView.h"
#import  <UIImageView+AFNetworking.h>
#import "GPUberViewCell.h"
#import <PulsingHaloLayer.h>
#import <Masonry.h>
#import <INTULocationManager.h>
#import "UIAlertView+BlocksKit.h"


#define DEFAULT_CLIENT_ID @"70zxopERw9Nx2OeQU8yrUYSpW69N-RVh"
#define uberClientServerToken @"K3bEsfZHfd4J_N1c-R-E_sExSEL7nBwnFylz67th"
#define uberSecret @"kPe3aGnyWs5uZTdlalJTgQYZdESeExLcJkLTLmtH"
#define redirectURI @"Hermes://com.Hyphen.Hermes"
#define uberClientId @"LZCKMtpl8YmctOR93qdjL8n_0fvJGH8z"

@interface GPUberViewController () <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>

typedef NS_ENUM(NSInteger, GPUberViewError) {
    GPUberViewErrorNetwork = 0,
    GPUberViewErrorNoProducts = 1,
    GPUberViewErrorLocationUnavailable = 2,
    GPUberViewErrorLocationDisabled = 3,
    GPUberViewErrorLocationPrePermissionDeclined = 4,
    GPUberViewErrorDistanceExceeded = 5,
};

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tableHeight;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UITextField *statusLabel;
@property (strong, nonatomic) IBOutlet UITextField *nameLabel;
@property (strong, nonatomic) IBOutlet UITextField *phoneNumber;
@property (strong, nonatomic) IBOutlet UIImageView *driverImage;
@property (strong, nonatomic) IBOutlet UIImageView *carImage;
@property (strong, nonatomic) IBOutlet UIView *driverInformation;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UIWebView *webview;
@property (strong,nonatomic) MKPlacemark *carAnnotation;

@property (nonatomic) PulsingHaloLayer *pulsingHalo;
@property (nonatomic) MKRoute *route;
@property (nonatomic) NSString *serverToken;
@property (nonatomic) CLPlacemark *destinationPlacemark;
@property (nonatomic) NSArray *elements;
@property (nonatomic) UIColor *previousWindowColor;
@property (nonatomic) BOOL firstLoad;
@property (nonatomic) INTULocationRequestID locationRequestId;

@end


@implementation GPUberViewController

- (id)initWithServerToken:(NSString *)serverToken {
    if (serverToken.length == 0)
        [NSException raise:NSInvalidArgumentException format:@"invalid server token:%@", serverToken];
    
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.serverToken = serverToken;
        self.startLocation = kCLLocationCoordinate2DInvalid;
        self.endLocation = kCLLocationCoordinate2DInvalid;
        
        self.firstLoad = NO;
    }
    
    return self;
}

- (id)initWithServerToken:(NSString *)serverToken
                    start:(CLLocationCoordinate2D)start
                      end:(CLLocationCoordinate2D)end {
    
    if (!CLLocationCoordinate2DIsValid(start))
        [NSException raise:NSInvalidArgumentException format:@"invalid start (%f, %f)", start.latitude, start.longitude];
    if (!CLLocationCoordinate2DIsValid(end))
        [NSException raise:NSInvalidArgumentException format:@"invalid end (%f, %f)", end.latitude, end.longitude];
    
    GPUberViewController *instance = [self initWithServerToken:serverToken];
    instance.startLocation = start;
    instance.endLocation = end;
    
    return instance;
}

- (id)initWithServerToken:(NSString *)serverToken
               clientId:(NSString *)clientId
                  start:(CLLocationCoordinate2D)start
                    end:(CLLocationCoordinate2D)end {
    
    GPUberViewController *instance = [self initWithServerToken:serverToken start:start end:end];
    instance.clientId = clientId;
    
    return instance;
}

- (void)showInViewController:(UIViewController *)viewController {
    UINavigationController *nVc = [[UINavigationController alloc] initWithRootViewController:self];
    float red = 29.0f/255.0f;
    float green = 202.0f/255.0f;
    float blue = 255.0f/255.0f;
    nVc.navigationBar.barTintColor =[UIColor colorWithRed:red green:green blue:blue alpha:1.0f ];
    [viewController presentViewController:nVc animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                  target:self
                                                                                  action:@selector(cancelView)];
    NSString *url;
    NSDictionary * uberinformation = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"uberInformation"];
    if (!uberinformation) {
        url = [NSString stringWithFormat:@"https://login.uber.com/oauth/authorize?response_type=code&client_id=%@&scope=request",uberClientId];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];

    }else{
        NSString *refreshToken = [uberinformation objectForKey:@"refresh_token"];
        url = [NSString stringWithFormat:@"https://login.uber.com/oauth/token"];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
         manager.requestSerializer = [AFJSONRequestSerializer serializer];
        NSDictionary *params = @{@"client_secret": uberSecret,
                                 @"client_id": uberClientId,
                                 @"grant_type": @"refresh_token",
                                 @"redirect_uri" : redirectURI,
                                 @"refresh_token": refreshToken
                                 };
        [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];

    }
    

    cancelButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = cancelButton;
   
    self.navigationItem.titleView = [GPUberUtils titleLabelForController:self.navigationController text:@"finding drivers..."];
    
    self.view.backgroundColor = [UIColor uberLightGray];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GPUberViewCell" bundle:nil] forCellReuseIdentifier:[GPUberViewCell reuseIdentifier]];
    
    self.loadingView.hidden = NO;
    self.pulsingHalo = [PulsingHaloLayer layer];
    self.pulsingHalo.animationDuration = 1.5;
    self.pulsingHalo.backgroundColor = [UIColor uberBlue].CGColor;
    self.pulsingHalo.radius = 75;
    self.pulsingHalo.position = self.loadingView.center;
    [self.loadingView.layer addSublayer:self.pulsingHalo];
    self.pulsingHalo.hidden = YES;
    
    [self refreshTable];
    
    // begin destination RGeo for the end location (start is done by the Uber app) unless the desired nickname was supplied
    if (!self.endName &&  CLLocationCoordinate2DIsValid(self.endLocation)) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        CLLocation *destinationLocation = [[CLLocation alloc] initWithLatitude:self.endLocation.latitude longitude:self.endLocation.longitude];
        [geocoder reverseGeocodeLocation:destinationLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            // If there's an error, no biggie. This is just a convenience
            if (!error || placemarks.count == 0) {
                self.destinationPlacemark = [placemarks firstObject];
            }
        }];
    }
    
    self.firstLoad = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIApplication *application = [UIApplication sharedApplication];
    self.previousWindowColor = application.keyWindow.backgroundColor;
    application.keyWindow.backgroundColor = [UIColor whiteColor];
    
    // recenter after view has loaded (and shifted)
    self.pulsingHalo.position = self.loadingView.center;
    self.pulsingHalo.hidden = NO;
    
    // this needs to happen only once AND once the view loads (UI dims settle)
    if (self.firstLoad) {
        [self launch];
        self.firstLoad = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // restore previous UI values
    UIApplication *application = [UIApplication sharedApplication];
    application.keyWindow.backgroundColor = self.previousWindowColor;
}

- (void)launch {
    [[[self determineStartLocation] continueWithSuccessBlock:^id(BFTask *task) {
        // success, proceed
        
        return [self initializeUber];
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (task.error) {
            [self.pulsingHalo removeFromSuperlayer];
            
            NSString *title = @"unknown error";
            NSString *message = @"We're sorry, but there was a problem contacting Uber.";
            
            NSString *domain = task.error.domain;
            NSInteger code = task.error.code;
            if ([domain isEqualToString:GP_UBER_VIEW_DOMAIN]) {
                if (code == GPUberViewErrorNetwork) {
                    title = @"network error";
                    message = @"We're sorry, but there was a problem contacting Uber.";
                } else if (code == GPUberViewErrorNoProducts) {
                    title = @"service unavailable";
                    message = @"We're sorry, but Uber is not yet available in your area.";
                } else if (code == GPUberViewErrorLocationUnavailable) {
                    title = @"no location";
                    message = @"We're sorry, your location could not be determined.";
                } else if (code == GPUberViewErrorLocationDisabled) {
                    title = @"location disabled";
                    message = @"You must enable location services to determine your pickup location.";
                } else if (code == GPUberViewErrorDistanceExceeded) {
                    title = @"distance exceeded";
                    message = @"We're sorry, but the requested route is too long.";
                } else if (code == GPUberViewErrorLocationPrePermissionDeclined) {
                    title = nil;
                    message = nil;
                    
                    [self cancelView];
                    return nil;
                }
            }
            
            self.navigationItem.titleView = [GPUberUtils titleLabelForController:self.navigationController text:title];
            UILabel *label = [GPUberUtils errorLabelWithText:message];
            [self.loadingView addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.loadingView.mas_centerX);
                make.centerY.equalTo(self.loadingView.mas_centerY);
                make.width.equalTo(@(label.frame.size.width)).priorityHigh();
                make.height.equalTo(@(label.frame.size.height)).priorityHigh();
            }];
        } else {
            [self refreshTable];
            
            // must refresh map frame for proper zoom computation
            [self.mapView layoutIfNeeded];
            if (self.route)
                [GPUberUtils zoomMapView:self.mapView toRoute:self.route animated:NO];
            else
                [GPUberUtils zoomMapViewToFitAnnotations:self.mapView animated:NO];
            
            [UIView animateWithDuration:0.5 animations:^{
                self.loadingView.alpha = 0;
            } completion:^(BOOL finished) {
                [self.loadingView removeFromSuperview];
            }];
            
            [UIView animateWithDuration:0.2 animations:^{
                self.navigationItem.titleView.alpha = 0;
            } completion:^(BOOL finished) {
                UIImage *logo = [self changeColorForImage:[UIImage imageNamed:@"uber_logo_15"] toColor:[UIColor whiteColor]];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:logo];
                [imageView setTintColor:[UIColor whiteColor]];
                imageView.contentMode = UIViewContentModeCenter;
                self.navigationItem.titleView = imageView;
                self.navigationItem.titleView.alpha = 0;
                
                [UIView animateWithDuration:0.3 animations:^{
                    self.navigationItem.titleView.alpha = 1.0;
                }];
            }];
        }
        
        return nil;
    }];
}

-(UIImage*)changeColorForImage:(UIImage *)image toColor:(UIColor*)color
{
    UIGraphicsBeginImageContext(image.size);
    
    CGRect contextRect;
    contextRect.origin.x = 0.0f;
    contextRect.origin.y = 0.0f;
    contextRect.size = [image size];
    
    // Retrieve source image and begin image context
    CGSize itemImageSize = [image size];
    CGPoint itemImagePosition;
    itemImagePosition.x = ceilf((contextRect.size.width - itemImageSize.width) / 2);
    itemImagePosition.y = ceilf((contextRect.size.height - itemImageSize.height) );
    
    UIGraphicsBeginImageContext(contextRect.size);
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    // Setup shadow
    // Setup transparency layer and clip to mask
    CGContextBeginTransparencyLayer(c, NULL);
    CGContextScaleCTM(c, 1.0, -1.0);
    CGContextClipToMask(c, CGRectMake(itemImagePosition.x, -itemImagePosition.y, itemImageSize.width, -itemImageSize.height), [image CGImage]);
    // Fill and end the transparency layer
    CGColorSpaceRef colorSpace = CGColorGetColorSpace(color.CGColor);
    CGColorSpaceModel model = CGColorSpaceGetModel(colorSpace);
    const CGFloat* colors = CGColorGetComponents(color.CGColor);
    
    if(model == kCGColorSpaceModelMonochrome)
    {
        CGContextSetRGBFillColor(c, colors[0], colors[0], colors[0], colors[1]);
    }else{
        CGContextSetRGBFillColor(c, colors[0], colors[1], colors[2], colors[3]);
    }
    contextRect.size.height = -contextRect.size.height;
    contextRect.size.height -= 15;
    CGContextFillRect(c, contextRect);
    CGContextEndTransparencyLayer(c);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)setClientId:(NSString *)clientId {
    _clientId = clientId;
}

- (NSString *)clientId {
    if (_clientId)
        return _clientId;
    else
        return DEFAULT_CLIENT_ID;
}

- (IBAction)cancelView {
    [[INTULocationManager sharedInstance] cancelLocationRequest:self.locationRequestId];
    if ([self.requestGet isEqual:@"processing"]||[self.requestGet isEqual:@"accepted"]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Cancel Uber?" message:@"Closing This Window Will Cancel Uber" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        [alert show];
    }else{
        [self.timer invalidate];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        NSDictionary * myDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"uberInformation"];
        
        NSString *accessToken = [myDictionary objectForKey:@"access_token"];
        
        NSString *url = [NSString stringWithFormat:@"https://api.uber.com/v1/requests/%@",self.request_id];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        AFHTTPRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
        [requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",accessToken] forHTTPHeaderField:@"Authorization"];
        manager.requestSerializer = requestSerializer;
        [manager DELETE:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.timer invalidate];
            [self dismissViewControllerAnimated:YES completion:nil];
            NSLog(@"success");
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];

    }
}


- (GPUberViewElement *)elementWithProductId:(NSString *)productId {
    if (!productId)
        return nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productId == %@", productId];
    NSArray *filteredArray = [self.elements filteredArrayUsingPredicate:predicate];
    return filteredArray.count > 0 ? filteredArray.firstObject : nil;
}

- (BFTask *)initializeUber {
    // wait for both map routing and Uber data to finish before dismissing wait screen
    
    NSMutableArray *tasks = [NSMutableArray new];
    
    [tasks addObject:[self setupMap]];
    [tasks addObject:[self getUberData]];
    
    return [BFTask taskForCompletionOfAllTasks:tasks];
}

- (BFTask *)determineStartLocation {
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    
    // is location passed-in by the user?
    if (CLLocationCoordinate2DIsValid(self.startLocation)) {
        [taskSource setResult:nil];
        
    // is location enabled?
    } else if (![CLLocationManager locationServicesEnabled]) {
        NSError *error = [NSError errorWithDomain:GP_UBER_VIEW_DOMAIN code:GPUberViewErrorLocationDisabled userInfo:nil];
        [taskSource setError:error];
        
    // should ask for location permissions?
    } else  {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusNotDetermined) {
            // show pre-permission dialog first (https://medium.com/@mulligan/the-right-way-to-ask-users-for-ios-permissions-96fa4eb54f2c)
            [UIAlertView bk_showAlertViewWithTitle:@"Allow Location?"
                                           message:@"Uber needs to determine your pickup location."
                                 cancelButtonTitle:@"Not Now"
                                 otherButtonTitles:@[@"Give Access"]
                                           handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                               
                                               if (buttonIndex != alertView.cancelButtonIndex) {
                                                   [self getLocationWithTaskSource:taskSource delay:YES];
                                               } else {
                                                   NSError *error = [NSError errorWithDomain:GP_UBER_VIEW_DOMAIN code:GPUberViewErrorLocationPrePermissionDeclined userInfo:nil];
                                                   [taskSource setError:error];
                                               }
            }];

        // else if location services authorized (looks messy due to backward iOS7 compatibility/deprecation handling)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        } else if ( ([CLLocationManager instanceMethodForSelector:@selector(requestWhenInUseAuthorization)] && status == kCLAuthorizationStatusAuthorizedWhenInUse) ||
                   status == kCLAuthorizationStatusAuthorized ) {
#pragma clang diagnostic pop
            [self getLocationWithTaskSource:taskSource delay:NO];
        
        // denied location permissions?
        } else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
            NSError *error = [NSError errorWithDomain:GP_UBER_VIEW_DOMAIN code:GPUberViewErrorLocationDisabled userInfo:nil];
            [taskSource setError:error];
            
        // some other error?
        } else {
            NSError *error = [NSError errorWithDomain:GP_UBER_VIEW_DOMAIN code:GPUberViewErrorLocationUnavailable userInfo:nil];
            [taskSource setError:error];
        }
    }
    
    return taskSource.task;
}

- (void)getLocationWithTaskSource:(BFTaskCompletionSource *)taskSource delay:(BOOL)delay {
    INTULocationManager *manager = [INTULocationManager sharedInstance];
    self.locationRequestId = [manager requestLocationWithDesiredAccuracy:INTULocationAccuracyBlock
                                                                 timeout:10
                                                    delayUntilAuthorized:delay
                                                                   block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
       // proceed even with a timeout (user/Uber can refine accuracy later)
       if (status == INTULocationStatusSuccess || (status == INTULocationStatusTimedOut && currentLocation)) {
           self.startLocation = currentLocation.coordinate;
           [taskSource setResult:nil];

           // we have a good enough location to show the UI and proceed, but attempt to improve it if too coarse
           if (achievedAccuracy < INTULocationAccuracyHouse) {
               self.locationRequestId = [manager subscribeToLocationUpdatesWithBlock:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                   if (status == INTULocationStatusSuccess) {
                       self.startLocation = currentLocation.coordinate;
                       
                       if (achievedAccuracy >= INTULocationAccuracyRoom)
                           [manager cancelLocationRequest:self.locationRequestId];
                   }
               }];
           }
           
       } else if (status == INTULocationStatusServicesDenied || status == INTULocationStatusServicesDisabled) {
           NSError *error = [NSError errorWithDomain:GP_UBER_VIEW_DOMAIN code:GPUberViewErrorLocationDisabled userInfo:nil];
           [taskSource setError:error];
       } else {
           NSError *error = [NSError errorWithDomain:GP_UBER_VIEW_DOMAIN code:GPUberViewErrorLocationUnavailable userInfo:nil];
           [taskSource setError:error];
       }
    }];
}

- (BFTask *)getUberData {
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    
    [[[[GPUberNetworking productsForStart:self.startLocation
                              serverToken:self.serverToken] continueWithSuccessBlock:^id(BFTask *task) {
        
        NSArray *products = task.result;
        if (products.count == 0) {
            NSError *error = [NSError errorWithDomain:GP_UBER_VIEW_DOMAIN code:GPUberViewErrorNoProducts userInfo:nil];
            return [BFTask taskWithError:error];
        } else {
            NSMutableArray *elements = [NSMutableArray arrayWithCapacity:products.count];
            for (GPUberProduct *product in products)
                [elements addObject:[GPUberViewElement elementWithProduct:product]];
            
            self.elements = [NSArray arrayWithArray:elements];
            
            if (CLLocationCoordinate2DIsValid(self.endLocation)) {
                return [GPUberNetworking pricesForStart:self.startLocation end:self.endLocation serverToken:self.serverToken];
            } else {
                // no end location specified, just fall through
                return [BFTask taskWithResult:nil];
            }
        }
    }] continueWithSuccessBlock:^id(BFTask *task) {
        NSArray *prices = task.result;
        for (GPUberPrice *price in prices) {
            GPUberViewElement *element = [self elementWithProductId:price.productId];
            [element parametrizeWithPrice:price];
        }
        
        return [GPUberNetworking timeEstimatesForStart:self.startLocation serverToken:self.serverToken];
    }] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            NSLog(@"error fetching uber data:%@", task.error);
            
            NSError *error = task.error;
            if (![error.domain isEqualToString:GP_UBER_VIEW_DOMAIN]) {
                if (error.code == 422)
                    error = [NSError errorWithDomain:GP_UBER_VIEW_DOMAIN code:GPUberViewErrorDistanceExceeded userInfo:task.error.userInfo];
                else
                    error = [NSError errorWithDomain:GP_UBER_VIEW_DOMAIN code:GPUberViewErrorNetwork userInfo:task.error.userInfo];
            }
            
            [taskSource setError:error];
        } else {
            NSArray *times = task.result;
            for (GPUberTime *time in times) {
                GPUberViewElement *element = [self elementWithProductId:time.productId];
                [element parametrizeWithTime:time];
            }
            
            [taskSource setResult:nil];
        }
        
        return nil;
    }];
    
    return taskSource.task;
}

- (void)launchUberWithProductId:(NSString *)productId clientId:(NSString *)clientId {
    NSString *urlString = nil;
    
    // use user-supplied nickname, or computed if none available
    NSString *dropoffNickname = self.endName;
    if (!dropoffNickname && self.destinationPlacemark) {
        if (self.destinationPlacemark.name)
            dropoffNickname = self.destinationPlacemark.name;
        else if (self.destinationPlacemark.subThoroughfare && self.destinationPlacemark.thoroughfare)
            dropoffNickname = [NSString stringWithFormat:@"%@ %@", self.destinationPlacemark.subThoroughfare, self.destinationPlacemark.thoroughfare];
        else
            dropoffNickname = self.destinationPlacemark.thoroughfare;
    }
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"uber://"]]) {
        // launch Uber app
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       productId, @"product_id",
                                       clientId, @"client_id",
                                       [NSNumber numberWithDouble:self.startLocation.latitude], @"pickup[latitude]",
                                       [NSNumber numberWithDouble:self.startLocation.longitude], @"pickup[longitude]",
                                       nil];
        
        if (CLLocationCoordinate2DIsValid(self.endLocation)) {
            [params setObject:[NSNumber numberWithDouble:self.endLocation.latitude] forKey:@"dropoff[latitude]"];
            [params setObject:[NSNumber numberWithDouble:self.endLocation.longitude] forKey:@"dropoff[longitude]"];
        }
        
        if (self.startName) [params setObject:self.startName forKey:@"pickup[nickname]"];
        if (dropoffNickname) [params setObject:dropoffNickname forKey:@"dropoff[nickname]"];

        urlString = [NSString stringWithFormat:@"uber://?action=setPickup&%@", [params urlEncodedString]];
    } else {
        // launch mobile site
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       productId, @"product_id",
                                       clientId, @"client_id",
                                       [NSNumber numberWithDouble:self.startLocation.latitude], @"pickup_latitude",
                                       [NSNumber numberWithDouble:self.startLocation.longitude], @"pickup_longitude",
                                       nil];
        
        if (self.firstName) [params setObject:self.firstName forKey:@"first_name"];
        if (self.lastName) [params setObject:self.lastName forKey:@"last_name"];
        if (self.email) [params setObject:self.email forKey:@"email"];
        if (self.countryCode) [params setObject:self.countryCode forKey:@"country_code"];
        if (self.mobileCountryCode) [params setObject:self.mobileCountryCode forKey:@"mobile_country_code"];
        if (self.mobilePhone) [params setObject:self.mobilePhone forKey:@"mobile_phone"];
        if (self.zipcode) [params setObject:self.zipcode forKey:@"zipcode"];
        
        if (CLLocationCoordinate2DIsValid(self.endLocation)) {
            [params setObject:[NSNumber numberWithDouble:self.endLocation.latitude] forKey:@"dropoff_latitude"];
            [params setObject:[NSNumber numberWithDouble:self.endLocation.longitude] forKey:@"dropoff_longitude"];
        }
        
        if (self.startName) [params setObject:self.startName forKey:@"pickup_nickname"];
        if (dropoffNickname) [params setObject:dropoffNickname forKey:@"dropoff_nickname"];
        
        urlString = [NSString stringWithFormat:@"https://m.uber.com/sign-up?%@", [params urlEncodedString]];
    }
    
    // cancel any pending location updates
    [[INTULocationManager sharedInstance] cancelLocationRequest:self.locationRequestId];
    
    NSLog(@"[GPUberView] launching Uber with: %@", urlString);
    [GPUberUtils openURL:[NSURL URLWithString:urlString]];
}


#pragma mark - Map

- (BFTask *)setupMap {
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    
    if (CLLocationCoordinate2DIsValid(self.startLocation) && CLLocationCoordinate2DIsValid(self.endLocation)) {
        MKPlacemark *startMark = [[MKPlacemark alloc] initWithCoordinate:self.startLocation addressDictionary:nil];
        MKPlacemark *endMark = [[MKPlacemark alloc] initWithCoordinate:self.endLocation addressDictionary:nil];
        
        [self.mapView addAnnotation:startMark];
        [self.mapView addAnnotation:endMark];
        
        // optimization to pre-load tile
        [GPUberUtils zoomMapViewToFitAnnotations:self.mapView animated:NO];
        
        MKMapItem *startItem = [[MKMapItem alloc] initWithPlacemark:startMark];
        MKMapItem *endItem = [[MKMapItem alloc] initWithPlacemark:endMark];
        
        MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
        request.source = startItem;
        request.destination = endItem;
        
        MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
            if (error || response.routes.count == 0) {
                NSLog(@"error calculating directions:%@", error);
            } else {
                self.route = [response.routes firstObject];
                [self.mapView addOverlay:self.route.polyline level:MKOverlayLevelAboveRoads];
            }
            
            // it's a success either way, we just wait for this to finish
            [taskSource setResult:nil];
        }];
    } else if (CLLocationCoordinate2DIsValid(self.startLocation)) {
        MKPlacemark *startMark = [[MKPlacemark alloc] initWithCoordinate:self.startLocation addressDictionary:nil];
        
        [self.mapView addAnnotation:startMark];
        
        // done
        [taskSource setResult:nil];
    } else {
        // done
        [taskSource setResult:nil];
    }
    
    return taskSource.task;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay {
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor uberBlue];
    renderer.lineWidth = 5.0;
    return renderer;
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation {
    static NSString *startPin = @"startPin";
    static NSString *endPin = @"endPin";
    static NSString *driverPin = @"driverPin";

    MKPinAnnotationView *annotationView = nil;
    if ([GPUberUtils isCoordinate:annotation.coordinate equalToCoordinate:self.startLocation]) {
        annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:startPin];
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:startPin];
            annotationView.pinColor = MKPinAnnotationColorGreen;
        }
    } else if([GPUberUtils isCoordinate:annotation.coordinate equalToCoordinate:self.endLocation]) {
        annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:endPin];
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:endPin];
            annotationView.pinColor = MKPinAnnotationColorRed;
        }
    }
    else{
        annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:driverPin];
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:driverPin];
            annotationView.pinColor = MKPinAnnotationColorPurple;

        }
    }
    
    return annotationView;
}

#pragma mark - Table

- (void)refreshTable {
    self.tableView.rowHeight = 44;
    self.tableHeight.constant = self.tableView.rowHeight * self.elements.count;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.elements.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GPUberViewCell *cell = (GPUberViewCell *)[tableView dequeueReusableCellWithIdentifier:[GPUberViewCell reuseIdentifier]];
    
    GPUberViewElement *element = [self.elements objectAtIndex:indexPath.row];
    
    [cell.productImageView setImageWithURL:element.image placeholderImage:nil];
    
    cell.productNameLabel.text = element.displayName;
    
    if (element.priceEstimate) {
        cell.innerLabel.text = [element timeEstimateString];
        
        cell.rightLabel.text = element.priceEstimate;
        cell.rightLabel.textColor = element.surgeMultiplier > 1 ? [UIColor uberBlue] : [UIColor grayColor];
    } else {
        cell.innerLabel.text = nil;
        
        cell.rightLabel.text = [element timeEstimateString];
        cell.rightLabel.textColor = [UIColor grayColor];
    }
    
    return cell;
}
#pragma CHANGE THIS TO DO ENDPOINT REQUEST
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GPUberViewElement *element = [self.elements objectAtIndex:indexPath.row];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];

    //[self launchUberWithProductId:element.productId clientId:self.clientId];
    NSDictionary * myDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"uberInformation"];
    NSString *accessToken = [myDictionary objectForKey:@"access_token"];
    NSString *url = [NSString stringWithFormat:@"https://api.uber.com/v1/requests"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",accessToken] forHTTPHeaderField:@"Authorization"];
    manager.requestSerializer = requestSerializer;
    NSDictionary *params = @{@"product_id": element.productId,
                             @"start_latitude": [self returnStringValue:self.startLocation.latitude],
                             @"start_longitude": [self returnStringValue:self.startLocation.longitude],
                             @"end_latitude" : [self returnStringValue:self.endLocation.latitude],
                             @"end_longitude": [self returnStringValue:self.endLocation.longitude]
                             };
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *json = responseObject;
        self.request_id = [json objectForKey:@"request_id"];
        NSLog(@"this is the resposne object %@",responseObject);
        self.timer = [NSTimer scheduledTimerWithTimeInterval:3
                                         target:self
                                       selector:@selector(requestDriver:)
                                       userInfo:@{@"requestId":self.request_id,
                                                  @"token":accessToken,
                                                  }
                                        repeats:YES];
        self.tableView.hidden = YES;
        self.driverInformation.frame = self.tableView.frame;
        self.driverInformation.hidden = NO;
        CLLocation *carLocation = [[CLLocation alloc]initWithLatitude:0 longitude:0];
        self.carAnnotation = [[MKPlacemark alloc] initWithCoordinate:[carLocation coordinate] addressDictionary:nil];
        
        [self.mapView addAnnotation:self.carAnnotation];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        id json = error.userInfo;
        NSLog(@"failure %@", operation.responseObject);
    }];
}

-(NSString *)returnStringValue:(float)location{
    return [NSString stringWithFormat:@"%f",location];
}

-(void)requestDriver:(NSTimer *)timer{
    
    NSDictionary *timerDictionary = timer.userInfo;
    NSString *request = [timerDictionary objectForKey:@"requestId"];
    NSString *token = [timerDictionary objectForKey:@"token"];
    NSString *url = [NSString stringWithFormat:@"https://api.uber.com/v1/requests/%@",request];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    manager.requestSerializer = requestSerializer;
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *json = responseObject;
        [self displayDriverInformation:json];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)displayDriverInformation:(NSDictionary *)json{
    NSString *status = [json objectForKey:@"status"];
    self.requestGet = status;
    self.statusLabel.text = status;
    if ([status isEqual:@"accepted"]) {
        NSDictionary *driverInformation  = [json objectForKey:@"driver"];
        if (driverInformation) {
            self.nameLabel.hidden = NO;
            self.phoneNumber.hidden = NO;
            self.driverImage.hidden = NO;
            self.carImage.hidden = NO;
            
            self.nameLabel.text = [driverInformation objectForKey:@"name"];
            self.phoneNumber.text = [driverInformation objectForKey:@"phone_number"];
            if ([driverInformation objectForKey:@"picture_url"]) {
                 self.driverImage.image = [self getImageFromPath:[driverInformation objectForKey:@"picture_url"] ];
            }
            
            NSDictionary *drivercar = [json objectForKey:@"vehicle"];
            if ([drivercar objectForKey:@"picture_url"]) {
                self.carImage.image = [self getImageFromPath:[drivercar objectForKey:@"picture_url"]];

            }
            NSDictionary *location =[json objectForKey:@"location"];
            float lat = [[location objectForKey:@"latitude"]floatValue];
            float lon = [[location objectForKey:@"longitude"]floatValue];
            CLLocation *carLocation = [[CLLocation alloc]initWithLatitude:lat longitude:lon];
            NSLog(@"%@",carLocation);
            [self.mapView removeAnnotation:self.carAnnotation];
            self.carAnnotation=  [[MKPlacemark alloc] initWithCoordinate:[carLocation coordinate] addressDictionary:@{@"pin":@"one"}];
            
            [self.mapView addAnnotation:self.carAnnotation];
        }
    }
}

-(UIImage *)getImageFromPath:(NSString *)path{
    if (path) {
        
        @try {
            NSURL *url = [NSURL URLWithString:path];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *img = [[UIImage alloc] initWithData:data];
            return img;        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
            return nil;
        }
    }
    return nil;
}



@end
