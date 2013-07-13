//
//  OrderedMutableDictionary.h
//  CurbSide
//
//  Created by Greg Walker on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Only change this value if initWithCoder or encodeWithCoder change.
static const NSInteger vOrderedMutableDictionary = 1;

@interface OrderedMutableDictionary : NSMutableDictionary <NSCoding> {
    @private
    NSMutableArray *orderedKeys;
    NSMutableDictionary *dictionary;
}

+(id) orderedDictionaryWithDictionary: (NSDictionary *)dict;

@end
