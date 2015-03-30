//
//  NSStack.h
//  Hermes
//
//  Created by Raylen Margono on 3/29/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import <Foundation/Foundation.h>
int static iterations=0;
@interface NSStack : NSObject

-(id)pop;
-(void)push:(id)object;
-(id)peek;
-(id)initWithArray:(NSArray *)array;
@property (strong,nonatomic)NSMutableArray *storage;
-(BOOL)isEmpty;
@end
