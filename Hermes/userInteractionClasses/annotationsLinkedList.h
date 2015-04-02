//
//  annotationsLinkedList.h
//  Hermes
//
//  Created by Raylen Margono on 4/1/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import <Foundation/Foundation.h>

static int placement;

@interface annotationsLinkedList : NSObject
@property(strong,nonatomic)NSMutableArray *storage;
-(id)init;
-(id)returnAnnotatotation;
-(void)addToLink:(id)object;
@end



