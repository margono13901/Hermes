//
//  NSStack.m
//  Hermes
//
//  Created by Raylen Margono on 3/29/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import "NSStack.h"

@implementation NSStack

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

- (void) push: (id)item {
    [self.storage addObject:item];
}

- (id) pop {
    id item = nil;
    if ([self.storage count] != 0) {
        item = [self.storage lastObject];
        [self.storage removeLastObject];
    }
    return item;
}

- (id) peek {
    id item = nil;
    if ([self.storage count] != 0) {
        item = [self.storage lastObject];
    }
    return item;
}

-(BOOL)isEmpty{
    return [self.storage count]==0;
}

@end
