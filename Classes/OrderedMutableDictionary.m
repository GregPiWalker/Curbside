//
//  OrderedMutableDictionary.m
//  CurbSide
//
//  Created by Greg Walker on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OrderedMutableDictionary.h"
#import "Constants.h"


static NSString *const orderedKeysKey = @"orderedKeys";
static NSString *const dictionaryKey = @"dictionary";


@implementation OrderedMutableDictionary

+(void) initialize {
    [OrderedMutableDictionary setVersion: vOrderedMutableDictionary];
}

+(id) dictionary {
    //OrderedMutableDictionary *rdict = [[OrderedMutableDictionary alloc] init];
    OrderedMutableDictionary *rdict = [[[OrderedMutableDictionary alloc] init] autorelease];
    return rdict;
}

+(id) dictionaryWithObject:(id)object forKey:(id)key {
    //OrderedMutableDictionary *rdict = [[OrderedMutableDictionary alloc] initWithObjects:[NSArray arrayWithObject:object] forKeys:[NSArray arrayWithObject:key]];
    OrderedMutableDictionary *rdict = [[[OrderedMutableDictionary alloc] initWithObjects:[NSArray arrayWithObject:object] forKeys:[NSArray arrayWithObject:key]] autorelease];
    return rdict;
}

+(id) dictionaryWithObjects:(NSArray *)objects forKeys:(NSArray *)keys {
    //OrderedMutableDictionary *rval = [[OrderedMutableDictionary alloc] initWithObjects:objects forKeys:keys];
    OrderedMutableDictionary *rval = [[[OrderedMutableDictionary alloc] initWithObjects:objects forKeys:keys] autorelease];
    return rval;
}

+(id) orderedDictionaryWithDictionary: (NSDictionary *)dict {
    OrderedMutableDictionary *rdict = [[[OrderedMutableDictionary alloc] init] autorelease];
    //TODO: check that this maintains order.
    for (id key in dict) {
        [rdict setObject: [dict objectForKey: key] forKey: key];
    }
    return rdict;
}

//+(id) dictionaryWithObjectsAndKeys:(id)firstObject, ... {
//    return nil;
//}

-(id) init {
    self = [super init];
    if (self) {
        orderedKeys = [[NSMutableArray alloc] init];
        dictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(id) initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys {
    if ([objects count] != [keys count]) {
        NSLog(@"Warning: OrderedMutableDictionary Object-Key counts differ.");
    }
    //self = [super initWithObjects:objects forKeys:keyCopies];
    self = [super init];
    if (self) {
        NSMutableArray *keyCopies = [[NSMutableArray arrayWithCapacity:[keys count]] retain];
        // Try to deep copy the keys for robustness.
        for (id key in keys) {
            if ([key respondsToSelector:@selector(copy)]) {
                [keyCopies addObject:[[key copy] autorelease]];
            }
            else {
                [keyCopies addObject:key];
            }
        }
        orderedKeys = keyCopies;
        dictionary = [[NSMutableDictionary dictionaryWithObjects:objects forKeys:keyCopies] retain];
    }
    return self;
}

-(void) dealloc {
    [orderedKeys release];
    [dictionary release];
    [super dealloc];
}


#pragma mark NSDictionary Primitive Methods

-(NSUInteger) count {
    return [orderedKeys count];
}

-(id) objectForKey:(id)aKey {
    if ([orderedKeys containsObject:aKey]) {
        return [dictionary objectForKey:aKey];
    }
    return nil;
}

-(NSEnumerator *) keyEnumerator {
    return [orderedKeys objectEnumerator];
}


#pragma mark NSMutableDictionary Methods

-(void) setObject:(id)anObject forKey:(id)aKey {
    //[super setObject:anObject forKey:aKey];
    [dictionary setObject:anObject forKey:aKey];
    [orderedKeys addObject:aKey];
}

-(void) removeObjectForKey:(id)aKey {
    //[super removeObjectForKey:aKey];
    [dictionary removeObjectForKey:aKey];
    [orderedKeys removeObject:aKey];
}

-(void) removeAllObjects {
    //[super removeAllObjects];
    [dictionary removeAllObjects];
    [orderedKeys removeAllObjects];
}

-(NSArray *) allKeys {
    return [[orderedKeys copy] autorelease];
}

-(NSArray *) allValues {
    NSMutableArray *rval = [NSMutableArray arrayWithCapacity:[orderedKeys count]];
    for (id key in orderedKeys) {
        [rval addObject:[self objectForKey:key]];
    }
    return rval;
}

-(NSString *) description {
    NSString *desc = @"{\n";
    int c = 1;
    for (id key in self) {
        desc = [desc stringByAppendingFormat: @"\t\t%i. \"%@\" = \"%@\";\n", c++, key, [self objectForKey: key]];
    }
    desc = [desc stringByAppendingString: @"}"];
    return desc;
}


#pragma mark NSCopying Methods

/// Returns a retained copy since the NSCopying docs say:
/// "the returned object is implicitly retained by the sender, who is responsible for releasing it."
-(id) copyWithZone:(NSZone *)zone {
    // The object is implicitly retained by the sender, meaning that the sender retains without having to issue retain message.
    OrderedMutableDictionary *copy = [[OrderedMutableDictionary allocWithZone:zone] initWithObjects:[super allValues] forKeys:orderedKeys];
    return copy;
}


#pragma mark NSCoding Methods

// If this method changes, be sure to update the Class Version.
-(id) initWithCoder: (NSCoder *)decoder {
    //[super initWithCoder:decoder];
    self = [super init];
    dictionary = [[decoder decodeObjectForKey:dictionaryKey] retain];
    orderedKeys = [[decoder decodeObjectForKey:orderedKeysKey] retain];
    
    return self;
}

// If this method changes, be sure to update the Class Version.
-(void) encodeWithCoder: (NSCoder *)coder {
    //[super encodeWithCoder:coder];
    [coder encodeObject:dictionary forKey:dictionaryKey];
    [coder encodeObject:orderedKeys forKey:orderedKeysKey];
}

/// Overriding this method allows the NSCoding to store instances as OrderedMutableDictionaries.
-(Class) classForCoder {
    return [OrderedMutableDictionary class];
}

@end
