//
//  SetDefaultMenuItem.m
//  Curbside
//
//  Created by Greg Walker on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SetDefaultMenuItem.h"


@implementation SetDefaultMenuItem
@synthesize indexPath;

- (void)dealloc {
    [indexPath release];
    [super dealloc];
}

@end