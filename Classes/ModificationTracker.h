//
//  ModificationTracker.h
//  Curbside
//
//  Created by Greg Walker on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ModificationTracker : NSObject {
    NSMutableDictionary *additions;
    NSMutableDictionary *deletions;
}

@property (nonatomic, readonly) NSMutableDictionary *additions;

@property (nonatomic, readonly) NSMutableDictionary *deletions;

-(NSArray *) additionsForClass: (Class)c;
-(NSArray *) deletionsForClass: (Class)c;

-(void) setAdditions: (NSArray *)add ForClass: (Class)c;
-(void) setDeletions: (NSArray *)del ForClass: (Class)c;

@end
