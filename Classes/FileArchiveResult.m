//
//  FileArchiveResult.m
//  Curbside
//
//  Created by Greg Walker on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FileArchiveResult.h"


@implementation FileArchiveResult

@synthesize isCompressed;
@synthesize archiveData;
@synthesize fileName;
@synthesize creationDate;

-(id) initWithFilename: (NSString *)name andData: (NSData *)data andCreationDate: (NSDate *)date isCompressed: (BOOL)compressed {
    self = [super init];
    if (name && date && data) {
        // Point to the same data buffer for efficiency.
        archiveData = [data retain];
        fileName = [name copy];
        creationDate = [date copy];
    }
    else {
        archiveData = nil;
        fileName = nil;
        creationDate = nil;
    }
    isCompressed = compressed;
    return self;
}

-(void) dealloc {
    [archiveData release];
    [fileName release];
    [creationDate release];
    [super dealloc];
}

@end
