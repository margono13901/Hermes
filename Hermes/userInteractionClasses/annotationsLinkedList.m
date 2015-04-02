//
//  annotationsLinkedList.m
//  Hermes
//
//  Created by Raylen Margono on 4/1/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import "annotationsLinkedList.h"


@implementation annotationsLinkedList

-(id)init{
    self = [super self];
    if (self) {
        self.storage = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)addToLink:(id)object{
    [self.storage addObject:object];
    placement = (int)self.storage.count-1;
}

-(id)returnAnnotatotation{
    id annotation = nil;
    if (placement < 0) {
        placement = (int)self.storage.count-1;
    }
    annotation = [self.storage objectAtIndex:placement--];
    return annotation;
}

@end
