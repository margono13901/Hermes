//
//  NSQueue.m
//  Hermes
//
//  Created by Raylen Margono on 3/26/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import "NSQueue.h"

@implementation NSQueue

-(id)init{
    if (self = [super init]){
        self.storage = [[NSMutableArray alloc]init];
    }
    return self;
}


-(id)initWithArray:(NSArray *)array{
    if (self = [super init]){
        self.storage = [[NSMutableArray alloc]initWithArray:array];
    }
    return self;
}

-(id)peek{
    id item = nil;
    if ([self.storage count] != 0) {
        item = [self.storage objectAtIndex:0];
    }
    return item;
}

-(void)enqueue:(id)object{
    [self.storage addObject:object];
}

-(id)dequeue{
    id item = nil;
    if ([self.storage count] != 0) {
        item = [self.storage objectAtIndex:0];
        [self.storage removeObjectAtIndex:0];
    }
    return item;
}

-(BOOL)isEmpty{
    return [self.storage count]==0;
}



@end
