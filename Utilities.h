//
//  Utilities.h
//  CurbSide
//
//  Created by Greg Walker on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString* GUID;


@interface Utilities : NSObject {
    
}

+(GUID) createGUID;

@end

/// Other goodies


@interface NSString (containsCategory)

-(BOOL) containsString: (NSString *)substring;
-(BOOL) containsCaseInsensitiveString: (NSString *)substring;
-(BOOL) containsAnyCharacterOfSet: (NSSet *)charSet options: (NSStringCompareOptions)mask;
-(BOOL) containsAllCharactersOfSet: (NSSet *)charSet options: (NSStringCompareOptions)mask;
-(BOOL) containsOnlyCharactersOfSet: (NSCharacterSet *)charSet options: (NSStringCompareOptions)mask;
-(NSString *) stripNonDigitCharacters;
-(BOOL) hasPrefix: (NSString *)substring options: (NSStringCompareOptions)mask;
-(BOOL) hasSuffix: (NSString *)substring options: (NSStringCompareOptions)mask;

@end

@interface NSDate (comparisonCategory)
-(NSComparisonResult) reverseCompare: (id)otherDate;
@end
