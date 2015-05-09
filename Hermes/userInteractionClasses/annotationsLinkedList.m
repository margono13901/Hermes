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
}

-(id)scrollThroughAnnotatotation{
    id annotation = nil;
    if ([self placementOutOfIndex]) {
        placement = 0;
    }
    annotation = [self.storage objectAtIndex:placement++];
    return annotation;
}

-(id)scrollBackThroughAnnotatotation{
    id annotation = nil;
    if ([self placementOutOfIndex]) {
        placement = (int)self.storage.count-1;
    }
    annotation = [self.storage objectAtIndex:placement--];
    return annotation;
}


-(BOOL)placementOutOfIndex{
    return placement < 0||placement >= self.storage.count;
}

+(void)changeToFirstPlacement{
    placement=1;
}


@end
