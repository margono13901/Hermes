
//
//  userInteractionViewUtils.m
//  Hermes
//
//  Created by Raylen Margono on 4/23/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import "userInteractionViewUtils.h"

@implementation userInteractionViewUtils

+(void)getGeoCodingInformationWithLat:(double)lat withLon:(double)lon withLocationView:(UITextField *)locationView{
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
        if (jsonData.count>0) {
            NSDictionary *allData = jsonData[0];
            NSString *location = [allData objectForKey:@"place_name"];
            NSArray* stringArray = [location  componentsSeparatedByString:@","];
            NSMutableString *text = [[NSMutableString alloc]init];
            for (int i = 0 ; i < stringArray.count-1; i++) {
                [text appendString:stringArray[i]];
                [text appendString:@" "];
            }
            locationView.text = [NSString stringWithFormat:@"%@",text];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

+(void)getPlaceName:(double)lat withLon:(double)lon withUserView:(UITextView *)textView{
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/radarsearch/json?"];
    NSDictionary *params = @{@"key":googlePlaceAPIKey,
                             @"location":[NSString stringWithFormat:@"%f,%f",lat,lon],
                             @"radius": [NSString stringWithFormat:@"%i",100],
                             @"sensor" :@"false",
                             @"types":@"establishment"
                             };
    
    AFSecurityPolicy *policy = [[AFSecurityPolicy alloc] init];
    [policy setAllowInvalidCertificates:YES];
    
    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    [operationManager setSecurityPolicy:policy];
    operationManager.requestSerializer = [AFJSONRequestSerializer serializer];
    operationManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operationManager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *json  = responseObject;
        if (((NSArray *)[json objectForKey:@"results"]).count>0) {
            NSDictionary *result =[json objectForKey:@"results"][0];
            NSString *place_id = [result objectForKey:@"place_id"];
            [self getPLaceName:lat withLon:lon placeId:place_id withUserTextView:textView];
        }
       

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

+(void)getPLaceName:(double)lat withLon:(double)lon placeId:(NSString *)placeId withUserTextView:(UITextView *)textView{
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=%@",placeId,googlePlaceAPIKey];
    AFSecurityPolicy *policy = [[AFSecurityPolicy alloc] init];
    [policy setAllowInvalidCertificates:YES];
    
    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    [operationManager setSecurityPolicy:policy];
    operationManager.requestSerializer = [AFJSONRequestSerializer serializer];
    operationManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operationManager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *json  = responseObject;
        NSDictionary *result= [json objectForKey:@"result"];
        NSString *name = [result objectForKey:@"name"];
        
        NSString *string = textView.text;
        textView.text = [NSString stringWithFormat:@"%@ is near %@",string,name];
      
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


+(UIImage *)getImageView:(UIView *)view{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * myImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return myImage;
}

+(NSString *)returnDateOfLatestAnnotation:(RMAnnotation *)layer{
    NSQueue *queue = layer.userInfo;
    PFObject *latestPost = [queue peek];
    int date = (int)[[NSDate date] timeIntervalSinceDate:[latestPost createdAt]]/60;
    if (date>60) {
        return [NSString stringWithFormat:@"%i hours ago",(int)[[NSDate date] timeIntervalSinceDate:[latestPost createdAt]]/3600];
    }
    return [NSString stringWithFormat:@"%i minutes ago",(int)[[NSDate date] timeIntervalSinceDate:[latestPost createdAt]]/60];
}

+(BOOL)distanceIsClose:(PFObject *)post1 to:(PFObject *)post2{
    PFGeoPoint *g1 = post1[@"location"];
    PFGeoPoint *g2 = post2[@"location"];
    CLLocation *l1 = [[CLLocation alloc]initWithLatitude:[g1 latitude] longitude:[g1 longitude]];
    CLLocation *l2 = [[CLLocation alloc]initWithLatitude:[g2 latitude] longitude:[g2 longitude]];
    if ([l1 distanceFromLocation:l2]<50) {
        return true;
    }
    return false;
}




@end
