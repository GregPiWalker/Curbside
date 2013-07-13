//
//  Utilities.m
//  CurbSide
//
//  Created by Greg Walker on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Utilities.h"


@implementation Utilities

#pragma mark - Class Methods

+(GUID) createGUID {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return [(NSString *)string autorelease];
}

@end

/// Other goodies

@implementation NSString (containsCategory)

-(BOOL) containsString: (NSString *)substring {    
    NSRange range = [self rangeOfString : substring];
    BOOL found = ( range.location != NSNotFound );
    
    return found;
}

-(BOOL) containsCaseInsensitiveString: (NSString *)substring {    
    NSRange range = [self rangeOfString : substring options: NSCaseInsensitiveSearch];
    BOOL found = ( range.location != NSNotFound );
    
    return found;
}

-(BOOL) containsOnlyCharactersOfSet: (NSCharacterSet *)charSet options: (NSStringCompareOptions)mask {  
    for (int i = 0; i < [self length]; i++) {
        unichar c[1];
        c[0] = [self characterAtIndex: i];
        NSRange range = [[NSString stringWithCharacters: c length: 1] rangeOfCharacterFromSet: charSet options: mask];
        if (range.location != NSNotFound) {
            return NO;
        }
    }
    return YES;
}

-(BOOL) containsAnyCharacterOfSet: (NSSet *)charSet options: (NSStringCompareOptions)mask {
    for (id c in charSet) {
        NSRange range = [self rangeOfString: c options: mask];
        if (range.location != NSNotFound) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL) containsAllCharactersOfSet: (NSSet *)charSet options: (NSStringCompareOptions)mask {
    for (id c in charSet) {
        NSRange range = [self rangeOfString: c options: mask];
        if (range.location == NSNotFound) {
            return NO;
        }
    }
    
    return YES;
}

-(NSString *) stripNonDigitCharacters {
    NSString *stripped = @"";
    for (int i = 0; i < [self length]; i++) {
        if (isdigit([self characterAtIndex:i])) {
            stripped = [stripped stringByAppendingFormat: @"%c", [self characterAtIndex:i]];
        }
    }
    return stripped;
}

-(BOOL) hasSuffix: (NSString *)substring options: (NSStringCompareOptions)mask {
    NSRange range = [self rangeOfString : substring options: mask];
    BOOL found = ( range.location == [self length] - range.length );
    
    return found;
}

-(BOOL) hasPrefix: (NSString *)substring options: (NSStringCompareOptions)mask {
    NSRange range = [self rangeOfString : substring options: mask];
    BOOL found = ( range.location == 0 );
    
    return found;
}

@end


@implementation NSDate (comparisonCategory)

/// reverseCompare
///
/// Returns the opposite results of compare.
-(NSComparisonResult) reverseCompare: (id)otherDate {
    if ([otherDate isKindOfClass: [NSDate class]]) {
        NSComparisonResult result = [self compare: otherDate];
        if (result == NSOrderedAscending) {
            return NSOrderedDescending;
        }
        else if (result == NSOrderedDescending) {
            return NSOrderedAscending;
        }
        else {
            return result;
        }
    }
    // TODO: exception handling.
    return NSIntegerMax;
}

@end
