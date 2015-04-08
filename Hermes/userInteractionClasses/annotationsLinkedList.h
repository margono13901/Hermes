//
//  annotationsLinkedList.h
//  Hermes
//
//  Created by Raylen Margono on 4/1/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "keys.h"
#import "AppDelegate.h"

static int placement;

@interface annotationsLinkedList : NSObject
@property(strong,nonatomic)NSMutableArray *storage;
-(id)init;
-(id)scrollThroughAnnotatotation;
-(void)addToLink:(id)object;
-(id)scrollBackThroughAnnotatotation;
@end



