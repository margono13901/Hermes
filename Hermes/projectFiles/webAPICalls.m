//
//  webAPICalls.m
//  Hermes
//
//  Created by Raylen Margono on 4/10/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import "webAPICalls.h"

@implementation webAPICalls

+(NSString *)getGeoCodingInformationWithLat:(double)lat withLon:(double)lon{
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
        for (int i = 0 ; i < 4; i++) {
            [text appendString:stringArray[i]];
            [text appendString:@" "];
        }
        self->re
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
