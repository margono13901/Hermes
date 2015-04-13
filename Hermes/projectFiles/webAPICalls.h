//
//  webAPICalls.h
//  Hermes
//
//  Created by Raylen Margono on 4/10/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "keys.h"

@interface webAPICalls : NSObject
+(NSString *)getGeoCodingInformationWithLat:(double)lat withLon:(double)lon;
@property(strong,nonatomic)id request;
@end
