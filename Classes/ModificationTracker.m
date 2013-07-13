//
//  ModificationTracker.m
//  Curbside
//
//  Created by Greg Walker on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ModificationTracker.h"


@implementation ModificationTracker

@synthesize additions;
@synthesize deletions;

-(id) init {
    self = [super init];
    if (self) {
        additions = [[NSMutableDictionary alloc] init];
        deletions = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(NSArray *) additionsForClass: (Class)c {
    id add = [additions objectForKey: c];
    if (add && [add isKindOfClass: [NSArray class]]) {
        return add;
    }
    else {
        return [NSArray array];
    }
}

-(NSArray *) deletionsForClass: (Class)c {
    id del = [deletions objectForKey: c];
    if (del && [del isKindOfClass: [NSArray class]]) {
        return del;
    }
    else {
        return [NSArray array];
    }
}

-(void) setAdditions: (NSArray *)add ForClass: (Class)c {
    if (add && ![additions objectForKey: c]) {
        [additions setObject: [NSArray arrayWithArray: add] forKey: (id<NSCopying>)c];
    }
}

-(void) setDeletions: (NSArray *)del ForClass: (Class)c {
    if (del && ![deletions objectForKey: c]) {
        [deletions setObject: [NSArray arrayWithArray: del] forKey: (id<NSCopying>)c];
    }
}

-(void) dealloc {
    [additions release];
    [deletions release];
    [super dealloc];
}

@end
