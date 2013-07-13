//
//  FileArchiveResult.h
//  Curbside
//
//  Created by Greg Walker on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileArchiveResult : NSObject {
    NSData *archiveData;
    NSString *fileName;
    NSDate *creationDate;
    BOOL isCompressed;
}

@property (nonatomic, readonly) NSData *archiveData;

@property (nonatomic, readonly) NSString *fileName;

@property (nonatomic, readonly) NSDate *creationDate;

@property (nonatomic, readonly) BOOL isCompressed;

-(id) initWithFilename: (NSString *)name andData: (NSData *)data andCreationDate: (NSDate *)date isCompressed: (BOOL)compressed;

@end
