//
//  NSQueue.h
//  Hermes
//
//  Created by Raylen Margono on 3/26/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSQueue : NSObject

-(id)peek;
-(void)enqueue:(id)object;
-(id)dequeue;
-(BOOL)isEmpty;
-(id)initWithArray:(NSArray *)array;

@property(strong,nonatomic) NSMutableArray *storage;

@end
