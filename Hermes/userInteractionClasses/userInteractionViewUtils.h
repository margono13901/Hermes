//
//  userInteractionViewUtils.h
//  Hermes
//
//  Created by Raylen Margono on 4/23/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "userInteractionView.h"

@interface userInteractionViewUtils : NSObject

+(UIImage *)getImageView:(UIView *)view;
+(void)getGeoCodingInformationWithLat:(double)lat withLon:(double)lon withTextView:(UITextView *)locationView;
+(NSString *)returnDateOfLatestAnnotation:(RMAnnotation *)layer;
+(BOOL)distanceIsClose:(PFObject *)post1 to:(PFObject *)post2;



@end
