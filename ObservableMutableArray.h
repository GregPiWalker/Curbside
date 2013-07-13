//
//  ObservableMutableArray.h
//  CurbSide
//
//  Created by Greg Walker on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define OBSERVABLE_MUTABLE_ARRAY(Classname, Propertyname, propertyname) \
 \
@interface Classname (ObservableMutable##Propertyname##Array) \
 \
-(NSUInteger) countOf##Propertyname; \
-(id) objectIn##PropertynameAtIndex:(NSUInteger)index; \
-(NSArray *) propertynameAtIndexes:(NSIndexSet *)indexes; \
-(void) get##Propertyname:(NSString **)buffer range:(NSRange)inRange; \
 \
-(void) insertObject:(id)object in##PropertynameAtIndex:(NSUInteger)index; \
-(void) insert##Propertyname:(NSArray *)array atIndexes:(NSIndexSet *)indexes; \
 \
-(void) removeObjectFrom##PropertynameAtIndex:(NSUInteger)index; \
-(void) remove##PropertynameAtIndexes:(NSIndexSet *)indexes; \
 \
-(void) replaceObjectIn##PropertynameAtIndex:(NSUInteger)index withObject:(id)anObject; \
-(void) replace##PropertynameAtIndexes:(NSIndexSet *)indexes withItems:(NSArray *)array; \
 \
@end \
 \
 \
@implementation Classname (ObservableMutable##Propertyname##Array) \
\
-(NSUInteger) countOf##Propertyname { \
    return [self.propertyname count]; \
} \
-(id) objectIn##PropertynameAtIndex:(NSUInteger)index { \
    return [self.propertyname objectAtIndex:index]; \
} \
-(NSArray *) propertynameAtIndexes:(NSIndexSet *)indexes { \
    return [self.propertyname objectsAtIndexes:indexes]; \
} \
-(void) get##Propertyname:(NSString **)buffer range:(NSRange)inRange { \
    return [self.propertyname getObjects:buffer range:inRange]; \
} \
 \
 \
-(void) insertObject:(id)object in##PropertynameAtIndex:(NSUInteger)index { \
    [self.propertyname insertObject:object atIndex:index]; \
    return; \
} \
-(void) insert##Propertyname:(NSArray *)array atIndexes:(NSIndexSet *)indexes { \
    [self.propertyname insertObjects:array atIndexes:indexes]; \
    return; \
} \
 \
 \
-(void) removeObjectFrom##PropertynameAtIndex:(NSUInteger)index { \
    [self.propertyname removeObjectAtIndex:index]; \
} \
-(void) remove##PropertynameAtIndexes:(NSIndexSet *)indexes { \
    [self.propertyname removeObjectsAtIndexes:indexes]; \
} \
 \
 \
-(void) replaceObjectIn##PropertynameAtIndex:(NSUInteger)index withObject:(id)anObject { \
    [self.propertyname replaceObjectAtIndex:index withObject:anObject]; \
} \
-(void) replace##PropertynameAtIndexes:(NSIndexSet *)indexes withItems:(NSArray *)array { \
    [self.propertyname replaceObjectsAtIndexes:indexes withObjects:array]; \
} \
 \
@end
